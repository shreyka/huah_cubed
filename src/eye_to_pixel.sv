`timescale 1ns / 1ps
`default_nettype none

/*

Given an XY position, calculate a
ray that goes from the eye position
to this position

Latency is possibly a long time lol

*/
module eye_to_pixel(
    input wire clk_in,
    input wire rst_in,

    input wire [10:0] x_in,
    input wire [9:0] y_in,

    output wire [31:0] dir_x,
    output wire [31:0] dir_y,
    output wire [31:0] dir_z,
    output wire dir_valid
    );

    ////////////////////////////////////////////////////
    // GAME CONSTANTS
    //
    // constants, precomputed, put here
    //

    localparam EYE_X = 1800;
    localparam EYE_Y = 1800;
    localparam WIDTH_HALF = 256;
    localparam HEIGHT_HALF = 192;

    logic [31:0] exminusw;
    assign exminusw = EYE_X - WIDTH_HALF;
    logic [31:0] eyminush;
    assign eyminush = EYE_Y - HEIGHT_HALF;

    logic [31:0] u_x, u_y, u_z;
    logic [31:0] v_x, v_y, v_z;

    assign u_x = 32'b00111111100000000000000000000000;
    assign u_y = 0;
    assign u_z = 0;

    assign v_x = 0;
    assign v_y = 32'b00111111100000000000000000000000;
    assign v_z = 0;

    ////////////////////////////////////////////////////
    // REQUIRED LOGIC/WIRES
    //
    // all required logic outputs will be here
    //

    // SECTION 1

    logic x_float_valid;
    logic [31:0] x_float_data;

    logic y_float_valid;
    logic [31:0] y_float_data;

    logic [31:0] ex_minus_w_data;
    logic [31:0] ey_minus_h_data;
    logic [31:0] float_100_data;

    logic [31:0] e_x_data;
    logic [31:0] e_y_data;
    logic [31:0] e_z_data;

    // SECTION 2

    logic [31:0] scale_u_x;
    logic [31:0] scale_u_y;
    logic [31:0] scale_u_z;
    logic scale_u_valid;

    logic [31:0] scale_v_x;
    logic [31:0] scale_v_y;
    logic [31:0] scale_v_z;
    logic scale_v_valid;

    logic [31:0] sum_scales_x;
    logic [31:0] sum_scales_y;
    logic [31:0] sum_scales_z;
    logic sum_scales_valid;

    logic [31:0] proj_plane_point_x;
    logic [31:0] proj_plane_point_y;
    logic [31:0] proj_plane_point_z;
    logic proj_plane_point_valid;

    logic [31:0] dir_sub_x;
    logic [31:0] dir_sub_y;
    logic [31:0] dir_sub_z;
    logic dir_sub_valid;

    logic [31:0] dir_norm_x;
    logic [31:0] dir_norm_y;
    logic [31:0] dir_norm_z;
    logic dir_norm_valid;

    ////////////////////////////////////////////////////
    // FLOATING-POINT MODULES
    //
    // all floating-point translations will take place here
    //

    // SECTION 1: DEFINITIONS

    floating_point_sint32_to_float x_to_float(
        .aclk(clk_in),
        .s_axis_a_tvalid(1'b1),
        .s_axis_a_tdata({21'b0, x_in}),
        .m_axis_result_tvalid(x_float_valid),
        .m_axis_result_tdata(x_float_data)
    );

    floating_point_sint32_to_float y_to_float(
        .aclk(clk_in),
        .s_axis_a_tvalid(1'b1),
        .s_axis_a_tdata({22'b0, y_in}),
        .m_axis_result_tvalid(y_float_valid),
        .m_axis_result_tdata(y_float_data)
    );

    // constant
    floating_point_sint32_to_float exminusw_to_float(
        .aclk(clk_in),
        .s_axis_a_tvalid(1'b1),
        .s_axis_a_tdata(exminusw),
        .m_axis_result_tdata(ex_minus_w_data)
    );

    // constant
    floating_point_sint32_to_float eyminusw_to_float(
        .aclk(clk_in),
        .s_axis_a_tvalid(1'b1),
        .s_axis_a_tdata(eyminush),
        .m_axis_result_tdata(ey_minus_h_data)
    );

    // constant
    floating_point_sint32_to_float float100_to_float(
        .aclk(clk_in),
        .s_axis_a_tvalid(1'b1),
        .s_axis_a_tdata(100),
        .m_axis_result_tdata(float_100_data)
    );

    // constant
    floating_point_sint32_to_float ex_to_float(
        .aclk(clk_in),
        .s_axis_a_tvalid(1'b1),
        .s_axis_a_tdata(1800),
        .m_axis_result_tdata(e_x_data)
    );

    // constant
    floating_point_sint32_to_float ey_to_float(
        .aclk(clk_in),
        .s_axis_a_tvalid(1'b1),
        .s_axis_a_tdata(1800),
        .m_axis_result_tdata(e_y_data)
    );

    // constant
    floating_point_sint32_to_float ez_to_float(
        .aclk(clk_in),
        .s_axis_a_tvalid(1'b1),
        .s_axis_a_tdata(-300),
        .m_axis_result_tdata(e_z_data)
    );

    //SECTION 2: OPERATIONS

    // scale_u
    vec_scale scale_u(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .v_x(u_x),
        .v_y(u_y),
        .v_z(u_z),
        .c(x_float_data),
        .v_valid(x_float_valid),

        .res_data_x(scale_u_x),
        .res_data_y(scale_u_y),
        .res_data_z(scale_u_z),
        .res_valid(scale_u_valid)
    );

    // scale_v
    vec_scale scale_v(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .v_x(v_x),
        .v_y(v_y),
        .v_z(v_z),
        .c(y_float_data),
        .v_valid(y_float_valid),

        .res_data_x(scale_v_x),
        .res_data_y(scale_v_y),
        .res_data_z(scale_v_z),
        .res_valid(scale_v_valid)
    );

    // sum_scales
    vec_add sum_scales(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .v1_x(scale_u_x),
        .v1_y(scale_u_y),
        .v1_z(scale_u_z),
        .v2_x(scale_v_x),
        .v2_y(scale_v_y),
        .v2_z(scale_v_z),
        .v_valid(scale_u_valid), //ASSERTION: SCALE_U and SCALE_V must finish at the same time 

        .res_data_x(sum_scales_x),
        .res_data_y(sum_scales_y),
        .res_data_z(sum_scales_z),
        .res_valid(sum_scales_valid)
    );

    // proj_plane_point
    vec_add proj_plane_point(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .v1_x(sum_scales_x),
        .v1_y(sum_scales_y),
        .v1_z(sum_scales_z),
        .v2_x(ex_minus_w_data), //ASSERTION: v2 is always constant
        .v2_y(ey_minus_h_data),
        .v2_z(float_100_data),
        .v_valid(sum_scales_valid),

        .res_data_x(proj_plane_point_x),
        .res_data_y(proj_plane_point_y),
        .res_data_z(proj_plane_point_z),
        .res_valid(proj_plane_point_valid)
    );

    // dir
    vec_sub dir_sub(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .v1_x(proj_plane_point_x),
        .v1_y(proj_plane_point_y),
        .v1_z(proj_plane_point_z),
        .v2_x(e_x_data), //ASSERTION: v2 is always constant
        .v2_y(e_y_data),
        .v2_z(e_z_data),
        .v_valid(proj_plane_point_valid),

        .res_data_x(dir_sub_x),
        .res_data_y(dir_sub_y),
        .res_data_z(dir_sub_z),
        .res_valid(dir_sub_valid)
    );

    vec_normalize dir_norm(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .v_x(dir_sub_x),
        .v_y(dir_sub_y),
        .v_z(dir_sub_z),
        .v_valid(dir_sub_valid),

        .res_data_x(dir_norm_x),
        .res_data_y(dir_norm_y),
        .res_data_z(dir_norm_z),
        .res_valid(dir_norm_valid)
    );

    assign dir_valid = dir_norm_valid;
    assign dir_x = dir_norm_x;
    assign dir_y = dir_norm_y;
    assign dir_z = dir_norm_z;    

endmodule

`default_nettype wire