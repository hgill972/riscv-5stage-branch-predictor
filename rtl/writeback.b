module storeStage(
input clk,
input reset,
input RegWrite,
input [1:0] ResultSrc, // Control unit inputs
input MemWrite,
input [4:0] Rdm,nxtadd,
input [31:0] ALUResultm,regdata,	 
input [31:0] immext,
output  [4:0]nxtaddout,Rdw,
//output  [31:0] ALUResultw,	 
output  RegWritew,
output  [1:0] ResultSrcw, // Control unit inputs
//output  MemWritew,
output [31:0] ResultW

);
wire [31:0]  readDataw;
wire MemWritew;
wire [31:0] ALUResultw;






/////////////////////////////////////
wire readData;
wire [31:0] immextw;
 DataMemory data_memory_inst (
        .clk(clk),                // Connect your clock input
        .reset(reset),            // Connect your reset input
        .addr(ALUResultm),              // Connect your memory address input
        .writeData(regdata),    // Connect your data to be written to memory
        .memWrite(MemWrite),      // Connect your write enable signal
        .readData(readData)       // Connect your data read from memory
    );
	 
	 
	 storeStagePipelineReg store_stage_pipeline_reg_inst (
        .clk(clk),                  // Connect your clock input
        .RegWrite(RegWrite),        // Connect your RegWrite input
        .ResultSrc(ResultSrc),      // Connect your ResultSrc input
        .MemWrite(MemWrite),        // Connect your MemWrite input
        .Rdm(Rdm),                  // Connect your Rdm input
        .nxtadd(nxtadd),            // Connect your nxtadd input
        .ALUResultm(ALUResultm),    // Connect your ALUResultm input
		  .readData(readData),
		  .immextm(immext),// Connect your regdata input
        .nxtaddout(nxtaddout),      // Connect your nxtaddout output
        .Rdw(Rdw),                  // Connect your Rdw output
        .ALUResultw(ALUResultw),    // Connect your ALUResultw output
        .RegWritew(RegWritew),      // Connect your RegWritew output
        .ResultSrcw(ResultSrcw),    // Connect your ResultSrcw output
        .MemWritew(MemWritew),
		  .readDataw(readDataw),
		  .immextw(immextw)// Connect your MemWritew output
    );

	 mux3choito1 mux1(.A(ALUResultw),
	                  .B (readDataw),
	                 .C(nxtaddout),
						  .D(immextw),
	                  .choice(ResultSrcw),
	                  .data(ResultW));
endmodule
module mux3choito1(
    input [31:0] A,
    input [31:0] B,
   input [4:0] C,
	input [31:0] D,
    input [1:0] choice,
    output reg [31:0] data
);

always @(*)
begin
    case (choice)
        2'b00: data = A;
        2'b01: data = B;
        2'b10:data = {27'd0, C}; 
		  2'b11:data=D;
		 
    endcase
end

endmodule

module DataMemory(
    input clk,            // Clock input
    input reset,          // Reset input
    input [31:0] addr,    // Memory address input
    input [31:0] writeData, // Data to be written to memory
    input memWrite,       // Write enable signal
    output [31:0] readData // Data read from memory
);

// Define memory size and depth
parameter MEM_DEPTH = 32; // Can be changed depending on our requiremnets
parameter MEM_WIDTH = 32;  
integer i;

// Memory array declaration
reg [31:0] memory [31:0];

// Read and write operations
always @(posedge clk or posedge reset ) begin
    if (reset) begin
        for ( i = 0; i < 32; i = i + 1) begin
            memory[i] = 0;
        end
    end 
	 else if (memWrite ==1)
        begin
            memory[addr] = writeData;
       end
	else
        	 memory[addr] = memory[addr] ;
		  
    
end
assign readData = memory[addr];
endmodule





module storeStagePipelineReg(
input clk,
input RegWrite,
input [1:0] ResultSrc, // Control unit inputs
input MemWrite,
input [4:0] Rdm,nxtadd,
input [31:0] ALUResultm,regdata,	 
input [31:0]readData,
input [31:0] immextm,
output reg [31:0]nxtaddout,Rdw,
output reg [31:0] ALUResultw,	 
output reg RegWritew,
output reg [1:0] ResultSrcw, // Control unit inputs
output reg MemWritew,
output reg [31:0]readDataw,
 output reg [31:0] immextw
);
always@(posedge clk)
begin
	nxtaddout<=nxtadd;
	Rdw<=Rdm;
	ALUResultw<=ALUResultm;
	RegWritew<= RegWrite;
	ResultSrcw <= ResultSrc;
	MemWritew <= MemWrite;
	readDataw <= readData;
	immextw<=immextm;
end
endmodule
