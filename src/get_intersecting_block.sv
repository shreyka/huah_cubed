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

    input wire [3:0] block_index_in,
    input wire [11:0] block_x_notfloat_in,
    input wire [11:0] block_y_notfloat_in,
    input wire [13:0] block_z_notfloat_in,
    input wire [31:0] head_x_float,
    input wire [31:0] head_y_float,
    input wire [31:0] head_z_float,
    input wire block_visible_in,

    input wire valid_in,

    output logic [10:0] x_out,
    output logic [9:0] y_out,
    output logic [31:0] ray_out_x,
    output logic [31:0] ray_out_y,
    output logic [31:0] ray_out_z,
    output logic [3:0] block_index_out,
    output logic ray_block_intersect_out,
    output logic [31:0] best_t,
    output logic valid_out
    ); 

    ////////////////////////////////////////////////////
    // VARIABLE DEFINITIONS
    //
    // logic variables go here
    //

    // stage -1

    logic [31:0] block_x_in;
    logic [31:0] block_y_in;
    logic [31:0] block_z_in;
    logic block_x_in_valid;

    // stage 0

    logic [31:0] ray_x;
    logic [31:0] ray_y;
    logic [31:0] ray_z;
    logic ray_valid;

    // stage 1

    logic [31:0] t;
    logic ray_block_intersect;
    logic ray_block_intersect_valid;

    // stage 2

    ////////////////////////////////////////////////////
    // LOGIC
    //
    // module logic chain
    //

    // stage -1: convert to float

    floating_point_sint32_to_float ex_to_float(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tvalid(valid_in),
        .s_axis_a_tdata({20'b0, block_x_notfloat_in}),
        .m_axis_result_tdata(block_x_in),
        .m_axis_result_tvalid(block_x_in_valid)
    );
    floating_point_sint32_to_float ey_to_float(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tvalid(valid_in),
        .s_axis_a_tdata({20'b0, block_y_notfloat_in}),
        .m_axis_result_tdata(block_y_in),
        .m_axis_result_tvalid()
    );
    floating_point_sint32_to_float ez_to_float(
        .aclk(clk_in),
        .aresetn(~rst_in),
        .s_axis_a_tvalid(valid_in),
        .s_axis_a_tdata({18'b0, block_z_notfloat_in}),
        .m_axis_result_tdata(block_z_in),
        .m_axis_result_tvalid()
    );

    // stage 0

    // pipeline x_in, y_in
    localparam XY_DELAY = 182 + 5; //verified
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

    eye_to_pixel eye_to_pixel( //117 + 5
        .clk_in(clk_in),
        .rst_in(rst_in),

        .x_in(x_in_pipe[XY_DELAY_0-1]),
        .y_in(y_in_pipe[XY_DELAY_0-1]),
        .head_x_float(head_x_float),
        .head_y_float(head_y_float),
        .head_z_float(head_z_float),
        .valid_in(block_x_in_valid),

        .dir_x(ray_x),
        .dir_y(ray_y),
        .dir_z(ray_z),
        .dir_valid(ray_valid)
    );

    // logic [31:0] i;
    // always_ff @(posedge clk_in) begin
    //     if(rst_in) begin
    //         i <= 0;
    //     end else begin
    //         i <= i + 1;
    //         if(block_x_in_valid) begin
    //             $display("%d: go into eye", i);
    //         end else if(ray_valid) begin
    //             $display("%d: leave eye", i);
    //         end
    //     end
    // end

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

    localparam BLOCK_DELAY = 111 + 6 + 5; // verified
    logic [31:0] block_x_pipe [BLOCK_DELAY-1:0];
    logic [31:0] block_y_pipe [BLOCK_DELAY-1:0];
    logic [31:0] block_z_pipe [BLOCK_DELAY-1:0];

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            for(int i=0; i<BLOCK_DELAY; i = i+1) begin
                block_x_pipe[i] <= 0;
                block_y_pipe[i] <= 0;
                block_z_pipe[i] <= 0;
            end
        end else begin
            block_x_pipe[0] <= block_x_in;
            block_y_pipe[0] <= block_y_in;
            block_z_pipe[0] <= block_z_in;
            for (int i=1; i<BLOCK_DELAY; i = i+1) begin
                block_x_pipe[i] <= block_x_pipe[i-1];
                block_y_pipe[i] <= block_y_pipe[i-1];
                block_z_pipe[i] <= block_z_pipe[i-1];
            end
        end
    end

    // always_ff @(posedge clk_in) begin
    //     if(ray_valid) begin
    //         $display("X IS %b", block_x_pipe[BLOCK_DELAY-1]);
    //     end else begin
    //         $display("INVALID X IS %b", block_x_pipe[BLOCK_DELAY-1]);
    //     end
    // end

    // logic [31:0] i;
    // always_ff @(posedge clk_in) begin
    //     if(rst_in) begin
    //         i <= 0;
    //     end else begin
    //         i <= i + 1;
    //         if(ray_valid) begin
    //             $display("%d: block_x_pipe: %b", i, block_x_pipe[BLOCK_DELAY-1]);
    //         end else begin
    //             $display("%d: invalid block_x_pipe: %b", i, block_x_pipe[BLOCK_DELAY-1]);
    //         end
    //     end
    // end

    // this is for the output, but also used in does_ray_block_intersect
    localparam BLOCK_VISIBLE_DELAY = 181 + 5; // verified
    logic block_visible_pipe [BLOCK_VISIBLE_DELAY-1:0];
    logic [3:0] block_index_pipe [BLOCK_VISIBLE_DELAY-1:0];
    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            for(int i=0; i<BLOCK_VISIBLE_DELAY; i = i+1) begin
                block_visible_pipe[i] <= 0;
                block_index_pipe[i] <= 0;
            end
        end else begin
            block_visible_pipe[0] <= block_visible_in;
            block_index_pipe[0] <= block_index_in;
            for (int i=1; i<BLOCK_VISIBLE_DELAY; i = i+1) begin
                block_visible_pipe[i] <= block_visible_pipe[i-1];
                block_index_pipe[i] <= block_index_pipe[i-1];
            end
        end
    end

    // always_ff @(posedge clk_in) begin
    //     if(ray_valid) begin
    //         $display("BLOCK_Z %b", block_z_pipe[BLOCK_DELAY-1]);
    //         $display("ray_x %b", ray_x);
    //         $display("block_index %d", block_index_pipe[BLOCK_DELAY-1+6]);
    //     end
    // end

    does_ray_block_intersect does_ray_block_intersect(
        .clk_in(clk_in),
        .rst_in(rst_in),
        
        .ray_x(ray_x),
        .ray_y(ray_y),
        .ray_z(ray_z),
        .block_pos_x(block_x_pipe[BLOCK_DELAY-1]),
        .block_pos_y(block_y_pipe[BLOCK_DELAY-1]),
        .block_pos_z(block_z_pipe[BLOCK_DELAY-1]),
        .head_x_float(head_x_float),
        .head_y_float(head_y_float),
        .head_z_float(head_z_float),
        .is_saber(block_index_pipe[BLOCK_DELAY-1+6] == 12 ? 1'b1 : 1'b0), //the +6 was empirically tested and verified, not sure why it is needed
        .valid_in(ray_valid),

        .intersects_data_out(ray_block_intersect),
        .t_out(t),
        .valid_out(ray_block_intersect_valid)
    );

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

    assign x_out = x_in_pipe[XY_DELAY-1];
    assign y_out = y_in_pipe[XY_DELAY-1];

    // logic [31:0] j;
    // always_ff @(posedge clk_in) begin
    //     if(rst_in) begin
    //         j <= 0;
    //     end else begin
    //         j <= j + 1;
    //         if(ray_block_intersect_valid) begin
    //             $display("%d: visible: %b", j, block_visible_pipe[BLOCK_VISIBLE_DELAY-1]);
    //         end else begin
    //             $display("%d: invalid visible: %b", j, block_visible_pipe[BLOCK_VISIBLE_DELAY-1]);
    //         end
    //     end
    // end

    always_ff @(posedge clk_in) begin
        if(~rst_in) begin
            valid_out <= ray_block_intersect_valid;
            ray_block_intersect_out <= ray_block_intersect && block_visible_pipe[BLOCK_VISIBLE_DELAY-1];
            best_t <= t;
            block_index_out <= block_index_pipe[BLOCK_VISIBLE_DELAY-1];

            ray_out_x <= ray_x_pipe[RAY_DELAY-1];
            ray_out_y <= ray_y_pipe[RAY_DELAY-1];
            ray_out_z <= ray_z_pipe[RAY_DELAY-1];
        end
    end
endmodule

`default_nettype wire