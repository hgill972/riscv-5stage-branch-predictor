module hazardunit( 
    input [4:0] Rs1E, Rs2E,
    input [4:0] RdE, RdM, RdW,
    input branch, RegWriteW,
    output reg [1:0] ForwardAE, ForwardBE
 
);

reg condition;
always @(*) 
begin
    ForwardAE = 2'b00;
    ForwardBE = 2'b00;
	 condition=RegWriteW|| branch;
    if ((Rs1E == RdM) & (condition) & (Rs1E != 0)) // higher priority - most recent
        ForwardAE = 2'b01; 
    else if ((Rs1E == RdW) & (condition) & (Rs1E != 0))
        ForwardAE = 2'b10; // for forwarding WriteBack Stage Result

    if ((Rs2E == RdM) & (condition) & (Rs2E != 0))
        ForwardBE = 2'b01; // for forwarding ALU Result in Memory Stage
    else if ((Rs2E == RdW) & condition & (Rs2E != 0))
        ForwardBE = 2'b10; // for forwarding WriteBack Stage Result
end


endmodule
