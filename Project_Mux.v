module mux_dff(CLK,rst,in,out,CE);
parameter  WIDTH=8 ;
parameter sync="SYNC";
parameter sel=0;
input CLK,rst,CE;
input[WIDTH-1:0] in;
output [WIDTH-1:0] out;
reg[WIDTH-1:0] dff_out;
generate
    if(sync=="ASYNC")begin
always @(posedge CLK or posedge rst) begin
if(rst) dff_out<=0;
else if(CE) dff_out<=in;
end
end
else begin
always @(posedge CLK) begin
if(rst) dff_out<=0;
else if(CE) dff_out<=in;
end
end
endgenerate
assign out=(sel==1)? dff_out:in;
endmodule

