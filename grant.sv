module grant #(parameter CHANNELS = 8, parameter WIDTH = 32, parameter weightlimit = 16)
(reset, clk, request, next_gnt, weight, gnt);
input reset, clk;
input [(CHANNELS-1):0] request;
input [(CHANNELS-1):0] next_gnt;
input [(WIDTH-1):0] weight;
output reg [(CHANNELS-1):0] gnt;
reg [(WIDTH-1):0] s_counter;
reg [(CHANNELS-1):0] s_request;
reg [(WIDTH-1):0] s_weight;
localparam size = 4;
reg [(size-1):0] state;
localparam RESET = 'b0001;
localparam GRANT_PROCESS = 'b0010;
localparam COUNT = 'b0100;
localparam GETWEIGHT = 'b1000;

always@(posedge clk, posedge reset)
begin
if(reset == 1'b1)
s_request=0;
else
s_request=request;
end

always@(posedge clk, posedge reset)
begin
if(reset == 1'b1)
begin
 state=0;
end
else
begin
case(state)
GRANT_PROCESS:
begin
if(gnt !=0)
state= GETWEIGHT;
else 
state= state;
end
GETWEIGHT:
begin 
state = COUNT;
end
COUNT:
begin
if(s_counter >= s_weight)
state = GRANT_PROCESS;
else if (s_counter >= weightlimit)
state = GRANT_PROCESS;
else
state = state;
end
default:
begin
state = GRANT_PROCESS;
end
endcase
end
end

always@(posedge clk, posedge reset)
begin
if(reset == 1'b1)
begin
gnt = 0;
s_counter=0;
s_weight=0;
end
else
case(state)
RESET: 
begin
gnt =0;
s_counter=0;
end
GRANT_PROCESS:
begin
gnt = request & next_gnt & (~next_gnt +1);
s_counter=2;
end
GETWEIGHT:
begin
s_weight = weight;
end
COUNT:
begin
s_counter=s_counter+1;
gnt=gnt;
end
default:
begin 
gnt= gnt;
s_counter = s_counter;
end
endcase
end
endmodule


