`timescale  10ns/1ns
`default_nettype none

//
// Traffic Light controller demo 18-may-2018 - 10:45
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
               GREEN      = 3'd1,
               YELLOW     = 3'd2,
               RED        = 3'd3,
               PEDGREEN   = 3'd4,
               PEDRED     = 3'd5;
     
    //
    // define registers
    //
    reg [STATE_SIZE - 1:0] state_d, state_q = 0;
    // timer max 60 seconds
    reg [29:0] timer_d, timer_q = 0;
    reg red_d, red_q = 0;
    reg yellow_d, yellow_q = 0;      
    reg green_d, green_q  = 0;
    reg ped_green_d, ped_green_q = 0;
    reg ped_red_d, ped_red_q = 0;
    
    //
    // connect outputs to d-registers
    //
    assign pin4_green = green_q;
    assign pin5_yellow = yellow_q;
    assign pin6_red = red_q;
    assign pin7_ped_green = ped_green_q;
    assign pin8_ped_red = ped_red_q;

    //
    // combinational part
    //
    always @* begin
        red_d = red_q;
        yellow_d = yellow_q;
        green_d = green_q;
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
                state_d = GREEN;
            end
            // Green light - 10 seconds
            GREEN: begin
                red_d = 1'b0;
                green_d = 1'b1;
                if (timer_q == 30'd0) begin
                    timer_d = 30'd5 * TIMER_SCALE;
                    state_d = YELLOW;
                end
            end
            // Yellow light - 5 seconds
            YELLOW: begin
                green_d = 1'b0;
                yellow_d = 1'b1;
                if (timer_q == 30'd0) begin
                    timer_d = 30'd5 * TIMER_SCALE;
                    state_d = RED;
                end
            end
            // Red light - 15 seconds
            RED: begin
                yellow_d = 1'b0;
                red_d = 1'b1;
                if (timer_q == 30'd0) begin
                    timer_d = 30'd10 * TIMER_SCALE;
                    state_d = PEDGREEN;
                end
            end
            // Ped green light - 10 seconds
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
                    state_d = GREEN;
                end
            end
            default: state_d = IDLE;
        endcase
    end
    
    //
    // sequential part
    //
    always @ (posedge pin3_clk_16mhz) begin
        green_q <= green_d;
        yellow_q <= yellow_d;
        red_q <= red_d;
        ped_green_q <= ped_green_d;
        ped_red_q <= ped_red_d;
        timer_q = timer_d;
        state_q <= state_d;
    end
     
endmodule

