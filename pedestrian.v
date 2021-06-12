`timescale  10ns/1ns
`default_nettype none

//
// Traffic Light controller demo 12-jun-2021 - 14:30
//

module pedestrian 
#(parameter TIMER_SCALE = 16000000)
(
    input i_pin3_clk_16mhz,
    output o_pin4_green,
    output o_pin5_yellow,
    output o_pin6_red,
    output o_pin7_ped_green,
    output o_pin8_ped_red);

    //
    // Time duration constants
    //
    localparam LAMPTESTDURATION   = 30'd1,
               ROADGREENDURATION  = 30'd10,
               ROADYELLOWDURATION = 30'd5,
               ROADREDDURATION    = 30'd10,
               PEDGREENDURATION   = 30'd10,
               PEDREDDURATION     = 30'd10,
               PAUSE              = 30'd1;

    //
    // state machine states
    //
    localparam LAMPTEST   = 3'd0,
               ROADGREEN  = 3'd1,
               ROADYELLOW = 3'd2,
               ROADRED    = 3'd3,
               PEDGREEN   = 3'd4,
               PEDRED     = 3'd5;
     
    // state register
    reg [2:0] r_state, r_state_next = LAMPTEST;

    // timer max 60 seconds
    reg [29:0] r_timer = 0;
    
    //
    // light-reg[0] = road_green
    // light-reg[1] = road_yellow
    // light-reg[2] = road_red
    // light_reg[3] = ped_green
    // light-reg[4] = ped_red
    //
    reg [4:0] r_light;
    
    // connect outputs to r_light
    assign o_pin4_green = r_light[0];
    assign o_pin5_yellow = r_light[1];
    assign o_pin6_red = r_light[2];
    assign o_pin7_ped_green = r_light[3];
    assign o_pin8_ped_red = r_light[4];
   
    //
    // state machine
    //
    always @ (posedge i_pin3_clk_16mhz) begin
        r_state <= r_state_next;
    end
    
    //
    // timer
    //
    always @ (posedge i_pin3_clk_16mhz) begin
        if (r_state != r_state_next)
            r_timer <= 0;
        else
            r_timer <= r_timer + 30'd1;
    end

    //
    // state machine
    //
    always @ (*) begin
        r_state_next = r_state;
        case (r_state)
            // All lamps on
            LAMPTEST: begin
               if (r_timer == LAMPTESTDURATION * TIMER_SCALE)
                   r_state_next = ROADGREEN;
               else
                   r_state_next = LAMPTEST;
            end
            // Road Green light
            ROADGREEN: begin
                if (r_timer == ROADGREENDURATION * TIMER_SCALE)
                    r_state_next = ROADYELLOW;
                else
                    r_state_next = ROADGREEN;
            end
            // Road Yellow light
            ROADYELLOW: begin
                if (r_timer == ROADYELLOWDURATION * TIMER_SCALE)
                    r_state_next = ROADRED;
                else
                    r_state_next = ROADYELLOW;
            end
            // Road light
            ROADRED: begin
                if (r_timer == (PAUSE * 5) * TIMER_SCALE)
                    r_state_next = PEDGREEN;
                else
                    r_state_next = ROADRED;
            end
            // Ped green
            PEDGREEN: begin
                if (r_timer == PEDGREENDURATION * TIMER_SCALE)
                    r_state_next = PEDRED;
                else
                    r_state_next = PEDGREEN;
            end
            // Ped red light
            PEDRED: begin
                if (r_timer == (PAUSE * 5) * TIMER_SCALE)
                    r_state_next = ROADGREEN;
                else
                    r_state_next = PEDRED;
            end
            default: r_state_next = LAMPTEST;
        endcase
    end

    //
    // state machine output
    //
    always @ (*) begin
        case (r_state)
            LAMPTEST:   r_light = 5'b11111; // All lamps on 
            ROADGREEN:  r_light = 5'b10001; // Road green
            ROADYELLOW: r_light = 5'b10010; // Road yellow
            ROADRED:    r_light = 5'b10100; // Road red
            PEDGREEN:   r_light = 5'b01100; // Ped green
            PEDRED:     r_light = 5'b10100; // Ped red
            default:    r_light = 5'b00000; // default all off
        endcase
    end

endmodule
