`timescale 1ns / 1ps
`default_nettype none

/*

Use this in block_selector
to get the block that intersects with
a particular XY position

*/
module get_intersecting_block(
    input wire clk_in,
    input wire rst_in,

    input wire [10:0] x_in,
    input wire [9:0] y_in,

    input wire [11:0] [11:0] block_x_notfloat_in,
    input wire [11:0] [11:0] block_y_notfloat_in,
    input wire [11:0] [13:0] block_z_notfloat_in,
    input wire valid_in,

    output logic [10:0] x_out,
    output logic [9:0] y_out,
    output logic [31:0] ray_out_x,
    output logic [31:0] ray_out_y,
    output logic [31:0] ray_out_z,
    output logic [3:0] best_block,
    output logic [31:0] best_t,
    output logic valid_out
    ); 

    ////////////////////////////////////////////////////
    // VARIABLE DEFINITIONS
    //
    // logic variables go here
    //

    //TODO: the full 12 is quite time intensive to build, think about possible pipelining tricks?
    localparam NUM_OF_BLOCKS = 4;

    // stage -1

    logic [NUM_OF_BLOCKS-1:0] [31:0] block_x_in;
    logic [NUM_OF_BLOCKS-1:0] [31:0] block_y_in;
    logic [NUM_OF_BLOCKS-1:0] [31:0] block_z_in;

    logic [NUM_OF_BLOCKS-1:0] block_x_in_valid;

    // stage 0

    logic [31:0] ray_x;
    logic [31:0] ray_y;
    logic [31:0] ray_z;
    logic ray_valid;

    // stage 1

    logic [31:0] t [11:0];
    logic ray_block_intersect [11:0];
    logic ray_block_intersect_valid [11:0];

    // stage 2

    ////////////////////////////////////////////////////
    // LOGIC
    //
    // module logic chain
    //

    // stage -1: convert to float

    generate
        for(genvar i = 0; i < NUM_OF_BLOCKS; i = i + 1) begin
            floating_point_sint32_to_float ex_to_float(
                .aclk(clk_in),
                .aresetn(~rst_in),
                .s_axis_a_tvalid(valid_in),
                .s_axis_a_tdata({20'b0, block_x_notfloat_in[i]}),
                .m_axis_result_tdata(block_x_in[i]),
                .m_axis_result_tvalid(block_x_in_valid[i])
            );
            floating_point_sint32_to_float ey_to_float(
                .aclk(clk_in),
                .aresetn(~rst_in),
                .s_axis_a_tvalid(valid_in),
                .s_axis_a_tdata({20'b0, block_y_notfloat_in[i]}),
                .m_axis_result_tdata(block_y_in[i]),
                .m_axis_result_tvalid()
            );
            floating_point_sint32_to_float ez_to_float(
                .aclk(clk_in),
                .aresetn(~rst_in),
                .s_axis_a_tvalid(valid_in),
                .s_axis_a_tdata({18'b0, block_z_notfloat_in[i]}),
                .m_axis_result_tdata(block_z_in[i]),
                .m_axis_result_tvalid()
            );
        end
    endgenerate

    // stage 0

    // pipeline x_in, y_in
    localparam XY_DELAY = 182;
    localparam XY_DELAY_0 = 6;
    logic [10:0] x_in_pipe [XY_DELAY-1:0];
    logic [9:0] y_in_pipe [XY_DELAY-1:0];

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            for(int i=0; i<XY_DELAY; i = i+1) begin
                x_in_pipe[i] <= 0;
                y_in_pipe[i] <= 0;
            end
        end else begin
            x_in_pipe[0] <= x_in;
            y_in_pipe[0] <= y_in;
            for (int i=1; i<XY_DELAY; i = i+1) begin
                x_in_pipe[i] <= x_in_pipe[i-1];
                y_in_pipe[i] <= y_in_pipe[i-1];
            end
        end
    end

    eye_to_pixel eye_to_pixel(
        .clk_in(clk_in),
        .rst_in(rst_in),

        .x_in(x_in_pipe[XY_DELAY_0-1]),
        .y_in(y_in_pipe[XY_DELAY_0-1]),
        .valid_in(block_x_in_valid[0]),

        .dir_x(ray_x),
        .dir_y(ray_y),
        .dir_z(ray_z),
        .dir_valid(ray_valid)
    );

    // always_ff @(posedge clk_in) begin
    //     if (block_x_in_valid[0]) begin
    //         // $display("XY IS VALID: (%d, %d)", x_in_pipe[XY_DELAY-1], x_in_pipe[XY_DELAY-1]);
    //         // for (int i = 0; i < 2; i = i + 1) begin
    //         //     $display("BLOCK FLOAT %d: %d=%b, %d=%b, %d=%b", i, block_x_notfloat_in[i], block_x_in[i], block_y_notfloat_in[i], block_y_in[i], block_z_notfloat_in[i], block_z_in[i]);
    //         // end
    //     end
    //     if(ray_valid) begin
    //         $display("VALID RAY %b %b %b", ray_x, ray_y, ray_z);
    //     end
    //     for(int i = 0; i < NUM_OF_BLOCKS; i = i + 1) begin
    //         if(ray_block_intersect_valid[i]) begin
    //             $display("INTERSECT_VALID i=%d: %b AND %b", i, ray_block_intersect[i], t[i]);
    //         end
    //     end
    // end

    // stage 1

    generate
        for(genvar i = 0; i < NUM_OF_BLOCKS; i = i + 1) begin
            // TODO: need to pipeline block_x_in, y, z
            // maybe not for now bc we can assume it does not change much over time
            does_ray_block_intersect does_ray_block_intersect(
                .clk_in(clk_in),
                .rst_in(rst_in),
                
                .ray_x(ray_x),
                .ray_y(ray_y),
                .ray_z(ray_z),
                .block_pos_x(block_x_in[i]),
                .block_pos_y(block_y_in[i]),
                .block_pos_z(block_z_in[i]),
                .valid_in(ray_valid),

                .intersects_data_out(ray_block_intersect[i]),
                .t_out(t[i]),
                .valid_out(ray_block_intersect_valid[i])
            );
        end
    endgenerate

    // stage 2

    // pipeline ray by does_ray_block_intersect (add, add, divide, lt, comp, max, lt): 11 + 11 + 28 + 2 + 2 + 3 + 2 = 59
    localparam RAY_DELAY = 58;
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

    localparam MAX_BLOCK_INDEX = 15;

    logic [3:0] best_block_comb;
    logic [31:0] best_t_comb;

    always_comb begin
        if(ray_block_intersect_valid[0]) begin
            best_t_comb = 32'b10111111100000000000000000000000;
            best_block_comb = MAX_BLOCK_INDEX; // above max value

            for(int i = NUM_OF_BLOCKS - 1; i >= 0; i = i - 1) begin
                if(ray_block_intersect[i]) begin
                    best_t_comb = t[i];
                    best_block_comb = i;
                end
            end
        end else begin
            best_t_comb = 32'b0;
            best_block_comb = MAX_BLOCK_INDEX;
        end
    end

    assign x_out = x_in_pipe[XY_DELAY-1];
    assign y_out = y_in_pipe[XY_DELAY-1];

    always_ff @(posedge clk_in) begin
        if(~rst_in) begin
            valid_out <= ray_block_intersect_valid[0];
            best_block <= best_block_comb;
            best_t <= best_t_comb;

            ray_out_x <= ray_x_pipe[RAY_DELAY-1];
            ray_out_y <= ray_y_pipe[RAY_DELAY-1];
            ray_out_z <= ray_z_pipe[RAY_DELAY-1];
        end
    end
endmodule

`default_nettype wire