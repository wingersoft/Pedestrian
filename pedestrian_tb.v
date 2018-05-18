`timescale  10ns/1ns

// hg 15-may-2018 - 13:000:45
module pedestrian_tb;
  
initial begin
    $dumpfile("pedestrian_tb.vcd");
    $dumpvars();
    $monitor("%05d0: green=%b, yellow=%b, red=%b, pedgreen=%b, pedred=%b", $time, green, yellow, red, pedgreen, pedred);    
    #180 $finish;
end

reg clk = 0;
always #1 clk = !clk;

wire green;
wire yellow;
wire red;
wire pedgreen;
wire pedred;

//
// for simulation TIMER_SCALE = 1
// for realtime   TIMER_SCALE = 16 000 000 = 1 second.
//

pedestrian #(.TIMER_SCALE(1)) dut (
    .pin3_clk_16mhz(clk), 
    .pin4_green(green), 
    .pin5_yellow(yellow), 
    .pin6_red(red),
    .pin7_ped_green(pedgreen),
    .pin8_ped_red(pedred)
    ); 

endmodule
