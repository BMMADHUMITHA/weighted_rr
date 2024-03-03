module weighted_rr #(parameter CHANNELS = 8, parameter WIDTH = 32, parameter weightlimit = 16)
(reset, clk, request, weight, grant1);
input reset, clk;
input [(CHANNELS-1):0] request;
input [(CHANNELS*WIDTH)-1:0] weight;
output wire [(CHANNELS-1):0] grant1;
wire [(CHANNELS-1):0] s_onehotsel;
wire [(WIDTH-1):0] s_weight;
wire [(CHANNELS-1):0] s_nextGrant;
assign grant1 = s_onehotsel;
weight_decoder #(32,8) wd1 (clk, reset,s_onehotsel, weight, s_weight);
next_grant_precalculate #(8) ngpc (reset,clk,request, s_onehotsel , s_nextGrant);
grant #(8,32,16) g1 (reset,clk, request, s_nextGrant, s_weight, s_onehotsel);

endmodule
