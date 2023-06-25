module alucont(aluop1,aluop0,f5,f4,f3,f2,f1,f0,gout,balrz,jmsub);//Figure 4.12 
input aluop1,aluop0,f5,f4,f3,f2,f1,f0;
output [2:0] gout;
output balrz;
output jmsub;
reg balrz = 1'b0;
reg jmsub = 1'b0;
reg [2:0] gout;
always @(aluop1 or aluop0 or f5 or f4 or f3 or f2 or f1 or f0)
begin
if(~(aluop1|aluop0))  gout=3'b010;
if(aluop0)gout=3'b110;
if(aluop1)//R-type
begin
	if (f5&~(f4|f3|f2|f1|f0))gout=3'b010; 	//function code=100000,ALU control=010 (add)
	if (f5&~(f4)&f3&~(f2)&f1&~(f0))gout=3'b111;			//function code=101010,ALU control=111 (set on less than)
	if (f5&~(f4)&~(f3)&~(f2)&f1&~(f0))gout=3'b110;		//function code=100010,ALU control=110 (sub)
	if (f5&~(f4)&~(f3)&f2&~(f1)&f0)gout=3'b001;		//function code=100101,ALU control=001 (or)
	if (f5&~(f4)&f2&~(f0))gout=3'b000;		//function code=10x1x0,ALU control=000 (and)
	if (~(f5)&~(f4)&~(f3)&f2&~(f1)&~(f0))gout=3'b011;	//function code=000100,ALU control=011 (sllv)
	if (~(f5)&f4&~(f3)&f2&f1&~(f0))
	begin
		gout=3'b100;	//function code=010110,ALU control=100 (balrz)
		balrz = 1'b1;
	end
	if (f5&~(f4)&~(f3)&~(f2)&f1&f0)
	begin
		gout=3'b110;	//function code=100011,ALU control=110 (sub)(jmsub)
		jmsub = 1'b1;	//bozuk
	end
end
end
endmodule