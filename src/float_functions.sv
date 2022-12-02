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

    output logic [31:0] res_data,
    output logic res_valid
    );

    logic dot_valid;
    logic [31:0] dot_data;

    vec_dot dot(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .v1_x(v_x),
        .v1_y(v_y),
        .v1_z(v_z),
        .v2_x(v_x),
        .v2_y(v_y),
        .v2_z(v_z),
        .v_valid(v_valid),

        .res_data(dot_data),
        .res_valid(dot_valid)
    );

    floating_point_re_sqrt mod(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tvalid(dot_valid),
        .s_axis_a_tdata(dot_data),
        .m_axis_result_tvalid(res_valid),
        .m_axis_result_tdata(res_data)
    );

endmodule

module vec_scale(
    input wire clk_in,
    input wire rst_in,

    input wire [31:0] v_x,
    input wire [31:0] v_y,
    input wire [31:0] v_z,
    input wire [31:0] c,
    input wire v_valid,

    output logic [31:0] res_data_x,
    output logic [31:0] res_data_y,
    output logic [31:0] res_data_z,
    output logic res_valid
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

    output logic [31:0] res_data_x,
    output logic [31:0] res_data_y,
    output logic [31:0] res_data_z,
    output logic res_valid
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

module vec_divide(
    input wire clk_in,
    input wire rst_in,

    input wire [31:0] v1_x,
    input wire [31:0] v1_y,
    input wire [31:0] v1_z,
    input wire [31:0] v2_x,
    input wire [31:0] v2_y,
    input wire [31:0] v2_z,
    input wire v_valid,

    output logic [31:0] res_data_x,
    output logic [31:0] res_data_y,
    output logic [31:0] res_data_z,
    output logic res_valid
    );

    floating_point_divide divide_x(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tdata(v1_x),
        .s_axis_b_tdata(v2_x),
        .s_axis_a_tvalid(v_valid),
        .s_axis_b_tvalid(v_valid),
        
        .m_axis_result_tvalid(res_valid),
        .m_axis_result_tdata(res_data_x)
    );

    floating_point_divide divide_y(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tdata(v1_y),
        .s_axis_b_tdata(v2_y),
        .s_axis_a_tvalid(v_valid),
        .s_axis_b_tvalid(v_valid),
        
        .m_axis_result_tdata(res_data_y)
    );

    floating_point_divide divide_z(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tdata(v1_z),
        .s_axis_b_tdata(v2_z),
        .s_axis_a_tvalid(v_valid),
        .s_axis_b_tvalid(v_valid),
        
        .m_axis_result_tdata(res_data_z)
    );

endmodule

module vec_multiply(
    input wire clk_in,
    input wire rst_in,

    input wire [31:0] v1_x,
    input wire [31:0] v1_y,
    input wire [31:0] v1_z,
    input wire [31:0] v2_x,
    input wire [31:0] v2_y,
    input wire [31:0] v2_z,
    input wire v_valid,

    output logic [31:0] res_data_x,
    output logic [31:0] res_data_y,
    output logic [31:0] res_data_z,
    output logic res_valid
    );

    floating_point_multiply multiply_x(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tdata(v1_x),
        .s_axis_b_tdata(v2_x),
        .s_axis_a_tvalid(v_valid),
        .s_axis_b_tvalid(v_valid),
        
        .m_axis_result_tvalid(res_valid),
        .m_axis_result_tdata(res_data_x)
    );

    floating_point_multiply multiply_y(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tdata(v1_y),
        .s_axis_b_tdata(v2_y),
        .s_axis_a_tvalid(v_valid),
        .s_axis_b_tvalid(v_valid),
        
        .m_axis_result_tdata(res_data_y)
    );

    floating_point_multiply multiply_z(
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

    output logic [31:0] res_data_x,
    output logic [31:0] res_data_y,
    output logic [31:0] res_data_z,
    output logic res_valid
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

    output logic [31:0] res_data,
    output logic res_valid
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

    output logic [31:0] res_data_x,
    output logic [31:0] res_data_y,
    output logic [31:0] res_data_z,
    output logic res_valid
    );

    logic resqrt_valid;
    logic [31:0] resqrt_data;

    vec_reciprocal_square_root mod(
        .clk_in(clk_in),
        .rst_in(rst_in),    
        .v_x(v_x),
        .v_y(v_y),
        .v_z(v_z),
        .v_valid(v_valid),

        .res_data(resqrt_data),
        .res_valid(resqrt_valid)
    );

    // pipelining the VX VY VZ
    localparam RESQRT_DELAY = 62;
    logic [31:0] v_x_pipe [RESQRT_DELAY-1:0];
    logic [31:0] v_y_pipe [RESQRT_DELAY-1:0];
    logic [31:0] v_z_pipe [RESQRT_DELAY-1:0];

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            for(int i=0; i<RESQRT_DELAY; i = i+1) begin
                v_x_pipe[i] <= 0;
                v_y_pipe[i] <= 0;
                v_z_pipe[i] <= 0;
            end
        end else begin
            v_x_pipe[0] <= v_x;
            v_y_pipe[0] <= v_y;
            v_z_pipe[0] <= v_z;
            for (int i=1; i<RESQRT_DELAY; i = i+1) begin
                v_x_pipe[i] <= v_x_pipe[i-1];
                v_y_pipe[i] <= v_y_pipe[i-1];
                v_z_pipe[i] <= v_z_pipe[i-1];
            end
        end

        // if (v_valid) begin
        //     $display("VEC_RECP VALID: %d", v_x);
        // end

        // if (resqrt_valid) begin
        //     $display("RESULT IS %b", resqrt_data);
        //     $display("VX IS %d", v_x_pipe[RESQRT_DELAY-1]);
        // end else begin
        //     $display("NOT VALID, VX IS %d", v_x_pipe[RESQRT_DELAY - 1]);
        // end
    end

    vec_scale mod2(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .v_x(v_x_pipe[RESQRT_DELAY-1]),
        .v_y(v_y_pipe[RESQRT_DELAY-1]),
        .v_z(v_z_pipe[RESQRT_DELAY-1]),
        .c(resqrt_data),
        .v_valid(resqrt_valid),

        .res_data_x(res_data_x),
        .res_data_y(res_data_y),
        .res_data_z(res_data_z),
        .res_valid(res_valid)
    );

endmodule

module float_less_than(
    input wire clk_in,
    input wire rst_in,

    input wire [31:0] a,
    input wire [31:0] b,
    input wire v_valid,

    output logic res_data,
    output logic res_valid
    );

    logic [7:0] comp_data;

    floating_point_lt mod(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tdata(a),
        .s_axis_b_tdata(b),
        .s_axis_a_tvalid(v_valid),
        .s_axis_b_tvalid(v_valid),
        .m_axis_result_tvalid(res_valid),
        .m_axis_result_tdata(comp_data)
    );

    assign res_data = comp_data[0];

endmodule

module vec_less_than(
    input wire clk_in,
    input wire rst_in,

    input wire [31:0] a_x,
    input wire [31:0] a_y,
    input wire [31:0] a_z,
    input wire [31:0] b_x,
    input wire [31:0] b_y,
    input wire [31:0] b_z,
    input wire v_valid,

    output logic res_data_x,
    output logic res_data_y,
    output logic res_data_z,
    output logic res_valid
    );

    logic [7:0] comp_data_x;
    logic [7:0] comp_data_y;
    logic [7:0] comp_data_z;

    floating_point_lt mod_x(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tdata(a_x),
        .s_axis_b_tdata(b_x),
        .s_axis_a_tvalid(v_valid),
        .s_axis_b_tvalid(v_valid),
        .m_axis_result_tvalid(res_valid),
        .m_axis_result_tdata(comp_data_x)
    );

    floating_point_lt mod_y(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tdata(a_y),
        .s_axis_b_tdata(b_y),
        .s_axis_a_tvalid(v_valid),
        .s_axis_b_tvalid(v_valid),
        .m_axis_result_tdata(comp_data_y)
    );

    floating_point_lt mod_z(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tdata(a_z),
        .s_axis_b_tdata(b_z),
        .s_axis_a_tvalid(v_valid),
        .s_axis_b_tvalid(v_valid),
        .m_axis_result_tdata(comp_data_z)
    );

    assign res_data_x = comp_data_x[0];
    assign res_data_y = comp_data_y[0];
    assign res_data_z = comp_data_z[0];

endmodule

module float_less_than_equal(
    input wire clk_in,
    input wire rst_in,

    input wire [31:0] a,
    input wire [31:0] b,
    input wire v_valid,

    output logic res_data,
    output logic res_valid
    );

    logic [7:0] comp_data;

    floating_point_lte mod(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tdata(a),
        .s_axis_b_tdata(b),
        .s_axis_a_tvalid(v_valid),
        .s_axis_b_tvalid(v_valid),
        .m_axis_result_tvalid(res_valid),
        .m_axis_result_tdata(comp_data)
    );

    assign res_data = comp_data[0];

endmodule

module float_equals(
    input wire clk_in,
    input wire rst_in,

    input wire [31:0] a,
    input wire [31:0] b,
    input wire v_valid,

    output logic res_data,
    output logic res_valid
    );

    logic [7:0] comp_data;

    floating_point_equal mod(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tdata(a),
        .s_axis_b_tdata(b),
        .s_axis_a_tvalid(v_valid),
        .s_axis_b_tvalid(v_valid),
        .m_axis_result_tvalid(res_valid),
        .m_axis_result_tdata(comp_data)
    );

    assign res_data = comp_data[0];

endmodule

module vec_comp(
    input wire clk_in,
    input wire rst_in,

    input wire [31:0] v1_x,
    input wire [31:0] v1_y,
    input wire [31:0] v1_z,
    input wire [31:0] v2_x,
    input wire [31:0] v2_y,
    input wire [31:0] v2_z,
    input wire comp_x,
    input wire comp_y,
    input wire comp_z,
    input wire v_valid,

    output logic [31:0] res_data_x,
    output logic [31:0] res_data_y,
    output logic [31:0] res_data_z,
    output logic res_valid
    );

    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            res_data_x <= 0;
            res_data_y <= 0;
            res_data_z <= 0;
            res_valid <= 0;
        end else begin
            if (v_valid) begin
                res_data_x <= comp_x ? v1_x : v2_x;
                res_data_y <= comp_y ? v1_y : v2_y;
                res_data_z <= comp_z ? v1_z : v2_z;
                res_valid <= 1;
            end else begin
                res_data_x <= 0;
                res_data_y <= 0;
                res_data_z <= 0;
                res_valid <= 0;
            end
        end
    end
endmodule

module vec_max(
    input wire clk_in,
    input wire rst_in,

    input wire [31:0] v_x,
    input wire [31:0] v_y,
    input wire [31:0] v_z,
    input wire v_valid,

    output logic [31:0] res_data,
    output logic res_valid
    );

    // stage 0

    logic comp_data_x, comp_data_y, comp_data_z;
    logic comp_valid;
    
    vec_less_than less_than(
        .clk_in(clk_in),
        .rst_in(rst_in),

        .a_x(v_y),
        .a_y(v_y),
        .a_z(v_x),

        .b_x(v_x),
        .b_y(v_z),
        .b_z(v_z),
        .v_valid(v_valid),

        .res_data_x(comp_data_x),
        .res_data_y(comp_data_y),
        .res_data_z(comp_data_z),
        .res_valid(comp_valid)
    );

    // stage 1

    // pipelining the VX VY VZ
    localparam COMP_DELAY = 2;
    logic [31:0] v_x_pipe [COMP_DELAY-1:0];
    logic [31:0] v_y_pipe [COMP_DELAY-1:0];
    logic [31:0] v_z_pipe [COMP_DELAY-1:0];

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            for(int i=0; i<COMP_DELAY; i = i+1) begin
                v_x_pipe[i] <= 0;
                v_y_pipe[i] <= 0;
                v_z_pipe[i] <= 0;
            end

            res_data <= 0;
            res_valid <= 0;
        end else begin
            if (comp_valid) begin
                if (comp_data_y && comp_data_z) begin
                    res_data <= v_z_pipe[COMP_DELAY-1];
                end else if (comp_data_x) begin
                    res_data <= v_x_pipe[COMP_DELAY-1];
                end else begin
                    res_data <= v_y_pipe[COMP_DELAY-1];
                end

                res_valid <= 1;
            end else begin
                res_data <= 0;
                res_valid <= 0;
            end

            v_x_pipe[0] <= v_x;
            v_y_pipe[0] <= v_y;
            v_z_pipe[0] <= v_z;
            for (int i=1; i<COMP_DELAY; i = i+1) begin
                v_x_pipe[i] <= v_x_pipe[i-1];
                v_y_pipe[i] <= v_y_pipe[i-1];
                v_z_pipe[i] <= v_z_pipe[i-1];
            end
        end
    end
endmodule

module vec_min(
    input wire clk_in,
    input wire rst_in,

    input wire [31:0] v_x,
    input wire [31:0] v_y,
    input wire [31:0] v_z,
    input wire v_valid,

    output logic [31:0] res_data,
    output logic res_valid
    );

    // stage 0

    logic comp_data_x, comp_data_y, comp_data_z;
    logic comp_valid;
    
    vec_less_than less_than(
        .clk_in(clk_in),
        .rst_in(rst_in),

        .a_x(v_x),
        .a_y(v_z),
        .a_z(v_z),

        .b_x(v_y),
        .b_y(v_y),
        .b_z(v_x),
        .v_valid(v_valid),

        .res_data_x(comp_data_x),
        .res_data_y(comp_data_y),
        .res_data_z(comp_data_z),
        .res_valid(comp_valid)
    );

    // stage 1

    // pipelining the VX VY VZ
    localparam COMP_DELAY = 2;
    logic [31:0] v_x_pipe [COMP_DELAY-1:0];
    logic [31:0] v_y_pipe [COMP_DELAY-1:0];
    logic [31:0] v_z_pipe [COMP_DELAY-1:0];

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            for(int i=0; i<COMP_DELAY; i = i+1) begin
                v_x_pipe[i] <= 0;
                v_y_pipe[i] <= 0;
                v_z_pipe[i] <= 0;
            end

            res_data <= 0;
            res_valid <= 0;
        end else begin
            if (comp_valid) begin
                if (comp_data_y && comp_data_z) begin
                    res_data <= v_z_pipe[COMP_DELAY-1];
                end else if (comp_data_x) begin
                    res_data <= v_x_pipe[COMP_DELAY-1];
                end else begin
                    res_data <= v_y_pipe[COMP_DELAY-1];
                end

                res_valid <= 1;
            end else begin
                res_data <= 0;
                res_valid <= 0;
            end

            v_x_pipe[0] <= v_x;
            v_y_pipe[0] <= v_y;
            v_z_pipe[0] <= v_z;
            for (int i=1; i<COMP_DELAY; i = i+1) begin
                v_x_pipe[i] <= v_x_pipe[i-1];
                v_y_pipe[i] <= v_y_pipe[i-1];
                v_z_pipe[i] <= v_z_pipe[i-1];
            end
        end
    end
endmodule

`default_nettype wire