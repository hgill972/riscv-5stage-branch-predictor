

module GPR(clk,reset,Radd1,Radd2,RaddD,wen,Dwrite,Rs1,Rs2);
input clk,reset,wen;  // 1-bit inputs
input [4:0]Radd1,Radd2,RaddD; // 5-bits regiter input addresses
input [31:0]Dwrite;

output  [31:0] Rs1,Rs2;
// Dwrite is the output of the ALU to be written in the destination register.
reg [31:0]Register[31:0]; // 32-bit regiters, each 32-bbit wide
//assign Rs1 = Register[Radd1];
//assign Rs2 = Register[Radd2];
integer i;
always@(negedge clk)
begin
if(reset)
  begin
  for(i=0;i<32;i=i+1)
  Register[i]=0;
  end
 else if(wen) 
     begin
	  Register[RaddD] = Dwrite;
	  end
 else
      Register[RaddD]=Register[RaddD]; 
end
assign Rs1 = Register[Radd1];
assign  Rs2 = Register[Radd2];
endmodule



module maindec(
    input [6:0] op,
    output [1:0] ResultSrc,
    output MemWrite,
    output Branch,
    output ALUSrc,
    output RegWrite,
    output Jump,
    output [1:0] ImmSrc,
    output [1:0] ALUOp
);

    reg [10:0] controls;

    assign {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, ALUOp, Jump} = controls;

    always @*
        case(op)
            // RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_Branch_ALUOp_Jump
            7'b0000011: controls = 11'b1_00_1_0_01_0_00_0; // lw
            7'b0100011: controls = 11'b0_01_1_1_01_0_00_0; // sw
            7'b0110011: controls = 11'b1_xx_0_0_00_0_10_0; // R-type
            7'b1100011: controls = 11'b0_xx_0_0_00_1_01_0; // branch
            7'b0010011: controls = 11'b1_10_1_0_00_0_10_0; // I-type ALU
            7'b1101111: controls = 11'b1_00_0_0_10_0_00_1; // jal
				7'b0110111: controls = 11'b1_00_0_0_11_0_xx_0; // ldu
            default: controls = 11'bx_xx_x_x_xx_x_xx_x; // ??? 
        endcase

endmodule

module aludec(
    input opb5,opb4,
    input [2:0] funct3,
    input funct7b5,
    input [1:0] ALUOp,
    output reg [3:0] ALUControl
);
    wire RtypeSub;
    
    assign RtypeSub = funct7b5 & (opb5||opb4); // TRUE for R-type subtract
    
    always @(* )begin
        case(ALUOp)
            2'b00: ALUControl = 4'b0000; // addition
            2'b01: ALUControl = 4'b0001; // subtraction
            default: begin // R-type or I-type ALU
                case(funct3)
                    3'b000: if (RtypeSub)
                                ALUControl = 4'b0001; // sub
                            else
                                ALUControl = 4'b0000; // add, addi
						  3'b100: ALUControl = 4'b0100; //xor,xori		
					     3'b101: if (RtypeSub)
						          ALUControl = 4'b0110;//srai,sra	 
						          else
							       ALUControl = 4'b0111;	//srl,srli 
                    3'b010: ALUControl = 4'b0101; // slt, slti
                    3'b110: ALUControl = 4'b0011; // or, ori
                    3'b111: ALUControl = 4'b0010; // and, andi
                    default: ALUControl = 4'bxxxx; // ???
                endcase
            end
        endcase
    end

endmodule

module controller(
    input [6:0] op,
    input [2:0] funct3,
    input funct7b5,
    output [1:0] ResultSrc,
    output MemWrite,
    //output PCSrc,
    output ALUSrc,
    output RegWrite,
    output Jump,
    output [1:0] ImmSrc,
    output [3:0] ALUControl,
	 output Branch
);

    wire [1:0] ALUOp;
    

    maindec md(op, ResultSrc, MemWrite, Branch, ALUSrc, RegWrite, Jump, ImmSrc, ALUOp);
    aludec ad(op[5],op[4], funct3, funct7b5, ALUOp, ALUControl);
    
   // assign PCSrc = Branch & Zero | Jump;

endmodule


module extend(
    input [31:7] instr,
    input [1:0] immsrc,
    output reg [31:0] immext
);
    always @* begin
        case(immsrc)
            // U-type
            2'b00: immext = {{20{instr[31]}}, instr[31:20]};
            // S-type (stores)
            2'b01: immext = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            // I-type
           2'b10: immext ={{22{instr[31]}}, instr[29:20]};
            // J-type (jal)
          //  2'b11: immext = {{12{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
            default: immext = 32'bx; // undefined
        endcase
    end
endmodule

//look into it again rtl viewer
module instructiondecode(
input clk,clrebranch,
                        input reset,stall,
       input [31:0] ins,
          input [4:0] currentaddress,nxtadd,
			  input [4:0] regadd,
			  input wen,
    //output PCSrc,
	 input [31:0] Dwrite,
	 output [1:0] ResultSrc, // Control unit outputs
    output MemWrite,
    output ALUSrc,
    output RegWrite,
    output Jump,
    output [1:0] ImmSrc,
    output [3:0] ALUControl,
	 output [31:0] RD1E, RD2E, // Register file output
	 output [31:0] immext,
	output branch ,
	output [4:0] currentaddressout,nxtaddout,RS1E,RS2E,RDE,
	output [2:0] fun3o
	 // Extend output
	 );

	 //wire PCSrcinp,
	
	 wire [1:0] ResultSrcinp; // Control unit outputs
    wire MemWriteinp;
    wire ALUSrcinp;
    wire RegWriteinp;
    //wire Jumpinp;
   // wire [1:0] ImmSrcinp,
    wire [3:0] ALUControlinp;
	 wire [4:0]  Rs1ainp,Rs2ainp,Rsadinp;
	 wire [31:0] RD1, RD2; // Register file output
	 wire [31:0] immextinp ;
	  wire branchinp;
	 
	   controller inst_controller (
        .op(ins[6:0]),
        .funct3(ins[14:12]),
        .funct7b5(ins[30]), 
        .ResultSrc(ResultSrcinp),
        .MemWrite(MemWriteinp),
        //.PCSrc(PCSrc),
        .ALUSrc(ALUSrcinp),
        .RegWrite(RegWriteinp),
        .Jump(Jump),
        .ImmSrc(ImmSrc),
        .ALUControl(ALUControlinp),
		.Branch(branchinp)
    );
	 
	 
	GPR m1 (
        .clk(clk),
        .reset(reset),
        .Radd1(ins[19:15]),//
        .Radd2(ins[24:20]),//
        .RaddD(regadd),//
        .wen(wen),//
        .Dwrite(Dwrite),//
        .Rs1(RD1),//
        .Rs2(RD2)//
    );
	 
	 
	 
			extend inst_extend (
        .instr(ins[31:7]),
        .immsrc(ImmSrc),
        .immext(immextinp)
    );
			
 instructionreg2 inst (
        .reset(clrebranch),//
        .clk(clk),//
		  .stall(stall),
        .Rd1(RD1),//
        .Rd2(RD2),//
        .RS1d(ins[19:15]),//
        .RS2d(ins[24:20]),//
        .RDd(ins[11:7]),//
        .ResultSrc(ResultSrcinp),//
        .MemWrite(MemWriteinp),//
        .ALUSrc(ALUSrcinp),//
        .RegWrite(RegWriteinp),//
        //.Jump(Jumpinp),//
        .branch(branchinp),
        .ImmSrc(ImmSrc),
        .ALUControl(ALUControlinp),
        .immExt(immextinp),
        .currentadd(currentaddress),
        .nxtadd(nxtadd),
        .ResultSrcE(ResultSrc),
        .MemWriteE(MemWrite),
        .ALUSrcE(ALUSrc),
        .RegWriteE(RegWrite),
       // .JumpE(Jump),
        .branchE(branch),
        //.ImmSrcE(ImmSrcE),
        .ALUControlE(ALUControl),
        .RD1E(RD1E),
        .RD2E(RD2E),
        .immExtE(immext),
        .RS1E(RS1E),
        .RS2E(RS2E),
        .RDE(RDE),
        .currentaddE(currentaddressout),
        .nxtaddE(nxtaddout),
		  .fun3i(ins[14:12]), ///////////////////////////////////////////////////////changess
		  .fun3o(fun3o)
		  );

		  
	
			
		 
		  

endmodule


module instructionreg2(
    input reset,
	 input clk,
	 input stall,
    input [31:0] Rd1,Rd2,
	 input [4:0] RS1d, RS2d, RDd,
	 input [1:0] ResultSrc, // Control unit outputs
    input MemWrite,
    input ALUSrc,
    input RegWrite,
   // input Jump,
	 input branch,
    input [1:0] ImmSrc,
    input [3:0] ALUControl,
	 input [31:0] immExt,    // Extend output
	 input [4:0] currentadd,nxtadd,


	 
	 output reg [1:0] ResultSrcE, // Control unit outputs
    output reg MemWriteE,
    output reg ALUSrcE,
    output reg RegWriteE,
   // output reg JumpE,
	 output reg branchE,
    output reg  [1:0] ImmSrcE,
    output  reg [3:0] ALUControlE,
	 output reg [31:0] RD1E, RD2E, // Register file output
	 output  reg [31:0] immExtE,    // Extend output

	 
	 output  reg [4:0]  RS1E, RS2E, RDE,
	 
output reg [4:0] currentaddE,nxtaddE,
input [2:0] fun3i,
output reg [2:0] fun3o

);

always@(posedge clk or posedge reset)
begin
 if(reset)
  begin
   ResultSrcE<=0; // Control unit outputs
    MemWriteE<=0;
    ALUSrcE<=0;
    RegWriteE<=0;
   // JumpE<=0;
	 branchE<=0;
     ImmSrcE<=0;
     ALUControlE<=0;
	  RD1E<=0;
	  RD2E<=0; // Register file output
	 immExtE<=0;
	 RS1E<=0; 
	 RS2E<=0; 
	 RDE<=0;
	currentaddE<=0;
	nxtaddE<=0;
	fun3o<=fun3i;
	
  end
 else if(!stall)
  begin
  currentaddE<=currentadd;
  nxtaddE<=nxtadd;
  ResultSrcE<=ResultSrc; // Control unit outputs
  MemWriteE<=MemWrite;
  ALUSrcE<=ALUSrc;
  RegWriteE<=RegWrite;
 // JumpE<=Jump;
  branchE<=branch;
  ImmSrcE<=ImmSrc;
  ALUControlE<=ALUControl;
  RD1E<=Rd1;
  RD2E<=Rd2; // Register file output
  immExtE<=immExt;
  RS1E<=RS1d; 
  RS2E<=RS2d; 
  RDE<=RDd;
  fun3o<=fun3i;
  end
end
endmodule
