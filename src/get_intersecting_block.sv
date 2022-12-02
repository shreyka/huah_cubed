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

    // WARNING: THIS MUST BE IN FLOAT FORM
    input wire [11:0] [31:0] block_x_in,
    input wire [11:0] [31:0] block_y_in,
    input wire [11:0] [31:0] block_z_in,
    input wire valid_in,

    output logic [31:0] ray_out_x,
    output logic [31:0] ray_out_y,
    output logic [31:0] ray_out_z,
    output logic [11:0] best_block,
    output logic [31:0] best_t,
    output logic valid_out
    ); 

    ////////////////////////////////////////////////////
    // VARIABLE DEFINITIONS
    //
    // logic variables go here
    //

    // stage 0

    logic [31:0] ray_x;
    logic [31:0] ray_y;
    logic [31:0] ray_z;
    logic ray_valid;

    // stage 1

    logic [31:0] t [11:0];
    logic ray_block_intersect [11:0];
    logic ray_block_intersect_valid [11:0];

    //TODO: the full 12 is quite time intensive to build, think about possible pipelining tricks?
    localparam NUM_OF_BLOCKS = 4;

    // stage 2

    ////////////////////////////////////////////////////
    // LOGIC
    //
    // module logic chain
    //

    // stage 0

    eye_to_pixel eye_to_pixel(
        .clk_in(clk_in),
        .rst_in(rst_in),

        .x_in(x_in),
        .y_in(y_in),
        .valid_in(valid_in),

        .dir_x(ray_x),
        .dir_y(ray_y),
        .dir_z(ray_z),
        .dir_valid(ray_valid)
    );

    always_ff @(posedge clk_in) begin
        if(ray_valid) begin
            $display("VALID RAY %b %b %b", ray_x, ray_y, ray_z);
        end
        for(int i = 0; i < NUM_OF_BLOCKS; i = i + 1) begin
            if(ray_block_intersect_valid[i]) begin
                $display("INTERSECT_VALID i=%d: %b AND %b", i, ray_block_intersect[i], t[i]);
            end
        end
    end

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

    localparam MAX_BLOCK_INDEX = 256;

    logic [11:0] best_block_comb;
    logic [31:0] best_t_comb;

    always_comb begin
        best_t_comb = 32'b10111111100000000000000000000000;
        best_block_comb = MAX_BLOCK_INDEX; // above max value

        for(int i = NUM_OF_BLOCKS - 1; i >= 0; i = i - 1) begin
            if(ray_block_intersect[i]) begin
                best_t_comb = t[i];
                best_block_comb = i;
            end
        end
    end

    always_ff @(posedge clk_in) begin
        if(~rst_in) begin
            valid_out <= ray_block_intersect_valid[0];

            best_block <= best_block_comb;
            best_t <= best_t_comb;

            // TODO: pipeline ray
            ray_out_x <= ray_x;
            ray_out_y <= ray_y;
            ray_out_z <= ray_z;
        end
    end
endmodule

`default_nettype wire