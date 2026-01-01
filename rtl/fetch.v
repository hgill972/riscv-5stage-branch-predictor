
module programcounter(
    input reset,
    input select,
    input [4:0] jumpingaddress,
    output [4:0] nextaddress,
    input stall,
    input clk,
    output reg [4:0] currentaddress
);
reg [4:0] counter;
always @(posedge clk or posedge reset) begin
    if (reset) begin
        counter = 0;
    end else if (!stall) begin

            counter <= nextaddress;
        
    end
end
always@(counter or select)
begin
if(select)
  currentaddress<=jumpingaddress;
else  
  currentaddress<=counter;

end

assign nextaddress[4:0]= (currentaddress[4:0] + 1) ;

endmodule


module progrmemory(
    input [4:0] address,
    input reset,
    output reg [31:0] data
);
    reg [31:0] programline [0:15];


    initial begin
    programline[0] = 32'h05200093; // addi x1, x0, 82
    programline[1] = 32'h04d00113; // addi x2, x0, 77
    programline[2] = 32'h002081b3; // add  x3, x1, x2
    programline[3] = 32'h00118233; // add  x4, x3, x1
    programline[4] = 32'h0000006f; // jal  x0, 0  (halt)

    end

    always @(*) begin
        if (reset)
            data = 32'h00000013; // NOP during reset
        else
            data = programline[address];
    end
endmodule








module instructionreg(input [4:0] currentaddin,nxtaddin,input [31:0] datain,input stall,input clk,input reset,output reg [31:0] dataout,output reg [4:0] currentadd,nxtadd);

always@(posedge clk or posedge reset)
begin
 if(reset)
  begin
   dataout<=32'bxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx;
	
  end
 else if(!stall)
  begin
   dataout<=datain;
	currentadd<=currentaddin;
	nxtadd<=nxtaddin;
  end
end
endmodule


module instructionfetch(
    input stall,
    input reset,
    input clk,
    input [4:0] branching,jumping,
    output [31:0] dataout,
    input  branch,jump,
	 input clr,
	 output [4:0] nextaddressoutput,
	output  [4:0] addressoutput,
	output  [31:0] datain,
	output [4:0] address
	 
);
   
   //output  [31:0] datain
	wire [4:0] nextaddress,addressskip;
	wire decidejump;
	// ---- ADD THIS ----
    wire signed [12:0] b_imm;
    wire signed [4:0]  branch_offset;
    
    // Correct RISC-V B-type immediate extraction
    assign b_imm = {
        dataout[31],     // imm[12]
        dataout[7],      // imm[11]
        dataout[30:25],  // imm[10:5]
        dataout[11:8],   // imm[4:1]
        1'b0
    };
    
    // Convert byte offset to word offset (PC is word-based)
    assign branch_offset = b_imm >>> 2;
	assign decidejump=branch|| jump;
	//output [4:0] address;
    // Instantiate sub-modules
    /*programadder programadder_inst(
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .branch(branch),
        .jumping(jumping),
        .address(address)
    );*/
	assign addressskip = branch ? (address + branch_offset) : jumping;
	 programcounter    programcounter_inst(.reset(reset),
	                                       .select(decidejump),
														.jumpingaddress(addressskip),
														.nextaddress(nextaddress),
														.stall(stall), 
														.clk(clk),
														.currentaddress(address));

    progrmemory progrmemory_inst(
        .address(address),
        .reset(reset),
        .data(datain)
    );

    instructionreg instructionreg_inst(
	     .currentaddin(address),
		  .nxtaddin(nextaddress),
        .datain(datain),
		  .stall(stall), 
        .clk(clk),
        .reset(clr),
        .dataout(dataout),
		  .currentadd(addressoutput),
		  .nxtadd(nextaddressoutput)
    );

endmodule
