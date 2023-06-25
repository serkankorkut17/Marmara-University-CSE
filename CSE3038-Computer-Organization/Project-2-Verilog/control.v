module control(in,regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,balmz,jsp,bn,aluop1,aluop2);
input [5:0] in;
output regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,balmz,jsp,bn,aluop1,aluop2;
wire rformat,lw,sw,beq;
assign rformat=~|in;
assign lw=in[5]& (~in[4])&(~in[3])&(~in[2])&in[1]&in[0];
assign sw=in[5]& (~in[4])&in[3]&(~in[2])&in[1]&in[0];
assign beq=~in[5]& (~in[4])&(~in[3])&in[2]&(~in[1])&(~in[0]);
assign balmz=~in[5]& in[4]&(~in[3])&in[2]&in[1]&in[0];		//balmz => 23=010111
assign jsp=~in[5]& in[4]&(~in[3])&(~in[2])&in[1]&(~in[0]);		//jsp => 18=010010
assign bn=~in[5]& in[4]&in[3]&(~in[2])&(~in[1])&in[0];		//bn => 25=011001
assign regdest=rformat;
assign alusrc=lw|sw|balmz|jsp;
assign memtoreg=lw;
assign regwrite=rformat|lw|balmz;
assign memread=lw|balmz|jsp;
assign memwrite=sw;
assign branch=beq;
assign aluop1=rformat;
assign aluop2=beq;
endmodule
