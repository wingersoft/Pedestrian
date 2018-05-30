`timescale  10ns/1ns
`default_nettype none

//
// Traffic Light controller demo 30-may-2018 - 11:50
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
    localparam RESET      = 3'd0,
               LAMPTEST   = 3'd1,
               ROADGREEN  = 3'd2,
               ROADYELLOW = 3'd3,
               ROADRED    = 3'd4,
               PEDGREEN   = 3'd5,
               PEDRED     = 3'd6;
     
    // state register
    reg [2:0] state_d, state_q = RESET;
    // timer max 60 seconds
    reg [29:0] timer_d, timer_q = 0;
    //
    // light-reg[0] = road_green
    // light-reg[1] = road_yellow
    // light-reg[2] = road_red
    // light_reg[3] = ped_green
    // light-reg[4] = ped_red
    //
    reg [4:0] light_reg_d, light_reg_q = 0;
    // conect outputs to light_reg
    assign pin4_green = light_reg_q[0];
    assign pin5_yellow = light_reg_q[1];
    assign pin6_red = light_reg_q[2];
    assign pin7_ped_green = light_reg_q[3];
    assign pin8_ped_red = light_reg_q[4];

    //
    // combinational part
    //
    always @* begin
        light_reg_d = light_reg_q;
        timer_d = timer_q;
        state_d = state_q;
        if (timer_q != 30'd0)
            timer_d = timer_q - 30'b1;
        case (state_q)
            RESET: begin
                light_reg_d = 5'b00000;
                timer_d = 30'd10 * TIMER_SCALE;
                state_d = LAMPTEST;
            end
            // All lamps on
            LAMPTEST: begin
               light_reg_d = 5'b11111;
               if (timer_q == 30'd0) begin
                   timer_d = 30'd10 * TIMER_SCALE;
                   state_d = ROADGREEN;
               end
            end
            // Green light - 10 seconds
            ROADGREEN: begin
                light_reg_d = 5'b10001;
                if (timer_q == 30'd0) begin
                    timer_d = 30'd5 * TIMER_SCALE;
                    state_d = ROADYELLOW;
                end
            end
            // Yellow light - 5 seconds
            ROADYELLOW: begin
                light_reg_d = 5'b10010;
                if (timer_q == 30'd0) begin
                    timer_d = 30'd5 * TIMER_SCALE;
                    state_d = ROADRED;
                end
            end
            // Red light - 15 seconds
            ROADRED: begin
                light_reg_d = 5'b10100;
                if (timer_q == 30'd0) begin
                    timer_d = 30'd10 * TIMER_SCALE;
                    state_d = PEDGREEN;
                end
            end
            // Ped green light
            PEDGREEN: begin
                light_reg_d = 5'b01100;
                if (timer_q == 30'd0) begin
                    timer_d = 30'd5 * TIMER_SCALE;
                    state_d = PEDRED;
                end
            end
            // Ped red light
            PEDRED: begin
                light_reg_d = 5'b10100;
                if (timer_q == 30'd0) begin
                    timer_d = 30'd10 * TIMER_SCALE;
                    state_d = ROADGREEN;
                end
            end
            default: state_d = RESET;
        endcase
    end
    
    //
    // sequential part
    //
    always @ (posedge pin3_clk_16mhz) begin
        light_reg_q <= light_reg_d;
        timer_q <= timer_d;
        state_q <= state_d;
    end
     
endmodule

