`timescale 1ns / 1ps
`default_nettype none

module broken_blocks(
    input wire clk_in,
    input wire rst_in,

    input wire [17:0] curr_time,

    input wire [11:0] block_x,
    input wire [11:0] block_y,
    input wire [13:0] block_z,
    input wire block_color,
    input wire [2:0] block_direction,
    input wire [7:0] block_ID_in,
    input wire block_sliced,

    output logic [9:0] [11:0] broken_blocks_x,
    output logic [9:0] [11:0] broken_blocks_y,
    output logic [9:0] [13:0] broken_blocks_z,
    output logic [9:0] broken_blocks_color,
    output logic [9:0] [11:0] broken_blocks_width,
    output logic [9:0] [11:0] broken_blocks_height
    );

    typedef enum {
        UP, RIGHT, DOWN, LEFT, ANY
    } direction;

    logic [9:0] [2:0] broken_blocks_direction;
    logic [9:0] [2:0] broken_blocks_time_alive;

    logic [17:0] last_time;

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            broken_blocks_x <= 0;
            broken_blocks_y <= 0;
            broken_blocks_z <= 0;
            broken_blocks_width <= 0;
            broken_blocks_height <= 0;
            broken_blocks_direction <= 0;
            broken_blocks_time_alive <= 0;
        end else begin
            if(block_sliced) begin
                $display("THERE WAS A BLOCK SLICED! %d", block_ID_in);
                //move two spots down
                for(int i = 0; i < 8; i = i + 1) begin
                    broken_blocks_x[i] <= broken_blocks_x[i + 2];
                    broken_blocks_y[i] <= broken_blocks_y[i + 2];
                    broken_blocks_z[i] <= broken_blocks_z[i + 2];
                    broken_blocks_width[i] <= broken_blocks_width[i + 2];
                    broken_blocks_height[i] <= broken_blocks_height[i + 2];
                    broken_blocks_color[i] <= broken_blocks_color[i + 2];
                    broken_blocks_direction[i] <= broken_blocks_direction[i + 2];
                    broken_blocks_time_alive[i] <= broken_blocks_time_alive[i + 2];
                end

                broken_blocks_x[8] <= block_x; 
                broken_blocks_y[8] <= block_y; 
                broken_blocks_z[8] <= block_z; 
                broken_blocks_width[8] <= (block_direction == UP || block_direction == DOWN) ? 64 : 128;
                broken_blocks_height[8] <= (block_direction == UP || block_direction == DOWN) ? 128 : 64; 
                broken_blocks_color[8] <= block_color;
                broken_blocks_direction[8] <= (block_direction == UP || block_direction == DOWN) ? LEFT : 64;
                broken_blocks_time_alive[8] <= 0;

                broken_blocks_x[9] <= block_x; 
                broken_blocks_y[9] <= block_y; 
                broken_blocks_z[9] <= block_z; 
                broken_blocks_width[9] <= (block_direction == UP || block_direction == DOWN) ? 64 : 128;
                broken_blocks_height[9] <= (block_direction == UP || block_direction == DOWN) ? 128 : 64; 
                broken_blocks_color[9] <= block_color;
                broken_blocks_direction[9] <= (block_direction == UP || block_direction == DOWN) ? RIGHT : DOWN;
                broken_blocks_time_alive[9] <= 0;
            end else begin
                if(last_time != curr_time) begin
                    last_time <= curr_time;

                    for(int i = 0; i < 10; i = i + 1) begin
                        if(broken_blocks_time_alive[i] == 50) begin
                            broken_blocks_x[i] <= 0;
                            broken_blocks_y[i] <= 0;
                            broken_blocks_z[i] <= 0;

                            broken_blocks_time_alive[i] <= broken_blocks_time_alive[i] + 1;
                        end else if(broken_blocks_time_alive[i] < 50) begin
                            broken_blocks_time_alive[i] <= broken_blocks_time_alive[i] + 1;

                            case(broken_blocks_direction[i])
                                UP: begin
                                    broken_blocks_y[i] <= $signed(broken_blocks_y[i]) - $signed(8) < 0 ? 0 : broken_blocks_y[i] - 8;
                                end
                                RIGHT: begin
                                    broken_blocks_x[i] <= broken_blocks_x[i] + 8 >= 3600 ? 3599 : broken_blocks_x[i] + 8;
                                end
                                DOWN: begin
                                    broken_blocks_y[i] <= broken_blocks_y[i] + 8 >= 3600 ? 3599 : broken_blocks_y[i] + 8;
                                end
                                LEFT: begin
                                    broken_blocks_x[i] <= $signed(broken_blocks_x[i]) - $signed(8) < 0 ? 0 : broken_blocks_x[i] - 8;
                                end
                            endcase
                        end
                    end
                end
            end
        end
    end

endmodule

`default_nettype wire