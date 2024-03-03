module weight_decoder #( parameter WIDTH =32, parameter CHANNELS = 8)
( clk, reset, onehotsel, datain, dataout);
input clk, reset;
input [(CHANNELS-1):0] onehotsel;
input [(CHANNELS*WIDTH)-1:0] datain;
output reg [(WIDTH-1):0] dataout;
genvar gv;
wire [(WIDTH-1):0] array [0:(CHANNELS-1)];
generate
for(gv=0; gv<CHANNELS; gv=gv+1)
begin 
assign array[gv] = datain[((gv+1)*WIDTH)-1: (gv*WIDTH)];
end
endgenerate
function integer decimal;
input [CHANNELS-1:0] onehotip;
integer i;
for(i=0; i<CHANNELS; i=i+1)
if(onehotip[i])
	decimal =i;
endfunction

always@*
begin
#5;
dataout = array[decimal(onehotsel)];
end
endmodule
