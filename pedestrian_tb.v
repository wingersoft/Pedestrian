`timescale  10ns/1ns
`default_nettype none

//
// hg 20-sep-2018 - 10:00
//

module pedestrian_tb;
  
initial begin
    $dumpfile("pedestrian_tb.vcd");
    $dumpvars();
    $monitor("%05d0: green=%b, yellow=%b, red=%b, pedgreen=%b, pedred=%b",
             $time, w_green, w_yellow, w_red, w_pedgreen, w_pedred);    
    #220 $finish;
end

// Clock generation
reg r_clk = 0;
always #1 r_clk = !r_clk;

// Outputs for simulation
wire w_green;
wire w_yellow;
wire w_red;
wire w_pedgreen;
wire w_pedred;

//
// for simulation TIMER_SCALE = 1
// for realtime   TIMER_SCALE = 16 000 000 = 1 second.
//

pedestrian #(.TIMER_SCALE(1)) dut (
    .i_pin3_clk_16mhz(r_clk), 
    .o_pin4_green(w_green), 
    .o_pin5_yellow(w_yellow), 
    .o_pin6_red(w_red),
    .o_pin7_ped_green(w_pedgreen),
    .o_pin8_ped_red(w_pedred)
    ); 

endmodule

