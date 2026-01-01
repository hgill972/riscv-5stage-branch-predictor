module execute(
input RegWrite,
input [1:0] ResultSrc, // Control unit inputs
input MemWrite,
input Jump,
input branch ,
input [3:0] ALUControl,
input ALUSrc,
input [31:0] RD1E, RD2E, // Register file inputs
input [31:0] immext,
input [4:0] currentaddress,nxtadd,Rde,
input clk,reset,


output branchchoice,
output regwitem,
output memwritem,
output [1:0] resultsrcm,
output [31:0] solm,regdatam,
output [4:0] nxtaddoutm,Rdm,jumping,
output [31:0] regdata,
output zero_flag, Neg_flag,

input [1:0] ForwardAE, ForwardBE,
input [31:0] Memoeyregvalue,Writeregvalue,
output [31:0] Bout,Aout

);
 wire [31:0] Bin,sol,solfinal;
 wire optionsel;
 
//mux3to1 m1
//mux3to1 m2
assign optionsel=ResultSrc[0]&ResultSrc[1];
mux2to1 m3(RD2E,immext,ALUSrc,Bin);

mux3to1  m4(RD1E,Memoeyregvalue,Writeregvalue,ForwardAE,Aout);
mux3to1  m5(Bin,Memoeyregvalue,Writeregvalue,ForwardBE,Bout);

//ALUREG m4(Bin,clk,Bout);
//ALUREG m5(RD1E,clk,Aout);
ALU m6(ALUControl,Aout,Bout,sol,zero_flag, Neg_flag);
mux2to1 m9(sol,immext,optionsel,solfinal);
//programaddr m7(currentaddress,immext,jumping);
assign branchchoice= branch;

instructionreg3 m8(clk,reset,
immext,
 RegWrite,
   ResultSrc, // Control unit inputs
 MemWrite,
 Rde,nxtadd,
solfinal,RD2E,	 
 nxtaddoutm,Rdm,
 solm,regdatam,	 
 regwitem,
 resultsrcm, // Control unit inputs
 memwritem,
 regdata);

endmodule

module mux3to1(
    input [31:0] A,
    input [31:0] B,
    input [31:0] C,
    input [1:0] choice,
    output reg [31:0] data
);

always @(*)
begin
    case (choice)
        2'b00: data = A;
        2'b01: data = B;
        2'b10: data = C;
    endcase
end

endmodule


module mux2to1(
    input [31:0] A,
    input [31:0] B,
    input choice,
    output reg [31:0] data
);

always @(*)
begin
    if (!choice)
        data = A;
    else
        data = B;
end

endmodule






module instructionreg3(

input clk,reset,
input [31:0] immext,
input RegWrite,
 input [1:0] ResultSrc, // Control unit inputs
 input MemWrite,
input [4:0] Rde,nxtadd,
input [31:0] sol,regdata,	 
output reg[4:0] nxtaddout,Rdm,
output reg [31:0] solm,regdatam,	 
output reg RegWritem,
 output reg [1:0] ResultSrcm, // Control unit inputs
 output reg MemWritem,
 output reg [31:0] regdatawrite
);

always@(posedge clk or posedge reset)
begin
if (reset)
begin

nxtaddout<=0;
Rdm<=0;
solm<=0;
regdatam <=  0;
RegWritem <= 0;
ResultSrcm <= 0;
MemWritem <= 0;
regdatawrite<=0;
end
else
begin
nxtaddout<=nxtadd;
Rdm<=Rde;
solm<=sol;
regdatam <=  regdata;
RegWritem <= RegWrite;
ResultSrcm <= ResultSrc;
MemWritem <= MemWrite;
regdatawrite<=immext;

end

end




endmodule















module ALU(
input [3:0] ALUcontrol,
input [31:0] A,B,

output reg [31:0] sol,
output reg zero_flag,Neg_flag
);

always@(*)
begin

case(ALUcontrol)
4'b0000:sol=A+B;
4'b0001:sol=A-B;
4'b0010:sol=A&B;
4'b0011:sol=A|B;
4'b0100:sol=A^B;
4'b0101:sol=A<B;
4'b0110:sol=A>>>B;
4'b0111:sol=A>>B;
default:sol=0;

endcase
zero_flag = (sol == 32'b00000000_00000000_00000000_00000000)?1:0;
Neg_flag = (sol[31]==1)?1:0;
end
endmodule





module ALUREG(

input [31:0] data,
input clk,
output reg [31:0] dataout
);


always@(posedge clk)
begin

dataout<=data;
end

endmodule

module programaddr(input [4:0] PC,input [31:0] exc,output [4:0] jumping);
wire [4:0] w;
assign w= exc[4:0];
assign jumping=w+PC;


endmodule
