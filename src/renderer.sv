`timescale 1ns / 1ps
`default_nettype none

/*

Given data from one block and an XY position,
render that block.

*/
module renderer(
    input wire clk_in,
    input wire rst_in,

    input wire [10:0] x_in,
    input wire [9:0] y_in,

    input wire [11:0] block_x,
    input wire [11:0] block_y,
    input wire [13:0] block_z,
    input wire block_color,
    input wire [2:0] block_direction,
    input wire block_visible,

    input wire [1:0] state,
    input wire [17:0] curr_time,
    input wire [17:0] max_time,
    input wire [11:0] score_in,
    input wire [3:0] health_in,
    input wire [2:0] combo_in,

    input wire [11:0] hand_x_left_bottom,
    input wire [11:0] hand_y_left_bottom,
    input wire [13:0] hand_z_left_bottom,
    input wire [11:0] hand_x_left_top,
    input wire [11:0] hand_y_left_top,
    input wire [13:0] hand_z_left_top,
    input wire [11:0] hand_x_right_bottom,
    input wire [11:0] hand_y_right_bottom,
    input wire [13:0] hand_z_right_bottom,
    input wire [11:0] hand_x_right_top,
    input wire [11:0] hand_y_right_top,
    input wire [13:0] hand_z_right_top,
    input wire [11:0] head_x,
    input wire [11:0] head_y,
    input wire [13:0] head_z,

    output logic [4:0] r_out,
    output logic [5:0] g_out,
    output logic [4:0] b_out
    );

    typedef enum {
        UP, RIGHT, DOWN, LEFT, ANY
    } direction;

    typedef enum {
        BLUE, RED
    } block_color_enum;

    /*
    Given a specific time, need to figure out how to place the blocks on the map
    */

    logic in_region_a; //TL
    logic in_region_b; //BR
    logic in_region_c; //TR
    logic in_region_d; //BL
    logic should_draw_arrow;

    logic [13:0] x_in_padded;
    assign x_in_padded = {3'b0, x_in};
    logic [12:0] y_in_padded;
    assign y_in_padded = {3'b0, y_in};
    logic [14:0] block_x_padded;
    assign block_x_padded = {3'b0, block_x};
    logic [14:0] block_y_padded;
    assign block_y_padded = {3'b0, block_y};

    always_comb begin
        if(block_visible) begin
            in_region_a = $signed(y_in_padded + x_in_padded) < $signed($signed(block_y_padded) + $signed(block_x_padded));
            in_region_b = $signed(y_in_padded + x_in_padded) > $signed($signed(block_y_padded) + $signed(block_x_padded));

            in_region_c = $signed(y_in_padded) < $signed($signed(x_in_padded) + $signed($signed(block_y_padded) - $signed(block_x_padded)));
            in_region_d = $signed(y_in_padded) > $signed($signed(x_in_padded) + $signed($signed(block_y_padded) - $signed(block_x_padded)));

            case(block_direction)
                UP: should_draw_arrow = in_region_a && in_region_c;
                RIGHT: should_draw_arrow = in_region_b && in_region_c;
                DOWN: should_draw_arrow = in_region_b && in_region_d;
                LEFT: should_draw_arrow = in_region_a && in_region_d;
                default: should_draw_arrow = 0;
            endcase
        end
    end

    function logic should_draw_hand;
        return x_in >= hand_x_left_bottom - 16 && x_in <= hand_x_left_bottom + 16 && y_in >= hand_y_left_bottom - 32 && y_in <= hand_y_left_top + 96;
    endfunction

    function logic [15:0] get_hand_rgb;
        if(y_in <= hand_y_left_top + 16) begin
            return {5'b0, 6'hF, 5'b0};
        end else begin
            return {5'b0, 6'hF, 5'hF};
        end
    endfunction

    logic [15:0] hand_rgb;
    assign hand_rgb = get_hand_rgb();

    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            r_out <= 0;
            g_out <= 0;
            b_out <= 0;
        end else begin
            // implicit ordering occurs here. first, draw the hand.
            // then, draw the blocks
            if(should_draw_hand()) begin
                r_out <= hand_rgb[15:11];
                g_out <= hand_rgb[10:5];
                b_out <= hand_rgb[4:0];
            end else if(block_visible) begin
                if(should_draw_arrow) begin
                    r_out <= 4'hF;
                    g_out <= 4'hF;
                    b_out <= 4'hF;
                end else if(block_color == BLUE) begin
                    r_out <= 0;
                    g_out <= 0;
                    b_out <= 4'hF;
                end else begin
                    r_out <= 4'hF;
                    g_out <= 0;
                    b_out <= 0;
                end
            end else begin
                r_out <= 0;
                g_out <= 0;
                b_out <= 0;
            end
        end
    end

endmodule

`default_nettype wire