module or3gate(input a,b,c,output reg d);
always@(*)
begin
if((a==1) || (b==1) || (c==1))
begin
d=1;
end
else
begin
d=0;
end
end
endmodule
module branchpredictor(input [6:0] ins,
input clk,
input [4:0]currentadd,
additionadd,
input branch,
input flag,
output reg reset,
output reg branchop,
output  [4:0] add,
output w1,w2,w3,w4,w5,
output reg  [2:0] count,
output reg  [ 4:0] currentreg,addreg);
reg [6:0] instemp;
reg  branching [6:0];
//reg  [2:0] count;
 //output reg  [ 4:0] currentreg,addreg;
initial
begin
reset=0;
branching[0]=1;
branching[1]=1;
branching[2]=1;
branching[3]=1;
branching[4]=1;
branching[5]=1;
branching[6]=1;
end
always@(negedge clk)
begin
if(ins[6:0]!=7'b1100011)
begin
instemp=ins;
branchop=0;
end
else if(ins[6:0]==7'b1100011)
begin
currentreg=currentadd+additionadd;
addreg=currentadd+1;
case(instemp)

7'b0000011:  begin//lw
branchop=branching[0];
count=0;
end
7'b0010011 :  begin//I type
branchop=branching[1];
count=1;
end
7'b0100011:  begin//sw
branchop=branching[2];
count=1;
end
7'b0110011:  begin//R type
branchop=branching[3];
count=2;
end
7'b0110111 :  begin//U type
branchop=branching[4];
count=3;
end
7'b1101111:  begin //jal
branchop=branching[5];
count=4;

end
default:
begin
branchop=0;
count=6;
end
endcase

end

/*

if (branch) begin
    if (flag != branching[count]) begin
        reset = 1;
        branching[count] = ~branching[count];
    end else begin
        reset = 0;
        // branching[count] remains unchanged
    end
end 
else begin
    reset = 0;
    // branching[count] remains unchanged
end
*/
//add=(branching[count]==1)?(currentreg):(addreg);
 end

always@(negedge clk)
begin
if(branch)
begin
if(flag!=branching[count])
begin
branching[count]<=~branching[count];
reset<=1;

end
else
begin

reset<=0;
end
end
else
begin
reset<=0;
end

end

 assign add=(branching[count])?(currentreg):(addreg);
assign w1=branching[0];
assign w2=branching[1];
assign w3=branching[2];
assign w4=branching[3];
assign w5=branching[4];


endmodule
