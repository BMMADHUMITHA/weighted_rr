module next_grant_precalculate #(parameter CHANNELS = 8)
( rst, clk, req, gnt, next_gnt);
input rst,clk;
input [(CHANNELS-1):0] req;
input [(CHANNELS-1):0] gnt;
output reg [(CHANNELS-1):0] next_gnt;
reg [(CHANNELS-1):0] mask;
localparam size=2;
reg [(size-1):0] state;
localparam RESET = 'b01;
localparam NEXT_GRANT = 'b10;

always@(posedge clk, posedge rst)
begin
if(rst == 1'b1)
begin
state = RESET;
end
else
case(state)
RESET:
begin
state = NEXT_GRANT;
end
NEXT_GRANT:
begin
state = state;
end
default:
begin
state = RESET;
end
endcase
end

always@(posedge clk, posedge rst)
begin
if(rst == 1'b1)
begin
next_gnt = 0;
mask =0;
end
else
case(state)
RESET:
begin
next_gnt = 0;
mask = ~0;
end
NEXT_GRANT: 
begin
mask = ~{gnt[CHANNELS-2:0], gnt[CHANNELS-1]}+1;
if(mask ==0)
mask=~0;
else
mask = mask;
next_gnt = req & mask;
if((next_gnt == 0) && (req !=0))
next_gnt = req;
end
default:
begin
mask = mask;
next_gnt = next_gnt;
end 
endcase
end
endmodule

