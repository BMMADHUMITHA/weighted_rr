
module testbench;

  // Parameters
  localparam CHANNELS = 8;
   localparam  WIDTH = 32;
   localparam  weightlimit = 16;
  
  // Signals
  reg reset;
  reg clk;
  reg [(CHANNELS-1):0] request;
  reg [(CHANNELS*WIDTH)-1:0] weight;
  wire [(CHANNELS-1):0] grant1;
reg[(CHANNELS-1):0] s_onehotsel;
  // Instantiate the arbiter module
  weighted_rr uut (
    .reset(reset),
    .clk(clk),
    .request(request),
    .weight(weight),
    .grant1(grant1)
  );
always #100 clk=~clk;

initial begin

clk <= 0;
reset <=1;

request <= 8'b00000000;
s_onehotsel <=8'b00000001;





#50 reset=0; 
end
always #25 @(posedge clk) request = $random;
always #150 weight <= $random;

endmodule

