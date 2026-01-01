module sevensegment (
input [3:0] a,
output reg [6:0] s
);
always @(*) 
case(a)
4'h0:s= 7'b1000000;
4'h1:s= 7'b1111001;
4'h2:s= 7'b0100100;
4'h3:s= 7'b0110000;
4'h4:s= 7'b0011001;
4'h5:s= 7'b0010010;
4'h6:s= 7'b0000010;
4'h7:s= 7'b1111000;
4'h8:s= 7'b0000000;
4'h9:s= 7'b0011000;
4'hA:s= 7'b0001000;
4'hB:s= 7'b0000011;
4'hC:s= 7'b1000110;
4'hD:s= 7'b0100001;
4'hE:s= 7'b0000110;
4'hF:s= 7'b0001110;
default:s=7'b0000000; 
endcase
endmodule
