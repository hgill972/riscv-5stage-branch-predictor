module RISCV_2(
input clk,
input reset,
//input clr,stall,
output [3:0] data4bitpart1,data4bitpart2,
output [6:0]sout_1,sout_2,
output reg [31:0]ResultW
//output wen,
//output [31:0] solm
//output [3:0] ALUControl

);
 wire [4:0] addressoutput;
    wire [4:0] addressTowhichToBranch;
    wire [31:0] instuctionfetchdata32;
    wire [4:0] addressinsfetchcurrent;
    wire [2:0] count;
    wire branchoperand;
    wire [4:0] currentregbranch, addregbranch;
    wire flag, branchOrOut;
    wire [1:0] ForwardAE, ForwardBE;
    wire [31:0] Aout, Bout;
    wire [31:0] solm;
    wire [31:0] regdatam;
//wire [4:0] addressoutput;
//wire branchOrOut;
wire [31:0] dataout;
wire [3:0] ALUControl;
//wire [31:0] solm;
//reg [31:0]ResultW;
  wire  [31:0] RD1E,RD2E;
wire ALUSrc;
wire [4:0]jumping;
//wire [31:0]dataout;// to be checking
wire branch;
//wire [31:0]dataout;////////////////////////////////////////////////////
//wire [4:0]addressoutput;
wire [4:0]nextaddressoutput;
//wire [4:0]nextaddressoutput;
//wire [4:0]addressoutput;
////////////////////////////////////////////////////////////////
wire [1:0]ResultSrc;
wire MemWrite;
//wire ALUSrc;
wire RegWrite;
wire Jump;
wire [1:0]ImmSrc;
//wire [2:0] ALUControl;/////////////////////////////////////////
//wire [31:0] RD1E;
//wire [31:0] RD2E;
wire [31:0] immext;
//wire branchout;
wire [4:0] currentaddressout,nxtaddout,RS1E,RS2E,RDE;
wire [31:0] Dwrite;
wire wen;
//////////////////////////////////////////////////////////////////
wire branchchoice;
wire regwitem;
wire memwritem;
wire [1:0] resultsrcm;
//wire [31:0] solm;
//wire [31:0] regdatam;
wire [4:0] nxtaddoutm,Rdm,jumpingout;
wire zeroFlag;
wire [4:0] Rdw;
//wire [31:0] regdata;
//assign regdata=0;
///////////////
wire [31:0]regdata;
////////////////////
wire [2:0] fun3o;
wire zero_flag, Neg_flag;
//wire flag; // actual flag used for branch after decision
//wire branchoperand; // output of branch predictor
wire w1, w2, w3, w4, w5;
//output [2:0]count;
//output [4:0]addressTowhichToBranch;
//wire branchOrOut;
wire branchReset;
//wire [31:0] instuctionfetchdata32;
//wire [4:0] addressinsfetchcurrent;



//wire [1:0] ForwardAE, ForwardBE;
mux2to1Forbranch m1(zero_flag, Neg_flag, fun3o, flag);

 instructionfetch instructionfetch_inst (
        .stall(0),                  // Connect your stall input
        .reset(reset),                  // Connect your reset input
        .clk(clk),                      // Connect your clk input
        .branching(addressTowhichToBranch),
        .jumping(dataout[24:20]),		  // Connect your jumping input
        .dataout(dataout),              // Connect your dataout output
        .branch(branchOrOut),  
        .jump(jump),		  // Connect your branch input
        .clr(branchReset),                      // Connect your clr input
        .nextaddressoutput(nextaddressoutput),    // Connect your nextaddressoutput output
        .addressoutput(addressoutput),  // Connect your addressoutput output
		  .datain(instuctionfetchdata32),
		  .address(addressinsfetchcurrent)
    );
	 
	 
	 instructiondecode instructiondecode_inst ( // Decode stage
        .clk(clk),  
        .clrebranch(branchReset|reset),		  // Connect your clock input
        .reset(reset),              // Connect your reset input
        .stall(0),              // Connect your stall input
        .ins(dataout),                  // Connect your instruction input
        .currentaddress(addressoutput),  // Connect your currentaddress input
        .nxtadd(nextaddressoutput),            // Connect your nxtadd input
        .regadd(Rdw),            // Connect your regadd input
        .wen(wen), 
.Dwrite(Dwrite),		  // Connect your wen input ///////////////////// TO BE DONE
        .ResultSrc(ResultSrc),      // Connect your ResultSrc output
        .MemWrite(MemWrite),        // Connect your MemWrite output
        .ALUSrc(ALUSrc),            // Connect your ALUSrc output
        .RegWrite(RegWrite),        // Connect your RegWrite output
        .Jump(Jump),                // Connect your Jump output
        .ImmSrc(ImmSrc),            // Connect your ImmSrc output
        .ALUControl(ALUControl),    // Connect your ALUControl output
        .RD1E(RD1E),                // Connect your RD1E output
        .RD2E(RD2E),                // Connect your RD2E output
        .immext(immext),            // Connect your immext output
        .branch(branchout),            // Connect your branch output
        .currentaddressout(currentaddressout),  // Connect your currentaddressout output
        .nxtaddout(nxtaddout),      // Connect your nxtaddout output
        .RS1E(RS1E),                // Connect your RS1E output
        .RS2E(RS2E),                // Connect your RS2E output
        .RDE(RDE),
		  .fun3o(fun3o)
		  // Connect your RDE output
    );

	  execute execute_inst ( // Execute stage
        .RegWrite(RegWrite),            // Connect your RegWrite input
        .ResultSrc(ResultSrc),          // Connect your ResultSrc input
        .MemWrite(MemWrite),            // Connect your MemWrite input
        .Jump(Jump),                    // Connect your Jump input
        .branch(branchout),                // Connect your branch input
        .ALUControl(ALUControl),        // Connect your ALUControl input
        .ALUSrc(ALUSrc),                // Connect your ALUSrc input
        .RD1E(RD1E),                    // Connect your RD1E input
        .RD2E(RD2E),                    // Connect your RD2E input
        .immext(immext),                // Connect your immext input
        .currentaddress(currentaddressout),// Connect your currentaddress input
        .nxtadd(nxtaddout),                // Connect your nxtadd input ///////////////// Needs checking
        .Rde(RDE),                      // Connect your Rde input
       // .regdata(32'b00000000000000000),              // Connect your regdata input   // dont need may check in future
       
		  .clk(clk), .reset(branchReset|reset),                     // Connect your clk input
        .branchchoice(branchchoice),    // Connect your branchchoice output /////////////// TO BE DONE
        .regwitem(regwitem),            // Connect your regwitem output     ////////////////// TO BE DONE
        .memwritem(memwritem),          // Connect your memwritem output
        .resultsrcm(resultsrcm),        // Connect your resultsrcm output
        .solm(solm),                    // Connect your solm output
        .regdatam(regdatam),            // Connect your regdatam output
        .nxtaddoutm(nxtaddoutm),        // Connect your nxtaddoutm output
        .Rdm(Rdm),                      // Connect your Rdm output
        .jumping(jumpingout),
         .regdata(regdata)	,	  // Connect your jumping output
        .zero_flag(zero_flag),	  // Connect your zeroFlag output
		  .Neg_flag(Neg_flag),
		  .ForwardAE(ForwardAE),
		  .ForwardBE(ForwardBE),
		  .Memoeyregvalue(solm),
		  .Writeregvalue(Dwrite),
		  .Bout(Bout),
		  .Aout(Aout)
    );
	 


	 storeStage storeStage_inst ( // Store stage
        .clk(clk),                  // Connect your clk input
        .reset(reset),              // Connect your reset input
        .RegWrite(regwitem),        // Connect your RegWrite input
        .ResultSrc(resultsrcm),      // Connect your ResultSrc input
        .MemWrite(memwritem),        // Connect your MemWrite input
        .Rdm(Rdm),                  // Connect your Rdm input
        .nxtadd(nxtaddoutm),            // Connect your nxtadd input
        .ALUResultm(solm),    // Connect your ALUResultm input
        .regdata(regdatam),
        .immext(regdata),		  // Connect your regdata input
        .nxtaddout(nxtaddoutw),      // Connect your nxtaddout output
        .Rdw(Rdw),                  // Connect your Rdw output
        //.ALUResultw(ALUResultw),    // Connect your ALUResultw output
        .RegWritew(wen),      // Connect your RegWritew output
        //.ResultSrcw(ResultSrcw),    // Connect your ResultSrcw output
        //.MemWritew(MemWritew),      // Connect your MemWritew output
        .ResultW(Dwrite)        // Connect your ResultW output
        //.readDataw(readDataw)       // Connect your readDataw output
    );
	 
	 branchpredictor b1(.ins(dataout[6:0]),
		.clk(clk),
		.currentadd(addressoutput),
		.additionadd(dataout[11:7]),
		.branch(branchchoice),
		.flag(flag),
		// outputs
		.reset(branchReset),
		.branchop(branchoperand),
		.add(addressTowhichToBranch),
		.w1(w1),.w2(w2),.w3(w2),.w4(w4),.w5(w5),
		.count(count),
		.currentreg(currentregbranch),
		.addreg(addregbranch)
		
		);
		   hazardunit uut (
        .Rs1E(RS1E),
        .Rs2E(RS2E),
        .RdE(RDE),
        .RdM(Rdm),
        .RdW(Rdw),
        .branch(branchout),
        .RegWriteW(RegWrite),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE)
    );
	 or3gate   grs(branchReset, Jump,branchoperand,branchOrOut);
	 always@(posedge clk)
	 begin
	  ResultW=Dwrite;
	 end
assign data4bitpart1=RD1E[3:0];
assign data4bitpart2=RD2E[3:0];
sevensegment sg(ResultW[3:0], sout_1[6:0]);
sevensegment sg_2(ResultW[7:4], sout_2[6:0]);
endmodule


module mux2to1Forbranch(
input A, // Zero_flag
input B, // Neg_flag
input [2:0]choice,

output reg data
);
always @(*)
begin
    if ((choice==3'b000))
        data = A;
    else if((choice==3'b001))
        data = ~A;
	 else if((choice==3'b010))
        data = B; 
	 else if((choice==3'b011))
        data = ~B; 
	else
       data=data	;
end

endmodule
