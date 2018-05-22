`timescale  10ns/1ns
`default_nettype none

//
// Traffic Light controller demo 22-may-2018 - 11:30
//
module pedestrian 
#(parameter TIMER_SCALE = 16000000)
(
    input pin3_clk_16mhz,
    output pin4_green,
    output pin5_yellow,
    output pin6_red,
    output pin7_ped_green,
    output pin8_ped_red
);
    
    //
    // state machine states
    //
    localparam STATE_SIZE = 3;
    localparam IDLE       = 3'd0,
               ROADGREEN  = 3'd1,
               ROADYELLOW = 3'd2,
               ROADRED    = 3'd3,
               PEDGREEN   = 3'd4,
               PEDRED     = 3'd5;
     
    //
    // define registers
    //
    reg [STATE_SIZE - 1:0] state_d, state_q = 0;
    // timer max 60 seconds
    reg [29:0] timer_d, timer_q = 0;
    // lights green, yellow, red
    reg road_green_d, road_green_q = 0;
    reg road_yellow_d, road_yellow_q = 0;      
    reg road_red_d, road_red_q  = 0;
    // lights pedestrian green and red
    reg ped_green_d, ped_green_q = 0;
    reg ped_red_d, ped_red_q = 0;
    
    //
    // connect outputs to d-registers
    //
    assign pin4_green = road_green_q;
    assign pin5_yellow = road_yellow_q;
    assign pin6_red = road_red_q;
    assign pin7_ped_green = ped_green_q;
    assign pin8_ped_red = ped_red_q;

    //
    // combinational part
    //
    always @* begin
        road_red_d = road_red_q;
        road_yellow_d = road_yellow_q;
        road_green_d = road_green_q;
        ped_green_d = ped_green_q;
        ped_red_d = ped_red_q;
        timer_d = timer_q;
        state_d = state_q;
        if (timer_q != 30'd0)
            timer_d = timer_q - 30'b1;
        case (state_q)
            IDLE: begin
                ped_red_d = 1'b1;
                ped_green_d = 1'b0;
                timer_d = 30'd10 * TIMER_SCALE;
                state_d = ROADGREEN;
            end
            // Green light - 10 seconds
            ROADGREEN: begin
                road_red_d = 1'b0;
                road_green_d = 1'b1;
                if (timer_q == 30'd0) begin
                    timer_d = 30'd5 * TIMER_SCALE;
                    state_d = ROADYELLOW;
                end
            end
            // Yellow light - 5 seconds
            ROADYELLOW: begin
                road_green_d = 1'b0;
                road_yellow_d = 1'b1;
                if (timer_q == 30'd0) begin
                    timer_d = 30'd5 * TIMER_SCALE;
                    state_d = ROADRED;
                end
            end
            // Red light - 15 seconds
            ROADRED: begin
                road_yellow_d = 1'b0;
                road_red_d = 1'b1;
                if (timer_q == 30'd0) begin
                    timer_d = 30'd10 * TIMER_SCALE;
                    state_d = PEDGREEN;
                end
            end
            // Ped green light
            PEDGREEN: begin
                ped_red_d = 1'b0;
                ped_green_d = 1'b1;
                if (timer_q == 30'd0) begin
                    timer_d = 30'd5 * TIMER_SCALE;
                    state_d = PEDRED;
                end
            end
            // Ped red light
            PEDRED: begin
                ped_green_d = 1'b0;
                ped_red_d = 1'b1;
                if (timer_q == 30'd0) begin
                    timer_d = 30'd10 * TIMER_SCALE;
                    state_d = ROADGREEN;
                end
            end
            default: state_d = IDLE;
        endcase
    end
    
    //
    // sequential part
    //
    always @ (posedge pin3_clk_16mhz) begin
        road_green_q <= road_green_d;
        road_yellow_q <= road_yellow_d;
        road_red_q <= road_red_d;
        ped_green_q <= ped_green_d;
        ped_red_q <= ped_red_d;
        timer_q <= timer_d;
        state_q <= state_d;
    end
     
endmodule

