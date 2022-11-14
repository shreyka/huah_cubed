`timescale 1ns / 1ps
`default_nettype none

module renderer(
    input wire clk_in,
    input wire rst_in,

    input wire [10:0] x_in,
    input wire [9:0] y_in,

    input wire block_visible,
    input wire [7:0] curr_block_index_in,
    input wire [11:0] block_x,
    input wire [11:0] block_y,
    input wire [13:0] block_z,
    input wire block_color,
    input wire [2:0] block_direction,

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

    logic [9:0] block_size;
    logic [9:0] block_size_2;
    assign block_size = 512 + ($signed(block_z) * $signed(-502) >>> 11);
    assign block_size_2 = (block_size > 512 ? 0 : block_size) >> 1;

    logic in_region_a; //TL
    logic in_region_b; //BR
    logic in_region_c; //TR
    logic in_region_d; //BL
    logic should_draw_arrow;

    always_comb begin
        if(block_visible) begin
            in_region_a = $signed(y_in + x_in) < $signed($signed(block_y) + $signed(block_x));
            in_region_b = $signed(y_in + x_in) > $signed($signed(block_y) + $signed(block_x));

            in_region_c = $signed(y_in) < $signed($signed(x_in) + $signed($signed(block_y) - $signed(block_x)));
            in_region_d = $signed(y_in) > $signed($signed(x_in) + $signed($signed(block_y) - $signed(block_x)));

            case(block_direction)
                UP: should_draw_arrow = in_region_a && in_region_c;
                RIGHT: should_draw_arrow = in_region_b && in_region_c;
                DOWN: should_draw_arrow = in_region_b && in_region_d;
                LEFT: should_draw_arrow = in_region_a && in_region_d;
                default: should_draw_arrow = 0;
            endcase

            // $display("\tRANGES: %d %d %d %d (%d, %d) should=%d vis=%d", block_x - block_size_2, block_x + block_size_2, block_y - block_size_2, block_y + block_size_2, x_in, y_in, should_draw_arrow, block_visible);
            // $display("\REGIONS: %d %d %d %d", in_region_a, in_region_b, in_region_c, in_region_d);
        end
    end

    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            r_out <= 0;
            g_out <= 0;
            b_out <= 0;
        end else begin
            if(block_visible &&
                    (x_in >= block_x - block_size_2 && x_in <= block_x + block_size_2 && y_in >= block_y - block_size_2 && y_in <= block_y + block_size_2)) begin
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