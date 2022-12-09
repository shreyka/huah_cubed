`timescale 1ns / 1ps
`default_nettype none

module three_dim_renderer(
    input wire clk_in,
    input wire rst_in,

    input wire [10:0] x_in_block,
    input wire [9:0] y_in_block,

    input wire [10:0] x_in_rgb,
    input wire [9:0] y_in_rgb,

    input wire [3:0] r_in_formatted,
    input wire [3:0] g_in_formatted,
    input wire [3:0] b_in_formatted,
    input wire block_visible,
    input wire valid_in,

    input wire [1:0] state,
    input wire [17:0] curr_time,
    input wire [17:0] max_time,
    input wire [11:0] score_in,
    input wire [3:0] health_in,
    input wire [2:0] combo_in,

    input wire [9:0] [11:0] broken_blocks_x,
    input wire [9:0] [11:0] broken_blocks_y,
    input wire [9:0] [13:0] broken_blocks_z,
    input wire [9:0] broken_blocks_color,
    input wire [9:0] [11:0] broken_blocks_width,
    input wire [9:0] [11:0] broken_blocks_height,

    input wire [11:0] hand_x_right_bottom,
    input wire [11:0] hand_y_right_bottom,
    input wire [13:0] hand_z_right_bottom,
    input wire [11:0] hand_x_right_top,
    input wire [11:0] hand_y_right_top,
    input wire [13:0] hand_z_right_top,
    input wire [11:0] head_x,
    input wire [11:0] head_y,
    input wire [13:0] head_z,

    output logic [3:0] r_out,
    output logic [3:0] g_out,
    output logic [3:0] b_out
    );

    // localparam WIDTH = 1024;
    // localparam HEIGHT = 768;
    localparam WIDTH = 512;
    localparam HEIGHT = 384;
    // localparam WIDTH = 4;
    // localparam HEIGHT = 2;

    typedef enum {
        BLUE, RED
    } block_color_enum;

    logic [$clog2(WIDTH*HEIGHT)-1:0] input_loc_read;
    logic [11:0] output_pixel_read;

    logic [$clog2(WIDTH*HEIGHT)-1:0] input_loc_write;
    logic [11:0] input_pixel_write;
    logic input_write_enable;

    function int get_offset_x(logic [10:0] x);
        if (x + 2 == WIDTH) begin
            return 0;
        end else if (x + 2 == WIDTH + 1) begin
            return 1;
        end else begin
            return x + 2;
        end
    endfunction

    function int get_offset_y(logic [10:0] x, logic [9:0] y);
        if (x + 2 == WIDTH || x + 2 == WIDTH + 1) begin
            if (y + 1 == HEIGHT) begin
                return 0;
            end else begin
                return (y + 1) * WIDTH;
            end
        end else begin
            return y * WIDTH;
        end
    endfunction

    always_comb begin
        $display("WE ARE AT (%d, %d)", x_in_rgb, y_in_rgb);
        // shift to allow to scale by 2
        input_loc_read = get_offset_x(x_in_rgb >> 1) + get_offset_y(x_in_rgb >> 1, y_in_rgb >> 1);
        $display("READ FOR LATER %d", input_loc_read);
    end 

    xilinx_true_dual_port_read_first_1_clock_ram #(
        .RAM_WIDTH(12), //only 12 bits, since screen can only render that much
        .RAM_DEPTH(WIDTH*HEIGHT),                     // Specify RAM depth (number of entries)
        .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
        .INIT_FILE("")                        // Specify name/location of RAM initialization file if using one (leave blank if not)
    ) rgb_buffer (
        .addra(input_loc_read),   // Port A address bus, width determined from RAM_DEPTH
        .dina(12'b0),     // Port A RAM input data, width determined from RAM_WIDTH
        .clka(clk_in),     // Port A clock
        .wea(1'b0),       // Port A write enable
        .ena(1'b1),       // Port A RAM Enable, for additional power savings, disable port when not in use
        .rsta(rst_in),     // Port A output reset (does not affect memory contents)
        .regcea(1'b1), // Port A output register enable
        .douta(output_pixel_read),   // Port A RAM output data, width determined from RAM_WIDTH

        .addrb(input_loc_write),   // Port B address bus, width determined from RAM_DEPTH
        .dinb(input_pixel_write),     // Port B RAM input data, width determined from RAM_WIDTH
        .web(input_write_enable),       // Port B write enable
        .enb(1'b1),       // Port B RAM Enable, for additional power savings, disable port when not in use
        .rstb(rst_in),     // Port B output reset (does not affect memory contents)
        .doutb(),
        .regceb(1'b1) // Port B output register enable
    );

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            input_pixel_write <= 12'b0;
        end else begin
            // send out the buffer info always
            r_out <= output_pixel_read[11:8];
            g_out <= output_pixel_read[7:4];
            b_out <= output_pixel_read[3:0];

            if (valid_in) begin
                if(x_in_block < WIDTH && y_in_block < HEIGHT) begin
                    // only write when in the range
                    input_loc_write <= x_in_block + (y_in_block * WIDTH);
                    input_write_enable <= 1;

                    if(block_visible) begin
                        input_pixel_write <= {r_in_formatted, g_in_formatted, b_in_formatted};
                    end else begin
                        input_pixel_write <= 12'h000;
                    end
                end else begin
                    input_write_enable <= 0;
                end
            end else begin
                input_write_enable <= 0;
            end
        end
    end

endmodule

`default_nettype wire