`timescale 1ns / 1ps
`default_nettype none

/*

Given a ray and a block position, return
if they intersect with each other.

This module is separated into 7 stages.

*/
module does_ray_block_intersect(
    input wire clk_in,
    input wire rst_in,
    
    input wire [31:0] ray_x,
    input wire [31:0] ray_y,
    input wire [31:0] ray_z,
    input wire [31:0] block_pos_x,
    input wire [31:0] block_pos_y,
    input wire [31:0] block_pos_z,
    input wire [31:0] t_in,
    input wire valid_in,

    output logic intersects_data_out,
    output logic [31:0] t_out,
    output logic valid_out
    );

    ////////////////////////////////////////////////////
    // VARIABLE CONSTANTS
    //
    // precomputed constants go here
    //

    logic [31:0] block_size;
    // 100
    assign block_size = 32'b01000010110010000000000000000000;

    logic [31:0] e_x_data, e_y_data, e_z_data;

    // constant, try to make never 0
    floating_point_sint32_to_float ex_to_float(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tvalid(1'b1),
        .s_axis_a_tdata(1800.00001),
        .m_axis_result_tdata(e_x_data)
    );

    // constant, try to make never 0
    floating_point_sint32_to_float ey_to_float(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tvalid(1'b1),
        .s_axis_a_tdata(1800.00001),
        .m_axis_result_tdata(e_y_data)
    );

    // constant, try to make never 0
    floating_point_sint32_to_float ez_to_float(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tvalid(1'b1),
        .s_axis_a_tdata(-300.00001),
        .m_axis_result_tdata(e_z_data)
    );

    ////////////////////////////////////////////////////
    // REQUIRED VARIABLES
    //
    // module variables go here
    //

    // stage 0
    logic [31:0] block_min_x, block_min_y, block_min_z;
    logic [31:0] block_max_x, block_max_y, block_max_z;
    logic block_min_valid;

    // stage 1
    logic [31:0] min_e_x, min_e_y, min_e_z;
    logic [31:0] max_e_x, max_e_y, max_e_z;
    logic min_e_valid;

    // stage 2
    logic [31:0] tx1_x, tx1_y, tx1_z;
    logic [31:0] tx2_x, tx2_y, tx2_z;
    logic tx1_valid;

    // stage 3
    logic min_tx12_lt_x, min_tx12_lt_y, min_tx12_lt_z;
    logic max_tx12_lt_x, max_tx12_lt_y, max_tx12_lt_z;
    logic min_tx12_lt_valid;

    // stage 4
    logic [31:0] tx12_min_select_x, tx12_min_select_y, tx12_min_select_z;
    logic [31:0] tx12_max_select_x, tx12_max_select_y, tx12_max_select_z;
    logic tx12_min_select_valid;

    // stage 5
    logic [31:0] tmin, tmax;
    logic tmin_valid;

    ////////////////////////////////////////////////////
    // MODULE LOGIC
    //
    // the entire chain of events go here
    //

    // stage 0

    vec_sub block_min_sub(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .v1_x(block_pos_x),
        .v1_y(block_pos_y),
        .v1_z(block_pos_z),
        .v2_x(block_size),
        .v2_y(block_size),
        .v2_z(block_size),
        .v_valid(valid_in),

        .res_data_x(block_min_x),
        .res_data_y(block_min_y),
        .res_data_z(block_min_z),
        .res_valid(block_min_valid)
    );

    vec_add block_max_add(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .v1_x(block_pos_x),
        .v1_y(block_pos_y),
        .v1_z(block_pos_z),
        .v2_x(block_size),
        .v2_y(block_size),
        .v2_z(block_size),
        .v_valid(valid_in),

        .res_data_x(block_max_x),
        .res_data_y(block_max_y),
        .res_data_z(block_max_z)
    );

    // stage 1

    vec_sub min_e_sub(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .v1_x(block_min_x),
        .v1_y(block_min_y),
        .v1_z(block_min_z),
        .v2_x(e_x_data),
        .v2_y(e_y_data),
        .v2_z(e_z_data),
        .v_valid(block_min_valid),

        .res_data_x(min_e_x),
        .res_data_y(min_e_y),
        .res_data_z(min_e_z),
        .res_valid(min_e_valid)
    );

    vec_sub max_e_sub(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .v1_x(block_max_x),
        .v1_y(block_max_y),
        .v1_z(block_max_z),
        .v2_x(e_x_data),
        .v2_y(e_y_data),
        .v2_z(e_z_data),
        .v_valid(block_min_valid),

        .res_data_x(max_e_x),
        .res_data_y(max_e_y),
        .res_data_z(max_e_z)
    );

    // stage 2, verified

    // pipelining the ray: add (11) and sub (11), verified
    localparam RAY_DELAY = 22;
    logic [31:0] ray_x_pipe [RAY_DELAY-1:0];
    logic [31:0] ray_y_pipe [RAY_DELAY-1:0];
    logic [31:0] ray_z_pipe [RAY_DELAY-1:0];

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            for(int i=0; i<RAY_DELAY; i = i+1) begin
                ray_x_pipe[i] <= 0;
                ray_y_pipe[i] <= 0;
                ray_z_pipe[i] <= 0;
            end
        end else begin
            ray_x_pipe[0] <= ray_x;
            ray_y_pipe[0] <= ray_y;
            ray_z_pipe[0] <= ray_z;
            for (int i=1; i<RAY_DELAY; i = i+1) begin
                ray_x_pipe[i] <= ray_x_pipe[i-1];
                ray_y_pipe[i] <= ray_y_pipe[i-1];
                ray_z_pipe[i] <= ray_z_pipe[i-1];
            end
        end
    end

    vec_divide tx1_divide(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .v1_x(min_e_x),
        .v1_y(min_e_y),
        .v1_z(min_e_z),
        .v2_x(ray_x_pipe[RAY_DELAY-1]),
        .v2_y(ray_y_pipe[RAY_DELAY-1]),
        .v2_z(ray_z_pipe[RAY_DELAY-1]),
        .v_valid(min_e_valid),

        .res_data_x(tx1_x),
        .res_data_y(tx1_y),
        .res_data_z(tx1_z),
        .res_valid(tx1_valid)
    );

    vec_divide tx2_divide(
        .clk_in(clk_in),
        .rst_in(rst_in),
        .v1_x(max_e_x),
        .v1_y(max_e_y),
        .v1_z(max_e_z),
        .v2_x(ray_x_pipe[RAY_DELAY-1]),
        .v2_y(ray_y_pipe[RAY_DELAY-1]),
        .v2_z(ray_z_pipe[RAY_DELAY-1]),
        .v_valid(min_e_valid),

        .res_data_x(tx2_x),
        .res_data_y(tx2_y),
        .res_data_z(tx2_z)
    );

    // stage 3, verified
    
    vec_less_than min_tx12_lt(
        .clk_in(clk_in),
        .rst_in(rst_in),

        .a_x(tx1_x),
        .a_y(tx1_y),
        .a_z(tx1_z),

        .b_x(tx2_x),
        .b_y(tx2_y),
        .b_z(tx2_z),
        .v_valid(tx1_valid),

        .res_data_x(min_tx12_lt_x),
        .res_data_y(min_tx12_lt_y),
        .res_data_z(min_tx12_lt_z),
        .res_valid(min_tx12_lt_valid)
    );
    
    vec_less_than max_tx12_lt(
        .clk_in(clk_in),
        .rst_in(rst_in),

        .a_x(tx2_x),
        .a_y(tx2_y),
        .a_z(tx2_z),

        .b_x(tx1_x),
        .b_y(tx1_y),
        .b_z(tx1_z),
        .v_valid(tx1_valid),

        .res_data_x(max_tx12_lt_x),
        .res_data_y(max_tx12_lt_y),
        .res_data_z(max_tx12_lt_z)
    );

    // stage 4

    // pipeline tx1, tx2: less than (2), verified
    localparam TX12_DELAY = 2;
    logic [31:0] tx1_x_pipe [TX12_DELAY-1:0];
    logic [31:0] tx1_y_pipe [TX12_DELAY-1:0];
    logic [31:0] tx1_z_pipe [TX12_DELAY-1:0];
    logic [31:0] tx2_x_pipe [TX12_DELAY-1:0];
    logic [31:0] tx2_y_pipe [TX12_DELAY-1:0];
    logic [31:0] tx2_z_pipe [TX12_DELAY-1:0];

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            for(int i=0; i<TX12_DELAY; i = i+1) begin
                tx1_x_pipe[i] <= 0;
                tx1_y_pipe[i] <= 0;
                tx1_z_pipe[i] <= 0;
                tx2_x_pipe[i] <= 0;
                tx2_y_pipe[i] <= 0;
                tx2_z_pipe[i] <= 0;
            end
        end else begin
            tx1_x_pipe[0] <= tx1_x;
            tx1_y_pipe[0] <= tx1_y;
            tx1_z_pipe[0] <= tx1_z;
            tx2_x_pipe[0] <= tx2_x;
            tx2_y_pipe[0] <= tx2_y;
            tx2_z_pipe[0] <= tx2_z;
            for (int i=1; i<TX12_DELAY; i = i+1) begin
                tx1_x_pipe[i] <= tx1_x_pipe[i-1];
                tx1_y_pipe[i] <= tx1_y_pipe[i-1];
                tx1_z_pipe[i] <= tx1_z_pipe[i-1];
                tx2_x_pipe[i] <= tx2_x_pipe[i-1];
                tx2_y_pipe[i] <= tx2_y_pipe[i-1];
                tx2_z_pipe[i] <= tx2_z_pipe[i-1];
            end
        end
    end

    vec_comp tx12_min_select_comp(
        .clk_in(clk_in),
        .rst_in(rst_in),

        .v1_x(tx1_x_pipe[TX12_DELAY-1]),
        .v1_y(tx1_y_pipe[TX12_DELAY-1]),
        .v1_z(tx1_z_pipe[TX12_DELAY-1]),
        .v2_x(tx2_x_pipe[TX12_DELAY-1]),
        .v2_y(tx2_y_pipe[TX12_DELAY-1]),
        .v2_z(tx2_z_pipe[TX12_DELAY-1]),
        .comp_x(min_tx12_lt_x),
        .comp_y(min_tx12_lt_y),
        .comp_z(min_tx12_lt_z),
        .v_valid(min_tx12_lt_valid),

        .res_data_x(tx12_min_select_x),
        .res_data_y(tx12_min_select_y),
        .res_data_z(tx12_min_select_z),
        .res_valid(tx12_min_select_valid)
    );

    vec_comp tx12_max_select_comp(
        .clk_in(clk_in),
        .rst_in(rst_in),

        .v1_x(tx1_x_pipe[TX12_DELAY-1]),
        .v1_y(tx1_y_pipe[TX12_DELAY-1]),
        .v1_z(tx1_z_pipe[TX12_DELAY-1]),
        .v2_x(tx2_x_pipe[TX12_DELAY-1]),
        .v2_y(tx2_y_pipe[TX12_DELAY-1]),
        .v2_z(tx2_z_pipe[TX12_DELAY-1]),
        .comp_x(max_tx12_lt_x),
        .comp_y(max_tx12_lt_y),
        .comp_z(max_tx12_lt_z),
        .v_valid(min_tx12_lt_valid),

        .res_data_x(tx12_max_select_x),
        .res_data_y(tx12_max_select_y),
        .res_data_z(tx12_max_select_z)
    );

    //stage 5

    vec_max tmin_max(
        .clk_in(clk_in),
        .rst_in(rst_in),

        .v_x(tx12_min_select_x),
        .v_y(tx12_min_select_y),
        .v_z(tx12_min_select_z),
        .v_valid(tx12_min_select_valid),

        .res_data(tmin),
        .res_valid(tmin_valid)
    );

    vec_min tmax_min(
        .clk_in(clk_in),
        .rst_in(rst_in),

        .v_x(tx12_max_select_x),
        .v_y(tx12_max_select_y),
        .v_z(tx12_max_select_z),
        .v_valid(tx12_min_select_valid),

        .res_data(tmax)
    );

    //stage 6

    // pipeline tmin: delay of lte
    localparam TMIN_DELAY = 2;
    logic [31:0] tmin_pipe [TMIN_DELAY-1:0];

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            for(int i=0; i<TMIN_DELAY; i = i+1) begin
                tmin_pipe[i] <= 0;
            end
        end else begin
            tmin_pipe[0] <= tmin;
            for (int i=1; i<TMIN_DELAY; i = i+1) begin
                tmin_pipe[i] <= tmin_pipe[i-1];
            end
        end
    end

    assign t_out = intersects_data_out ? tmin_pipe[TMIN_DELAY-1] : 0;

    float_less_than_equal intersects_lte(
        .clk_in(clk_in),
        .rst_in(rst_in),

        .a(tmin),
        .b(tmax),
        .v_valid(tmin_valid),

        .res_data(intersects_data_out),
        .res_valid(valid_out)
    );
endmodule

`default_nettype wire