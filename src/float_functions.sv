`timescale 1ns / 1ps
`default_nettype none

/*

Compiles a list of float functions that can be used for vector
arithmetic.

*/

module vec_reciprocal_square_root(
    input wire clk_in,
    input wire rst_in,

    input wire [31:0] v_x,
    input wire [31:0] v_y,
    input wire [31:0] v_z,
    input wire v_valid,

    output wire [31:0] res_data,
    output wire res_valid
    );

    // floating_point_re_sqrt mod(
    //     .aclk(clk_in),
    //     .aresetn(~rst_in),
    //     .s_axis_a_tvalid(v_valid),
    //     .s_axis_a_tdata(v_x),
    //     .m_axis_result_tvalid(res_valid),
    //     .m_axis_result_tdata()
    // );

endmodule

module vec_scale(
    input wire clk_in,
    input wire rst_in,

    input wire [31:0] v_x,
    input wire [31:0] v_y,
    input wire [31:0] v_z,
    input wire [31:0] c,
    input wire v_valid,

    output wire [31:0] res_data_x,
    output wire [31:0] res_data_y,
    output wire [31:0] res_data_z,
    output wire res_valid
    );

    floating_point_multiply mult_x(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tdata(v_x),
        .s_axis_b_tdata(c),
        .s_axis_a_tvalid(v_valid),
        .s_axis_b_tvalid(v_valid),
        
        .m_axis_result_tvalid(res_valid),
        .m_axis_result_tdata(res_data_x)
    );

    floating_point_multiply mult_y(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tdata(v_y),
        .s_axis_b_tdata(c),
        .s_axis_a_tvalid(v_valid),
        .s_axis_b_tvalid(v_valid),
        
        .m_axis_result_tdata(res_data_y)
    );

    floating_point_multiply mult_z(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tdata(v_z),
        .s_axis_b_tdata(c),
        .s_axis_a_tvalid(v_valid),
        .s_axis_b_tvalid(v_valid),
        
        .m_axis_result_tdata(res_data_z)
    );

endmodule

module vec_add(
    input wire clk_in,
    input wire rst_in,

    input wire [31:0] v1_x,
    input wire [31:0] v1_y,
    input wire [31:0] v1_z,
    input wire [31:0] v2_x,
    input wire [31:0] v2_y,
    input wire [31:0] v2_z,
    input wire v_valid,

    output wire [31:0] res_data_x,
    output wire [31:0] res_data_y,
    output wire [31:0] res_data_z,
    output wire res_valid
    );

    floating_point_add add_x(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tdata(v1_x),
        .s_axis_b_tdata(v2_x),
        .s_axis_a_tvalid(v_valid),
        .s_axis_b_tvalid(v_valid),
        
        .m_axis_result_tvalid(res_valid),
        .m_axis_result_tdata(res_data_x)
    );

    floating_point_add add_y(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tdata(v1_y),
        .s_axis_b_tdata(v2_y),
        .s_axis_a_tvalid(v_valid),
        .s_axis_b_tvalid(v_valid),
        
        .m_axis_result_tdata(res_data_y)
    );

    floating_point_add add_z(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tdata(v1_z),
        .s_axis_b_tdata(v2_z),
        .s_axis_a_tvalid(v_valid),
        .s_axis_b_tvalid(v_valid),
        
        .m_axis_result_tdata(res_data_z)
    );

endmodule

module vec_sub(
    input wire clk_in,
    input wire rst_in,

    input wire [31:0] v1_x,
    input wire [31:0] v1_y,
    input wire [31:0] v1_z,
    input wire [31:0] v2_x,
    input wire [31:0] v2_y,
    input wire [31:0] v2_z,
    input wire v_valid,

    output wire [31:0] res_data_x,
    output wire [31:0] res_data_y,
    output wire [31:0] res_data_z,
    output wire res_valid
    );

    floating_point_sub sub_x(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tdata(v1_x),
        .s_axis_b_tdata(v2_x),
        .s_axis_a_tvalid(v_valid),
        .s_axis_b_tvalid(v_valid),
        
        .m_axis_result_tvalid(res_valid),
        .m_axis_result_tdata(res_data_x)
    );

    floating_point_sub sub_y(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tdata(v1_y),
        .s_axis_b_tdata(v2_y),
        .s_axis_a_tvalid(v_valid),
        .s_axis_b_tvalid(v_valid),
        
        .m_axis_result_tdata(res_data_y)
    );

    floating_point_sub sub_z(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tdata(v1_z),
        .s_axis_b_tdata(v2_z),
        .s_axis_a_tvalid(v_valid),
        .s_axis_b_tvalid(v_valid),
        
        .m_axis_result_tdata(res_data_z)
    );

endmodule

module vec_dot(
    input wire clk_in,
    input wire rst_in,

    input wire [31:0] v1_x,
    input wire [31:0] v1_y,
    input wire [31:0] v1_z,
    input wire [31:0] v2_x,
    input wire [31:0] v2_y,
    input wire [31:0] v2_z,
    input wire v_valid,

    output wire [31:0] res_data,
    output wire res_valid
    );

    logic mult_valid;
    logic [31:0] mult_data_x, mult_data_y, mult_data_z;

    floating_point_multiply mult_x(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tdata(v1_x),
        .s_axis_b_tdata(v2_x),
        .s_axis_a_tvalid(v_valid),
        .s_axis_b_tvalid(v_valid),
        
        .m_axis_result_tvalid(mult_valid),
        .m_axis_result_tdata(mult_data_x)
    );

    floating_point_multiply mult_y(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tdata(v1_y),
        .s_axis_b_tdata(v2_y),
        .s_axis_a_tvalid(v_valid),
        .s_axis_b_tvalid(v_valid),
        
        .m_axis_result_tdata(mult_data_y)
    );

    floating_point_multiply mult_z(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tdata(v1_z),
        .s_axis_b_tdata(v2_z),
        .s_axis_a_tvalid(v_valid),
        .s_axis_b_tvalid(v_valid),
        
        .m_axis_result_tdata(mult_data_z)
    );

    // add vx vy

    logic vxy_valid;
    logic [31:0] vxy_data;
    logic vz_valid;
    logic [31:0] vz_data;

    floating_point_add add_xy(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tdata(mult_data_x),
        .s_axis_b_tdata(mult_data_y),
        .s_axis_a_tvalid(mult_valid),
        .s_axis_b_tvalid(mult_valid),
        
        .m_axis_result_tvalid(vxy_valid),
        .m_axis_result_tdata(vxy_data)
    );

    // purely a pipeline
    floating_point_add add_z0(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tdata(mult_data_z),
        .s_axis_b_tdata(0),
        .s_axis_a_tvalid(mult_valid),
        .s_axis_b_tvalid(mult_valid),
        
        .m_axis_result_tvalid(vz_valid),
        .m_axis_result_tdata(vz_data)
    );

    // add vxy vz

    floating_point_add add_xyz(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tdata(vxy_data),
        .s_axis_b_tdata(vz_data),
        .s_axis_a_tvalid(vxy_valid),
        .s_axis_b_tvalid(vxy_valid),
        
        .m_axis_result_tvalid(res_valid),
        .m_axis_result_tdata(res_data)
    );

endmodule

module vec_normalize(
    input wire clk_in,
    input wire rst_in,

    input wire [31:0] v_x,
    input wire [31:0] v_y,
    input wire [31:0] v_z,
    input wire v_valid,

    output wire [31:0] res_data_x,
    output wire [31:0] res_data_y,
    output wire [31:0] res_data_z,
    output wire res_valid
    );

endmodule

module float_less_than(
    input wire clk_in,
    input wire rst_in,

    input wire [31:0] a,
    input wire [31:0] b,
    input wire v_valid,

    output wire res_data,
    output wire res_valid
    );

endmodule

module float_less_than_equal(
    input wire clk_in,
    input wire rst_in,

    input wire [31:0] a,
    input wire [31:0] b,
    input wire v_valid,

    output wire res_data,
    output wire res_valid
    );

endmodule

module float_equals(
    input wire clk_in,
    input wire rst_in,

    input wire [31:0] a,
    input wire [31:0] b,
    input wire v_valid,

    output wire res_data,
    output wire res_valid
    );

endmodule

`default_nettype wire