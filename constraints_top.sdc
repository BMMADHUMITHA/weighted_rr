
set EXTCLK "clk" ;
set_units -time 1.0ns ;
set EXTCLK_PERIOD 20.0;
create_clock -name "$EXTCLK" -period "$EXTCLK_PERIOD" -waveform "0
[expr $EXTCLK_PERIOD/2]" [get_ports clk]

set SKEW 0.200
set_clock_uncertainty $SKEW [get_clocks $EXTCLK]

set SRLATENCY 0.80
set SFLATENCY 0.75

set MINRISE  0.20
set MAXRISE  0.25
set MINFALL  0.15
set MAXFALL  0.10
set_clock_transition -rise -min $MINRISE [get_clocks $EXTCLK]
set_clock_transition -rise -max $MAXRISE [get_clocks $EXTCLK]
set_clock_transition -fall -min $MINFALL [get_clocks $EXTCLK]
set_clock_transition -fall -max $MAXFALL [get_clocks $EXTCLK]

set INPUT_DELAY 0.5
set OUTPUT_DELAY 0.5

set INPUT_DELAY 0.5
set_input_delay -clock [get_clocks $EXTCLK] -add_delay 0.3 [get_ports reset]
set INPUT_DELAY 0.5
set_input_delay -clock [get_clocks $EXTCLK] -add_delay 0.3 [get_ports request]
set INPUT_DELAY 0.5
set_input_delay -clock [get_clocks $EXTCLK] -add_delay 0.3 [get_ports weight]



set OUTPUT_DELAY 0.5
set_output_delay -clock [get_clocks $EXTCLK] -add_delay 0.3 [get_ports grant1]
