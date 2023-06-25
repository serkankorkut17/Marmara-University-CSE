module processor;
reg [31:0] pc; //32-bit prograom counter
reg clk; //clock
reg [7:0] datmem[0:31],mem[0:31]; //32-size data and instruction memory (8 bit(1 byte) for each location)

reg [2:0] statusZNV;
//reg n;	//negative status
//reg z;	//zero status
//reg v;	//overflow status

wire [31:0] 
dataa,	//Read data 1 output of Register File
datab,	//Read data 2 output of Register File
out2,		//Output of mux with ALUSrc control-mult2
out3,		//Output of mux with MemToReg control-mult3
out3_1,		//Output of mux with Balmz(after MemToReg) control-mult3_1
out4,		//Output of mux with (Branch&ALUZero) control-mult4
out5,		//Output of mux with (Balmz&ALUZero and Jsp) control-mult5
out6,		//Output of mux with (Bn) control-mult6
sum,		//ALU result
extad,	//Output of sign-extend unit
adder1out,	//Output of adder which adds PC and 4-add1
adder2out,	//Output of adder which adds PC+4 and 2 shifted sign-extend result-add2
sextad,	//Output of shift left 2 unit
target;	//pseudo-direct address

wire [5:0] inst31_26;	//31-26 bits of instruction
wire [4:0] 
inst25_21,	//25-21 bits of instruction
inst20_16,	//20-16 bits of instruction
inst15_11,	//15-11 bits of instruction
out1,		//Write data input of Register File
out1_1;		//Register File[31] if instruction is jmsub if not out1

wire [15:0] inst15_0;	//15-0 bits of instruction

wire [31:0] instruc,	//current instruction
dpack;	//Read data output of memory (data read from memory)

wire [2:0] gout;	//Output of ALU control unit
wire balrz,		//Output of balrz signal in ALU control unit
jmsub;			//Output of jmsub signal in ALU control unit

wire zout,	//Zero output of ALU
nout,		//Negative output of ALU
vout,		//Overflow output of ALU
pcsrc0,	//Output of AND gate with Branch and ZeroOut inputs
pcsrc1,	//Output of AND gate with Balmz and ZeroOut inputs
pcsrc2,	//Output of AND gate with Bn and NOut inputs
//Control signals
regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,balmz,jsp,bn,aluop1,aluop0;

//32-size register file (32 bit(1 word) for each register)
reg [31:0] registerfile[0:31];

integer i;

// datamemory connections

always @(posedge clk)
//write data to memory
if (memwrite)
begin 
//sum stores address,datab stores the value to be written
datmem[sum[4:0]+3]=datab[7:0];
datmem[sum[4:0]+2]=datab[15:8];
datmem[sum[4:0]+1]=datab[23:16];
datmem[sum[4:0]]=datab[31:24];
end

//instruction memory
//4-byte instruction
 assign instruc={mem[pc[4:0]],mem[pc[4:0]+1],mem[pc[4:0]+2],mem[pc[4:0]+3]};
 assign inst31_26=instruc[31:26];
 assign inst25_21=instruc[25:21];
 assign inst20_16=instruc[20:16];
 assign inst15_11=instruc[15:11];
 assign inst15_0=instruc[15:0];


// registers
mult2_to_1_32  multread1(dataa, registerfile[inst25_21],registerfile[29],jsp);
//assign dataa=registerfile[inst25_21];//Read register 1
assign datab=registerfile[inst20_16];//Read register 2
always @(posedge clk)
 registerfile[out1_1]= regwrite ? out3_1:registerfile[out1_1];//Write data to register

//read data from memory, sum stores address
assign dpack={datmem[sum[5:0]],datmem[sum[5:0]+1],datmem[sum[5:0]+2],datmem[sum[5:0]+3]};

//multiplexers
//mux with RegDst control
mult2_to_1_5  mult1(out1, instruc[20:16],instruc[15:11],regdest);

//mux with jmsub control
mult2_to_1_5  mult1_1(out1_1, out1,5'b11111,jmsub);

//mux with ALUSrc control
mult2_to_1_32 mult2(out2, datab,extad,alusrc);

//mux with MemToReg control
mult2_to_1_32 mult3(out3, sum,dpack,memtoreg);

//mux with Balmz, Balrz, Jmsub control
mult2_to_1_32 mult3_1(out3_1, out3,adder1out,pcsrc1);

//mux with (Branch&ALUZero) control
mult2_to_1_32 mult4(out4, adder1out,adder2out,pcsrc0);

//mux with (Balmz&ALUZero and jsp and balrz and jmsub) control
mult2_to_1_32 mult5(out5, out4,dpack,pcsrc1);

//mux with bn control
assign 	 target = {adder1out[31:28], instruc[25:0], {2'b00}};
mult2_to_1_32 mult6(out6, out5,target,pcsrc2);

// load pc
always @(negedge clk)
begin
	pc=out6;
  	statusZNV[2] = zout;
	statusZNV[1] = nout;
	statusZNV[0] = vout;
end

// alu, adder and control logic connections

//ALU unit
alu32 alu1(sum,dataa,out2,zout,nout,vout,gout); 

//adder which adds PC and 4
adder add1(pc,32'h4,adder1out);

//adder which adds PC+4 and 2 shifted sign-extend result
adder add2(adder1out,sextad,adder2out);

//Control unit
control cont(instruc[31:26],regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,balmz,jsp,bn,
aluop1,aluop0);

//Sign extend unit
signext sext(instruc[15:0],extad);

//ALU control unit
alucont acont(aluop1,aluop0,instruc[5],instruc[4],instruc[3],instruc[2], instruc[1], instruc[0] ,gout,balrz,jmsub);

//Shift-left 2 unit
shift shift2(sextad,extad);

//AND gate
assign pcsrc0=branch && statusZNV[2];
assign pcsrc1=(balmz && statusZNV[2]) || jsp || (balrz && statusZNV[2]) || jmsub;
assign pcsrc2=bn && statusZNV[1];

//initialize datamemory,instruction memory and registers
//read initial data from files given in hex
initial
begin
$readmemh("initDm.dat",datmem); //read Data Memory
$readmemh("initIM.dat",mem);//read Instruction Memory
$readmemh("initReg.dat",registerfile);//read Register File

	for(i=0; i<31; i=i+1)
	$display("Instruction Memory[%0d]= %h  ",i,mem[i],"Data Memory[%0d]= %h   ",i,datmem[i],
	"Register[%0d]= %h",i,registerfile[i]);
end

initial
begin
pc=0;
#1000 $finish;
	
end
initial
begin
clk=0;
//40 time unit for each cycle
forever #20  clk=~clk;
end
initial 
begin
  $monitor($time,"PC %h",pc,"  SUM %h",sum,"   INST %h",instruc[31:0],
"   REGISTER %h %h %h %h %h ",registerfile[1],registerfile[2],registerfile[3],registerfile[31],registerfile[5], registerfile[6] );
end
endmodule
