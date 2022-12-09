`timescale 1ns / 1ps
`default_nettype none

/*

Get the RGB value that should
be set at a particular XY coordinate.

*/
module get_pixel_rgb_formatted(
    input wire clk_in,
    input wire rst_in,

    input wire [11:0] block_pos_x,
    input wire [11:0] block_pos_y,
    input wire [13:0] block_pos_z,
    input wire [2:0] block_color,
    input wire [2:0] block_dir,
    input wire block_visible_in,

    input wire [31:0] ray_x,
    input wire [31:0] ray_y,
    input wire [31:0] ray_z,

    input wire [10:0] x_in,
    input wire [9:0] y_in,
    input wire valid_in,

    input wire [31:0] t_in,

    output logic [10:0] x_out,
    output logic [9:0] y_out,
    output logic block_visible_out,
    output logic [3:0] r_out,
    output logic [3:0] g_out,
    output logic [3:0] b_out,
    output logic rgb_valid
    );

    ////////////////////////////////////////////////////
    // VARIABLE CONSTANTS
    //
    // precomputed constants go here
    //

    typedef enum {
        BLUE, RED
    } block_color_enum;

    logic [31:0] one;
    logic [31:0] two_fifty_five;

    assign one = 32'b00111111100000000000000000000000;
    assign two_fifty_five = 32'b01000011011111110000000000000000;

    ////////////////////////////////////////////////////
    // VARIABLE DEFINITIONS
    //
    // logic variables go here
    //

    // stage -1
    logic [31:0] block_float_x, block_float_y, block_float_z;
    logic block_float_x_valid;

    // stage 0
    logic [31:0] r_pixel;
    logic [31:0] g_pixel;
    logic [31:0] b_pixel;
    logic rgb_pixel_valid;

    // stage 1
    logic rgb_lt_x;
    logic rgb_lt_y;
    logic rgb_lt_z;
    logic rgb_lt_valid;

    // stage 2
    logic [31:0] rgb_one_low_x, rgb_one_low_y, rgb_one_low_z;
    logic rgb_one_low_valid;

    // stage 3
    logic [31:0] r_scaled;
    logic [31:0] g_scaled;
    logic [31:0] b_scaled;
    logic rgb_scaled_valid;

    // stage 4
    logic [31:0] r_int;
    logic [31:0] g_int;
    logic [31:0] b_int;
    logic r_int_valid;

    ////////////////////////////////////////////////////
    // LOGIC
    //
    // module logic chain
    //

    // logic [31:0] count;
    // always_ff @(posedge clk_in) begin
    //     if (valid_in) begin
    //         count <= 0;
    //         $display("VALID_IN XY (%d, %d)", x_in, y_in);
    //     end else begin
    //         count <= count + 1;
    //     end

    //     if(rgb_valid) begin
    //         $display("i:%d, RGB_VALID XY (%d, %d)", count, x_in, y_in);
    //     end
    // end

    // stage -1: convert to float, takes 6 cycles

    floating_point_sint32_to_float ex_to_float(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tvalid(valid_in),
        .s_axis_a_tdata({20'b0, block_pos_x}),
        .m_axis_result_tdata(block_float_x),
        .m_axis_result_tvalid(block_float_x_valid)
    );
    floating_point_sint32_to_float ey_to_float(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tvalid(valid_in),
        .s_axis_a_tdata({20'b0, block_pos_y}),
        .m_axis_result_tdata(block_float_y),
        .m_axis_result_tvalid()
    );
    floating_point_sint32_to_float ez_to_float(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tvalid(valid_in),
        .s_axis_a_tdata({18'b0, block_pos_z}),
        .m_axis_result_tdata(block_float_z),
        .m_axis_result_tvalid()
    );

    // stage 0

    // pipelining the ray: 6, verified
    localparam RAY_DELAY = 6;
    logic [31:0] ray_x_pipe [RAY_DELAY-1:0];
    logic [31:0] ray_y_pipe [RAY_DELAY-1:0];
    logic [31:0] ray_z_pipe [RAY_DELAY-1:0];
    logic [31:0] t_in_pipe [RAY_DELAY-1:0];

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            for(int i=0; i<RAY_DELAY; i = i+1) begin
                ray_x_pipe[i] <= 0;
                ray_y_pipe[i] <= 0;
                ray_z_pipe[i] <= 0;
                t_in_pipe[i] <= 0;
            end
        end else begin
            ray_x_pipe[0] <= ray_x;
            ray_y_pipe[0] <= ray_y;
            ray_z_pipe[0] <= ray_z;
            t_in_pipe[0] <= t_in;
            for (int i=1; i<RAY_DELAY; i = i+1) begin
                ray_x_pipe[i] <= ray_x_pipe[i-1];
                ray_y_pipe[i] <= ray_y_pipe[i-1];
                ray_z_pipe[i] <= ray_z_pipe[i-1];
                t_in_pipe[i] <= t_in_pipe[i-1];
            end
        end
    end

    get_pixel_color get_pixel_color(
        .clk_in(clk_in),
        .rst_in(rst_in),

        .block_pos_x(block_float_x),
        .block_pos_y(block_float_y),
        .block_pos_z(block_float_z),
        .block_color(block_color),
        .block_dir(block_dir),
        .valid_in(block_float_x_valid),

        .ray_x(ray_x_pipe[RAY_DELAY-1]),
        .ray_y(ray_y_pipe[RAY_DELAY-1]),
        .ray_z(ray_z_pipe[RAY_DELAY-1]),

        .t_in(t_in_pipe[RAY_DELAY-1]),

        .r_out(r_pixel),
        .g_out(g_pixel),
        .b_out(b_pixel),
        .rgb_valid(rgb_pixel_valid)
    );

    // stage 1
    vec_less_than rgb_lt(
        .clk_in(clk_in),
        .rst_in(rst_in),

        .a_x(r_pixel),
        .a_y(g_pixel),
        .a_z(b_pixel),

        .b_x(one),
        .b_y(one),
        .b_z(one),
        .v_valid(rgb_pixel_valid),

        .res_data_x(rgb_lt_x),
        .res_data_y(rgb_lt_y),
        .res_data_z(rgb_lt_z),
        .res_valid(rgb_lt_valid)
    );

    // stage 2

    //todo: should pipeline block_pos, block_dir
    localparam RGB_DELAY = 2;
    logic [31:0] r_pixel_pipe [RGB_DELAY-1:0];
    logic [31:0] g_pixel_pipe [RGB_DELAY-1:0];
    logic [31:0] b_pixel_pipe [RGB_DELAY-1:0];

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            for(int i=0; i<RGB_DELAY; i = i+1) begin
                r_pixel_pipe[i] <= 0;
                g_pixel_pipe[i] <= 0;
                b_pixel_pipe[i] <= 0;
            end
        end else begin
            r_pixel_pipe[0] <= r_pixel;
            g_pixel_pipe[0] <= g_pixel;
            b_pixel_pipe[0] <= b_pixel;
            for (int i=1; i<RGB_DELAY; i = i+1) begin
                r_pixel_pipe[i] <= r_pixel_pipe[i-1];
                g_pixel_pipe[i] <= g_pixel_pipe[i-1];
                b_pixel_pipe[i] <= b_pixel_pipe[i-1];
            end
        end
    end

    vec_comp rgb_one_low_comp(
        .clk_in(clk_in),
        .rst_in(rst_in),

        .v1_x(r_pixel_pipe[RGB_DELAY-1]),
        .v1_y(g_pixel_pipe[RGB_DELAY-1]),
        .v1_z(b_pixel_pipe[RGB_DELAY-1]),
        .v2_x(one),
        .v2_y(one),
        .v2_z(one),
        .comp_x(rgb_lt_x),
        .comp_y(rgb_lt_y),
        .comp_z(rgb_lt_z),
        .v_valid(rgb_lt_valid),

        .res_data_x(rgb_one_low_x),
        .res_data_y(rgb_one_low_y),
        .res_data_z(rgb_one_low_z),
        .res_valid(rgb_one_low_valid)
    );

    // stage 3
    vec_scale rgb_scaled_scale(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .v_x(rgb_one_low_x),
        .v_y(rgb_one_low_y),
        .v_z(rgb_one_low_z),
        .c(two_fifty_five),
        .v_valid(rgb_one_low_valid),

        .res_data_x(r_scaled),
        .res_data_y(g_scaled),
        .res_data_z(b_scaled),
        .res_valid(rgb_scaled_valid)
    );

    // always_ff @(posedge clk_in) begin
    //     if (rgb_scaled_valid) begin
    //         $display("RGB_SCALED %b %b %b", r_scaled, g_scaled, b_scaled);
    //     end
    // end

    // stage 4

    floating_point_float_to_sint32 rgb_out_x(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tvalid(rgb_scaled_valid),
        .s_axis_a_tdata(r_scaled),
        .m_axis_result_tdata(r_int),
        .m_axis_result_tvalid(r_int_valid)
    );  

    floating_point_float_to_sint32 rgb_out_y(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tvalid(rgb_scaled_valid),
        .s_axis_a_tdata(g_scaled),
        .m_axis_result_tdata(g_int),
        .m_axis_result_tvalid()
    );  

    floating_point_float_to_sint32 rgb_out_z(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tvalid(rgb_scaled_valid),
        .s_axis_a_tdata(b_scaled),
        .m_axis_result_tdata(b_int),
        .m_axis_result_tvalid()
    );

    // pipeline XY (270 + 6, measured and verified)
    localparam XY_DELAY = 270 + 6;
    logic [10:0] x_in_pipe [XY_DELAY-1:0];
    logic [9:0] y_in_pipe [XY_DELAY-1:0];
    logic block_visible_out_pipe [XY_DELAY-1:0];

    // always_ff @(posedge clk_in) begin
    //     if (r_int_valid) begin
    //         $display("XY %d %d", x_in_pipe[XY_DELAY-1], y_in_pipe[XY_DELAY-1]);
    //         $display("RGB %b %b %b", r_int, g_int, b_int);
    //     end else begin
    //         $display("    INVALID XY %d %d", x_in_pipe[XY_DELAY-1], y_in_pipe[XY_DELAY-1]);
    //     end
    // end

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            for(int i=0; i<XY_DELAY; i = i+1) begin
                x_in_pipe[i] <= 0;
                y_in_pipe[i] <= 0;
                block_visible_out_pipe[i] <= 0;
            end
        end else begin
            x_in_pipe[0] <= x_in;
            y_in_pipe[0] <= y_in;
            block_visible_out_pipe[0] <= block_visible_in;
            for (int i=1; i<XY_DELAY; i = i+1) begin
                x_in_pipe[i] <= x_in_pipe[i-1];
                y_in_pipe[i] <= y_in_pipe[i-1];
                block_visible_out_pipe[i] <= block_visible_out_pipe[i-1];
            end
        end
    end

    assign x_out = x_in_pipe[XY_DELAY-1];
    assign y_out = y_in_pipe[XY_DELAY-1];
    assign block_visible_out = block_visible_out_pipe[XY_DELAY-1];
    assign r_out = r_int[7:4];
    assign g_out = g_int[7:4];
    assign b_out = b_int[7:4];
    assign rgb_valid = r_int_valid;
endmodule

`default_nettype wire