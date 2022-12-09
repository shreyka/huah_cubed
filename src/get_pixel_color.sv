`timescale 1ns / 1ps
`default_nettype none

/*

Given a block position and ray position,
as well as t, return the RGB value of the
collision.

*/
module get_pixel_color(
    input wire clk_in,
    input wire rst_in,

    input wire [31:0] block_pos_x,
    input wire [31:0] block_pos_y,
    input wire [31:0] block_pos_z,
    input wire [2:0] block_color,
    input wire [2:0] block_dir,
    input wire valid_in,

    input wire [31:0] ray_x,
    input wire [31:0] ray_y,
    input wire [31:0] ray_z,

    input wire [31:0] t_in,

    output logic [31:0] r_out,
    output logic [31:0] g_out,
    output logic [31:0] b_out,
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

    logic [31:0] e_x_data, e_y_data, e_z_data;

    assign e_x_data = 32'b01000100111000010000000000000001; //1800.0001
    assign e_y_data = 32'b01000100111000010000000000000001; //1800.0001
    assign e_z_data = 32'b11000011100101100000000000000011; //-300.0001

    logic [31:0] lights_pos_x [2:0];
    logic [31:0] lights_pos_y [2:0];
    logic [31:0] lights_pos_z [2:0];
    logic [31:0] lights_intense_x [2:0];
    logic [31:0] lights_intense_y [2:0];
    logic [31:0] lights_intense_z [2:0];

    assign lights_pos_x[0] = 32'b01000100101011110000000000000000; //1400
    assign lights_pos_y[0] = 32'b01000100111000010000000000000000; //1800
    assign lights_pos_z[0] = 32'b01000010110010000000000000000000; //100
    assign lights_pos_x[1] = 32'b01000100111000010000000000000000; //1800
    assign lights_pos_y[1] = 32'b01000100111000010000000000000000; //1800
    assign lights_pos_z[1] = 32'b01000010110010000000000000000000; //100
    assign lights_pos_x[2] = 32'b01000101000010011000000000000000; //2200
    assign lights_pos_y[2] = 32'b01000100111000010000000000000000; //1800
    assign lights_pos_z[2] = 32'b01000010110010000000000000000000; //100

    assign lights_intense_x[0] = 32'b00111110100000000000000000000000; //0.25
    assign lights_intense_y[0] = 32'b00111111000000000000000000000000; //0.5
    assign lights_intense_z[0] = 32'b00111110100000000000000000000000; //0.25
    assign lights_intense_x[1] = 32'b00111111010000000000000000000000; //0.75
    assign lights_intense_y[1] = 32'b00111111000000000000000000000000; //0.5
    assign lights_intense_z[1] = 32'b00111111010000000000000000000000; //0.75
    assign lights_intense_x[2] = 32'b00111110100000000000000000000000; //0.25
    assign lights_intense_y[2] = 32'b00111111000000000000000000000000; //0.5
    assign lights_intense_z[2] = 32'b00111110100000000000000000000000; //0.25

    ////////////////////////////////////////////////////
    // VARIABLE DEFINITIONS
    //
    // logic variables go here
    //

    // stage 0
    logic [31:0] scaled_ray_x, scaled_ray_y, scaled_ray_z;
    logic scaled_ray_valid;

    // stage 1-0
    logic should_render_arrow;
    logic should_render_arrow_valid;
    
    // stage 1-1
    logic [31:0] new_origin_x, new_origin_y, new_origin_z;
    logic new_origin_valid;

    // stage 2
    logic [31:0] normal_sub_x, normal_sub_y, normal_sub_z;
    logic normal_sub_valid;

    // stage 3
    // logic [31:0] normal_add_x, normal_add_y, normal_add_z;
    // logic normal_add_valid;
    
    // stage 4
    logic [31:0] normal_x, normal_y, normal_z;
    logic normal_valid;

    // stage 5
    logic [31:0] r_light [2:0];
    logic [31:0] g_light [2:0];
    logic [31:0] b_light [2:0];
    logic r_light_valid [2:0];

    // ASSUMPTION: 3 lights exist
    // stage 5-1
    logic [31:0] dist_x [2:0];
    logic [31:0] dist_y [2:0];
    logic [31:0] dist_z [2:0];
    logic dist_valid [2:0];
    
    // stage 5-2
    logic [31:0] ray_dir_x [2:0];
    logic [31:0] ray_dir_y [2:0];
    logic [31:0] ray_dir_z [2:0];
    logic ray_dir_valid [2:0];
    
    // stage 5-3
    logic [31:0] lambert [2:0];
    logic lambert_valid [2:0];
    
    // stage 5-4
    logic [31:0] light_intense_mat_mult_x [2:0];
    logic [31:0] light_intense_mat_mult_y [2:0];
    logic [31:0] light_intense_mat_mult_z [2:0];
    logic light_intense_mat_mult_valid [2:0];

    // stage 5-5
    logic [31:0] lambert_scale_x [2:0];
    logic [31:0] lambert_scale_y [2:0];
    logic [31:0] lambert_scale_z [2:0];
    logic lambert_scale_valid [2:0];
    
    // stage 6
    logic [31:0] r_total_0, g_total_0, b_total_0;
    logic r_total_0_valid;
    logic [31:0] r_total, g_total, b_total;
    logic r_total_valid;
    
    
    // stage 7
    logic [31:0] min_rgb;
    logic min_rgb_valid;
    
    ////////////////////////////////////////////////////
    // LOGIC
    //
    // module logic chain
    //

    // stage 0

    vec_scale ray_vec_scale( //verified
        .clk_in(clk_in),
        .rst_in(rst_in),
        .v_x(ray_x),
        .v_y(ray_y),
        .v_z(ray_z),
        .c(t_in),
        .v_valid(valid_in),

        .res_data_x(scaled_ray_x),
        .res_data_y(scaled_ray_y),
        .res_data_z(scaled_ray_z),
        .res_valid(scaled_ray_valid)
    );

    // stage 1
    // stage 1-0
    
    //todo: should pipeline block_pos, block_dir
    localparam BLOCK_POS_DIR_DELAY = 19;
    localparam BLOCK_POS_DIR_DELAY_0 = 8;
    logic [31:0] block_pos_x_pipe [BLOCK_POS_DIR_DELAY-1:0];
    logic [31:0] block_pos_y_pipe [BLOCK_POS_DIR_DELAY-1:0];
    logic [31:0] block_pos_z_pipe [BLOCK_POS_DIR_DELAY-1:0];
    logic [2:0] block_dir_pipe [BLOCK_POS_DIR_DELAY-1:0];

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            for(int i=0; i<BLOCK_POS_DIR_DELAY; i = i+1) begin
                block_pos_x_pipe[i] <= 0;
                block_pos_y_pipe[i] <= 0;
                block_pos_z_pipe[i] <= 0;
                block_dir_pipe[i] <= 0;
            end
        end else begin
            block_pos_x_pipe[0] <= block_pos_x;
            block_pos_y_pipe[0] <= block_pos_y;
            block_pos_z_pipe[0] <= block_pos_z;
            block_dir_pipe[0] <= block_dir;
            for (int i=1; i<BLOCK_POS_DIR_DELAY; i = i+1) begin
                block_pos_x_pipe[i] <= block_pos_x_pipe[i-1];
                block_pos_y_pipe[i] <= block_pos_y_pipe[i-1];
                block_pos_z_pipe[i] <= block_pos_z_pipe[i-1];
                block_dir_pipe[i] <= block_dir_pipe[i-1];
            end
        end
    end

    get_pixel_color_should_draw_arrow should_render_arrow_mod(
        .clk_in(clk_in),
        .rst_in(rst_in),

        .block_pos_x(block_pos_x_pipe[BLOCK_POS_DIR_DELAY_0-1]),
        .block_pos_y(block_pos_y_pipe[BLOCK_POS_DIR_DELAY_0-1]),
        .block_pos_z(block_pos_z_pipe[BLOCK_POS_DIR_DELAY_0-1]),
        .block_dir(block_dir_pipe[BLOCK_POS_DIR_DELAY_0-1]),
        .scaled_ray_x(scaled_ray_x),
        .scaled_ray_y(scaled_ray_y),
        .scaled_ray_z(scaled_ray_z),
        .valid_in(scaled_ray_valid),

        .should_render_arrow(should_render_arrow),
        .should_render_arrow_valid(should_render_arrow_valid)
    );

    // always_ff @(posedge clk_in) begin
    //     if(should_render_arrow_valid) begin
    //         $display("SHOULD_RENDER? %d", should_render_arrow);
    //     end
    // end

    vec_add new_origin_add( //verified up to here
        .clk_in(clk_in),
        .rst_in(rst_in),
        .v1_x(e_x_data),
        .v1_y(e_y_data),
        .v1_z(e_z_data),
        .v2_x(scaled_ray_x),
        .v2_y(scaled_ray_y),
        .v2_z(scaled_ray_z),
        .v_valid(scaled_ray_valid),

        .res_data_x(new_origin_x),
        .res_data_y(new_origin_y),
        .res_data_z(new_origin_z),
        .res_valid(new_origin_valid)
    );

    // stage 2

    vec_sub normal_sub( //verified up to here
        .clk_in(clk_in),
        .rst_in(rst_in),
        .v1_x(new_origin_x),
        .v1_y(new_origin_y),
        .v1_z(new_origin_z),
        .v2_x(block_pos_x_pipe[BLOCK_POS_DIR_DELAY-1]),
        .v2_y(block_pos_y_pipe[BLOCK_POS_DIR_DELAY-1]),
        .v2_z(block_pos_z_pipe[BLOCK_POS_DIR_DELAY-1]),
        .v_valid(new_origin_valid),

        .res_data_x(normal_sub_x),
        .res_data_y(normal_sub_y),
        .res_data_z(normal_sub_z),
        .res_valid(normal_sub_valid)
    );

    // always_ff @(posedge clk_in) begin
    //     if(normal_sub_valid) begin
    //         $display("NORMAL_SUB %b %b %b", normal_sub_x, normal_sub_y, normal_sub_z);
    //     end
    // end

    // stage 3: SKIPPED
    // stage 4

    vec_normalize normalize_normal( //verified up to here
        .clk_in(clk_in),
        .rst_in(rst_in),
        .v_x(normal_sub_x),
        .v_y(normal_sub_y),
        .v_z(normal_sub_z),
        .v_valid(normal_sub_valid),

        .res_data_x(normal_x),
        .res_data_y(normal_y),
        .res_data_z(normal_z),
        .res_valid(normal_valid)
    );

    // stage 5

    //TEST STARTING HERE

    // pipeline new_origin: 81
    localparam NEW_ORIGIN_DELAY = 81;
    logic [31:0] new_origin_x_pipe [NEW_ORIGIN_DELAY-1:0];
    logic [31:0] new_origin_y_pipe [NEW_ORIGIN_DELAY-1:0];
    logic [31:0] new_origin_z_pipe [NEW_ORIGIN_DELAY-1:0];
    logic new_origin_valid_pipe [NEW_ORIGIN_DELAY-1:0];

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            for(int i=0; i<NEW_ORIGIN_DELAY; i = i+1) begin
                new_origin_x_pipe[i] <= 0;
                new_origin_y_pipe[i] <= 0;
                new_origin_z_pipe[i] <= 0;
                new_origin_valid_pipe[i] <= 0;
            end
        end else begin
            new_origin_x_pipe[0] <= new_origin_x;
            new_origin_y_pipe[0] <= new_origin_y;
            new_origin_z_pipe[0] <= new_origin_z;
            new_origin_valid_pipe[0] <= new_origin_valid;
            for (int i=1; i<NEW_ORIGIN_DELAY; i = i+1) begin
                new_origin_x_pipe[i] <= new_origin_x_pipe[i-1];
                new_origin_y_pipe[i] <= new_origin_y_pipe[i-1];
                new_origin_z_pipe[i] <= new_origin_z_pipe[i-1];
                new_origin_valid_pipe[i] <= new_origin_valid_pipe[i-1];
            end
        end
    end

    // pipeline normal: 81
    localparam NORMAL_DELAY = 81;
    logic [31:0] normal_x_pipe [NORMAL_DELAY-1:0];
    logic [31:0] normal_y_pipe [NORMAL_DELAY-1:0];
    logic [31:0] normal_z_pipe [NORMAL_DELAY-1:0];
    logic normal_valid_pipe [NORMAL_DELAY-1:0];

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            for(int i=0; i<NORMAL_DELAY; i = i+1) begin
                normal_x_pipe[i] <= 0;
                normal_y_pipe[i] <= 0;
                normal_z_pipe[i] <= 0;
                normal_valid_pipe[i] <= 0;
            end
        end else begin
            normal_x_pipe[0] <= normal_x;
            normal_y_pipe[0] <= normal_y;
            normal_z_pipe[0] <= normal_z;
            normal_valid_pipe[0] <= normal_valid;
            for (int i=1; i<NORMAL_DELAY; i = i+1) begin
                normal_x_pipe[i] <= normal_x_pipe[i-1];
                normal_y_pipe[i] <= normal_y_pipe[i-1];
                normal_z_pipe[i] <= normal_z_pipe[i-1];
                normal_valid_pipe[i] <= normal_valid_pipe[i-1];
            end
        end
    end

    // pipeline block_mat (scale, add, sub, normalize, sub, normalize, dot, multiply): 208 + 11 

    // always_ff @(posedge clk_in) begin
    //     $display("MAT IS %d", block_mat_x);
    // end

    localparam BLOCK_MAT_DELAY = 208 + 11;
    logic [2:0] block_color_pipe [BLOCK_MAT_DELAY-1:0];

    logic [31:0] block_mat_x, block_mat_y, block_mat_z;
    assign block_mat_x = block_color_pipe[BLOCK_MAT_DELAY-1] == RED ? 32'b00111111100000000000000000000000 : 32'b0;
    assign block_mat_y = 32'b0;
    assign block_mat_z = block_color_pipe[BLOCK_MAT_DELAY-1] == BLUE ? 32'b00111111100000000000000000000000 : 32'b0;

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            for(int i=0; i<BLOCK_MAT_DELAY; i = i+1) begin
                block_color_pipe[i] <= 0;
            end
        end else begin
            block_color_pipe[0] <= block_color;
            for (int i=1; i<BLOCK_MAT_DELAY; i = i+1) begin
                block_color_pipe[i] <= block_color_pipe[i-1];
            end
        end
    end

    generate
        for (genvar i = 0; i < 3; i = i + 1) begin
            // stage 5-1
            vec_sub dist_sub(
                .clk_in(clk_in),
                .rst_in(rst_in),
                .v1_x(lights_pos_x[i]),
                .v1_y(lights_pos_y[i]),
                .v1_z(lights_pos_z[i]),
                .v2_x(new_origin_x_pipe[NEW_ORIGIN_DELAY-1]),
                .v2_y(new_origin_y_pipe[NEW_ORIGIN_DELAY-1]),
                .v2_z(new_origin_z_pipe[NEW_ORIGIN_DELAY-1]),
                .v_valid(new_origin_valid_pipe[NEW_ORIGIN_DELAY-1]),

                .res_data_x(dist_x[i]),
                .res_data_y(dist_y[i]),
                .res_data_z(dist_z[i]),
                .res_valid(dist_valid[i])
            );

            // stage 5-2
            vec_normalize ray_dir_normalize(
                .clk_in(clk_in),
                .rst_in(rst_in),
                .v_x(dist_x[i]),
                .v_y(dist_y[i]),
                .v_z(dist_z[i]),
                .v_valid(dist_valid[i]),

                .res_data_x(ray_dir_x[i]),
                .res_data_y(ray_dir_y[i]),
                .res_data_z(ray_dir_z[i]),
                .res_valid(ray_dir_valid[i])
            );

            // stage 5-3
            vec_dot lambert_dot(
                .clk_in(clk_in),
                .rst_in(rst_in),
                .v1_x(ray_dir_x[i]),
                .v1_y(ray_dir_y[i]),
                .v1_z(ray_dir_z[i]),
                .v2_x(normal_x_pipe[NORMAL_DELAY-1]),
                .v2_y(normal_y_pipe[NORMAL_DELAY-1]),
                .v2_z(normal_z_pipe[NORMAL_DELAY-1]),
                .v_valid(ray_dir_valid[i]),

                .res_data(lambert[i]),
                .res_valid(lambert_valid[i])
            );

            // stage 5-4
            vec_multiply light_intense_mat_mult_multiply(
                .clk_in(clk_in),
                .rst_in(rst_in),
                .v1_x(lights_intense_x[i]),
                .v1_y(lights_intense_y[i]),
                .v1_z(lights_intense_z[i]),
                .v2_x(lambert[i]),
                .v2_y(lambert[i]),
                .v2_z(lambert[i]),
                .v_valid(lambert_valid[i]), 

                .res_data_x(light_intense_mat_mult_x[i]),
                .res_data_y(light_intense_mat_mult_y[i]),
                .res_data_z(light_intense_mat_mult_z[i]),
                .res_valid(light_intense_mat_mult_valid[i])
            ); //verified up to here

            // always_ff @(posedge clk_in) begin
            //     if(i == 0 && light_intense_mat_mult_valid[0]) begin
            //         $display("LIGHT_INTENSE %b %b %b", light_intense_mat_mult_x[0], light_intense_mat_mult_y[0], light_intense_mat_mult_z[0]);
            //     end
            // end

            always_ff @(posedge clk_in) begin
                if(i == 0 && light_intense_mat_mult_valid[0]) begin
                    // $display("LIGHT_INTENSE %b %b %b", light_intense_mat_mult_x[0], light_intense_mat_mult_y[0], light_intense_mat_mult_z[0]);
                    $display("MAT IS %d %d %d", block_mat_x, block_mat_y, block_mat_z);
                end
            end

            // stage 5-5
            vec_multiply lambert_scale_multiply(
                .clk_in(clk_in),
                .rst_in(rst_in),
                .v1_x(light_intense_mat_mult_x[i]),
                .v1_y(light_intense_mat_mult_y[i]),
                .v1_z(light_intense_mat_mult_z[i]),
                .v2_x(block_mat_x),
                .v2_y(block_mat_y),
                .v2_z(block_mat_z),
                .v_valid(light_intense_mat_mult_valid[i]), 

                .res_data_x(lambert_scale_x[i]),
                .res_data_y(lambert_scale_y[i]),
                .res_data_z(lambert_scale_z[i]),
                .res_valid(lambert_scale_valid[i])
            );
        end
    endgenerate

    // stage 6

    // pipeline lambert_scale: 11
    localparam LAMBERT_SCALE_DELAY = 11;
    logic [31:0] lambert_scale_x_pipe [LAMBERT_SCALE_DELAY-1:0];
    logic [31:0] lambert_scale_y_pipe [LAMBERT_SCALE_DELAY-1:0];
    logic [31:0] lambert_scale_z_pipe [LAMBERT_SCALE_DELAY-1:0];
    logic lambert_scale_valid_pipe [LAMBERT_SCALE_DELAY-1:0];

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            for(int i=0; i<LAMBERT_SCALE_DELAY; i = i+1) begin
                lambert_scale_x_pipe[i] <= 0;
                lambert_scale_y_pipe[i] <= 0;
                lambert_scale_z_pipe[i] <= 0;
                lambert_scale_valid_pipe[i] <= 0;
            end
        end else begin
            lambert_scale_x_pipe[0] <= lambert_scale_x[2];
            lambert_scale_y_pipe[0] <= lambert_scale_y[2];
            lambert_scale_z_pipe[0] <= lambert_scale_z[2];
            lambert_scale_valid_pipe[0] <= lambert_scale_valid[2];
            for (int i=1; i<LAMBERT_SCALE_DELAY; i = i+1) begin
                lambert_scale_x_pipe[i] <= lambert_scale_x_pipe[i-1];
                lambert_scale_y_pipe[i] <= lambert_scale_y_pipe[i-1];
                lambert_scale_z_pipe[i] <= lambert_scale_z_pipe[i-1];
                lambert_scale_valid_pipe[i] <= lambert_scale_valid_pipe[i-1];
            end
        end
    end

    // always_ff @(posedge clk_in) begin
    //     if(lambert_scale_valid[0]) begin
    //         $display("ORI-RGB-0 SCALE0 %h %h %h", lambert_scale_x[0], lambert_scale_x[1], lambert_scale_x[2]);
    //     end
    // end // i think this is verified

    vec_add r_total_0_add(
                .clk_in(clk_in),
                .rst_in(rst_in),
                .v1_x(lambert_scale_x[0]),
                .v1_y(lambert_scale_y[0]),
                .v1_z(lambert_scale_z[0]),
                .v2_x(lambert_scale_x[1]),
                .v2_y(lambert_scale_y[1]),
                .v2_z(lambert_scale_z[1]),
                .v_valid(lambert_scale_valid[0]),

                .res_data_x(r_total_0),
                .res_data_y(g_total_0),
                .res_data_z(b_total_0),
                .res_valid(r_total_0_valid)
            );
    
    // always_ff @(posedge clk_in) begin
    //     if(r_total_0_valid) begin
    //         $display("ORI-RGB-1 %h %h %h", r_total_0,g_total_0,b_total_0);
    //     end
    // end

    // stage 6-1
    vec_add r_total_add(
                .clk_in(clk_in),
                .rst_in(rst_in),
                .v1_x(r_total_0),
                .v1_y(g_total_0),
                .v1_z(b_total_0),
                .v2_x(lambert_scale_x_pipe[LAMBERT_SCALE_DELAY-1]),
                .v2_y(lambert_scale_y_pipe[LAMBERT_SCALE_DELAY-1]),
                .v2_z(lambert_scale_z_pipe[LAMBERT_SCALE_DELAY-1]),
                .v_valid(r_total_0_valid),

                .res_data_x(r_total),
                .res_data_y(g_total),
                .res_data_z(b_total),
                .res_valid(r_total_valid)
            );

    // always_ff @(posedge clk_in) begin
    //     if(r_total_valid) begin
    //         $display("ORI-RGB-2 %h %h %h", r_total,g_total,b_total);
    //     end
    // end // i think verified up to here

    // stage 7

    vec_max min_rgb_max(
        .clk_in(clk_in),
        .rst_in(rst_in),

        .v_x(r_total),
        .v_y(g_total),
        .v_z(b_total),
        .v_valid(r_total_valid),

        .res_data(min_rgb),
        .res_valid(min_rgb_valid)
    );

    // stage 8

    // pipeline should_render_arrow: 194, verified
    localparam SHOULD_RENDER_ARROW_DELAY = 194 + 1;
    logic should_render_arrow_pipe [SHOULD_RENDER_ARROW_DELAY-1:0];
    logic should_render_arrow_valid_pipe [SHOULD_RENDER_ARROW_DELAY-1:0];

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            for(int i=0; i<SHOULD_RENDER_ARROW_DELAY; i = i+1) begin
                should_render_arrow_pipe[i] <= 0;
                should_render_arrow_valid_pipe[i] <= 0;
            end
        end else begin
            should_render_arrow_pipe[0] <= should_render_arrow;
            should_render_arrow_valid_pipe[0] <= should_render_arrow_valid;
            for (int i=1; i<SHOULD_RENDER_ARROW_DELAY; i = i+1) begin
                should_render_arrow_pipe[i] <= should_render_arrow_pipe[i-1];
                should_render_arrow_valid_pipe[i] <= should_render_arrow_valid_pipe[i-1];
            end
        end
    end

    // always_ff @(posedge clk_in) begin
    //     if(should_render_arrow_valid_pipe[SHOULD_RENDER_ARROW_DELAY-1]) begin
    //         $display("SHOULD_RENDER_DELAY? %d", should_render_arrow_pipe[SHOULD_RENDER_ARROW_DELAY-1]);
    //     end
    // end

    // pipeline r_total, g_total, b_total: 3
    localparam RGB_TOTAL_DELAY = 3;
    logic [31:0] r_total_pipe [RGB_TOTAL_DELAY-1:0];
    logic [31:0] g_total_pipe [RGB_TOTAL_DELAY-1:0];
    logic [31:0] b_total_pipe [RGB_TOTAL_DELAY-1:0];

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            for(int i=0; i<RGB_TOTAL_DELAY; i = i+1) begin
                r_total_pipe[i] <= 0;
                g_total_pipe[i] <= 0;
                b_total_pipe[i] <= 0;
            end
        end else begin
            r_total_pipe[0] <= r_total;
            g_total_pipe[0] <= g_total;
            b_total_pipe[0] <= b_total;
            for (int i=1; i<RGB_TOTAL_DELAY; i = i+1) begin
                r_total_pipe[i] <= r_total_pipe[i-1];
                g_total_pipe[i] <= g_total_pipe[i-1];
                b_total_pipe[i] <= b_total_pipe[i-1];
            end
        end
    end

    // always_ff @(posedge clk_in) begin
    //     if(min_rgb_valid) begin
    //         $display("RGB %b %b %b", r_total_pipe[RGB_TOTAL_DELAY-1],g_total_pipe[RGB_TOTAL_DELAY-1],b_total_pipe[RGB_TOTAL_DELAY-1]);
    //     end
    // end

    always_ff @(posedge clk_in) begin
        if(~rst_in) begin
            if(min_rgb_valid) begin
                rgb_valid <= 1;
                if(should_render_arrow_pipe[SHOULD_RENDER_ARROW_DELAY-1]) begin
                    r_out <= min_rgb;
                    g_out <= min_rgb;
                    b_out <= min_rgb;
                end else begin
                    r_out <= r_total_pipe[RGB_TOTAL_DELAY-1];
                    g_out <= g_total_pipe[RGB_TOTAL_DELAY-1];
                    b_out <= b_total_pipe[RGB_TOTAL_DELAY-1];
                end
            end else begin
                rgb_valid <= 0;
            end
        end
    end

endmodule

module get_pixel_color_should_draw_arrow(
    input wire clk_in,
    input wire rst_in,

    input wire [31:0] block_pos_x,
    input wire [31:0] block_pos_y,
    input wire [31:0] block_pos_z,
    input wire [2:0] block_dir,
    input wire [31:0] scaled_ray_x,
    input wire [31:0] scaled_ray_y,
    input wire [31:0] scaled_ray_z,
    input wire valid_in,

    output logic should_render_arrow,
    output logic should_render_arrow_valid
    );

    typedef enum {
        UP, RIGHT, DOWN, LEFT, ANY
    } direction;

    ////////////////////////////////////////////////////
    // VARIABLE CONSTANTS
    //
    // precomputed constants go here
    //

    logic [31:0] TWO_BLOCK_SIZE, MINUS_BLOCK_PLUS_EDGE_SIZE, PLUS_BLOCK_MINUS_EDGE_SIZE;

    assign TWO_BLOCK_SIZE = 32'b01000011010010000000000000000000; //200
    assign MINUS_BLOCK_PLUS_EDGE_SIZE = 32'b11000010101000000000000000000000; //-80
    assign PLUS_BLOCK_MINUS_EDGE_SIZE = 32'b01000010101000000000000000000000; //80

    logic [31:0] point_zero_one;

    assign point_zero_one = 32'b00111100001000111101011100001010;

    ////////////////////////////////////////////////////
    // VARIABLE DEFINITIONS
    //
    // logic variables go here
    //

    // stage 0, 1, 2
    logic [31:0] scaled_sub_0, scaled_sub_1;
    logic scaled_sub_comp;
    logic scaled_sub_0_valid, scaled_sub_1_valid, scaled_sub_comp_valid;

    // stage 1-0-0
    logic [31:0] block_pos_normalized_x, block_pos_normalized_y, block_pos_normalized_z;
    logic block_pos_normalized_valid;

    // stage 1-0-1
    logic [31:0] region_a_eq_ray, region_a_eq_block;
    logic [31:0] region_c_eq_ray, region_c_eq_block;
    logic [31:0] ud_bounds_0_eq, ud_bounds_1_eq;
    logic [31:0] lr_bounds_0_eq, lr_bounds_1_eq;
    logic region_a_eq_ray_valid;

    // stage 1-0-2
    logic in_region_a, in_region_c, is_in_ud_bounds_0, is_in_ud_bounds_1, is_in_lr_bounds_0, is_in_lr_bounds_1;
    logic x_ray_block_less_than, y_ray_block_less_than;
    logic in_region_a_valid;

    // stage 1-0-3
    logic is_in_udlr_bounds;
    logic in_region_b;
    logic in_region_d;

    ////////////////////////////////////////////////////
    // LOGIC
    //
    // module logic chain
    //

    // stage 0, 1, 2

    // always_ff @(posedge clk_in) begin
    //     if (valid_in) begin
    //         $display("BLOCK POS IS %d %d %d", block_pos_x, block_pos_y, block_pos_z);
    //     end
    // end

    floating_point_sub scaled_sub_0_sub(
        .aclk(clk_in),
        .aresetn(~rst_in),

        .s_axis_a_tdata(scaled_ray_z),
        .s_axis_b_tdata(block_pos_z),
        .s_axis_a_tvalid(valid_in),
        .s_axis_b_tvalid(valid_in),
        
        .m_axis_result_tdata(scaled_sub_0),
        .m_axis_result_tvalid(scaled_sub_0_valid)
    );

    floating_point_sub scaled_sub_1_sub(
        .aclk(clk_in),
        .aresetn(~rst_in),

        .s_axis_a_tdata(scaled_sub_0),
        .s_axis_b_tdata(TWO_BLOCK_SIZE),
        .s_axis_a_tvalid(scaled_sub_0_valid),
        .s_axis_b_tvalid(scaled_sub_0_valid),
        
        .m_axis_result_tdata(scaled_sub_1),
        .m_axis_result_tvalid(scaled_sub_1_valid)
    );

    float_less_than_equal scaled_sub_comp_lte(
        .clk_in(clk_in),
        .rst_in(rst_in),

        .a(scaled_sub_1),
        .b(point_zero_one),
        .v_valid(scaled_sub_1_valid),

        .res_data(scaled_sub_comp),
        .res_valid(scaled_sub_comp_valid)
    );

    // always_ff @(posedge clk_in) begin
    //     if (scaled_sub_comp_valid) begin
    //         $display("SCALED_SUB_COMP %d", scaled_sub_comp);
    //     end
    // end

    // stage 1-0-0

    // pipelining the block_pos: 24, verified
    localparam BLOCK_POS_DELAY = 24;
    logic [31:0] block_pos_x_pipe [BLOCK_POS_DELAY-1:0];
    logic [31:0] block_pos_y_pipe [BLOCK_POS_DELAY-1:0];
    logic [31:0] block_pos_z_pipe [BLOCK_POS_DELAY-1:0];

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            for(int i=0; i<BLOCK_POS_DELAY; i = i+1) begin
                block_pos_x_pipe[i] <= 0;
                block_pos_y_pipe[i] <= 0;
                block_pos_z_pipe[i] <= 0;
            end
        end else begin
            block_pos_x_pipe[0] <= block_pos_x;
            block_pos_y_pipe[0] <= block_pos_y;
            block_pos_z_pipe[0] <= block_pos_z;
            for (int i=1; i<BLOCK_POS_DELAY; i = i+1) begin
                block_pos_x_pipe[i] <= block_pos_x_pipe[i-1];
                block_pos_y_pipe[i] <= block_pos_y_pipe[i-1];
                block_pos_z_pipe[i] <= block_pos_z_pipe[i-1];
            end
        end
    end

    vec_sub block_pos_normalized_sub( //output verified
        .clk_in(clk_in),
        .rst_in(rst_in),

        .v1_x(block_pos_x_pipe[BLOCK_POS_DELAY-1]),
        .v1_y(block_pos_y_pipe[BLOCK_POS_DELAY-1]),
        .v1_z(block_pos_z_pipe[BLOCK_POS_DELAY-1]),
        .v2_x(32'b01000100111000010000000000000000), //1800
        .v2_y(32'b01000100111000010000000000000000), //1800
        .v2_z(32'b0),
        .v_valid(scaled_sub_comp_valid),

        .res_data_x(block_pos_normalized_x),
        .res_data_y(block_pos_normalized_y),
        .res_data_z(block_pos_normalized_z),
        .res_valid(block_pos_normalized_valid)
    );

    // stage 1-0-1

    // pipelining the scaled ray: 35 + 11
    localparam SCALED_RAY_DELAY = 46;
    localparam SCALED_RAY_DELAY_1 = 35;
    logic [31:0] scaled_ray_x_pipe [SCALED_RAY_DELAY-1:0];
    logic [31:0] scaled_ray_y_pipe [SCALED_RAY_DELAY-1:0];
    logic [31:0] scaled_ray_z_pipe [SCALED_RAY_DELAY-1:0];

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            for(int i=0; i<SCALED_RAY_DELAY; i = i+1) begin
                scaled_ray_x_pipe[i] <= 0;
                scaled_ray_y_pipe[i] <= 0;
                scaled_ray_z_pipe[i] <= 0;
            end
        end else begin
            scaled_ray_x_pipe[0] <= scaled_ray_x;
            scaled_ray_y_pipe[0] <= scaled_ray_y;
            scaled_ray_z_pipe[0] <= scaled_ray_z;
            for (int i=1; i<SCALED_RAY_DELAY; i = i+1) begin
                scaled_ray_x_pipe[i] <= scaled_ray_x_pipe[i-1];
                scaled_ray_y_pipe[i] <= scaled_ray_y_pipe[i-1];
                scaled_ray_z_pipe[i] <= scaled_ray_z_pipe[i-1];
            end
        end
    end

    floating_point_add add_a_ray(
        .aclk(clk_in),
        .aresetn(~rst_in),

        .s_axis_a_tdata(scaled_ray_y_pipe[SCALED_RAY_DELAY_1-1]),
        .s_axis_b_tdata(scaled_ray_x_pipe[SCALED_RAY_DELAY_1-1]),
        .s_axis_a_tvalid(block_pos_normalized_valid),
        .s_axis_b_tvalid(block_pos_normalized_valid),
        
        .m_axis_result_tdata(region_a_eq_ray),
        .m_axis_result_tvalid(region_a_eq_ray_valid)
    );

    floating_point_add add_a_block(
        .aclk(clk_in),
        .aresetn(~rst_in),

        .s_axis_a_tdata(block_pos_normalized_y),
        .s_axis_b_tdata(block_pos_normalized_x),
        .s_axis_a_tvalid(block_pos_normalized_valid),
        .s_axis_b_tvalid(block_pos_normalized_valid),
        
        .m_axis_result_tdata(region_a_eq_block),
        .m_axis_result_tvalid()
    );

    floating_point_sub sub_c_ray(
        .aclk(clk_in),
        .aresetn(~rst_in),

        .s_axis_a_tdata(scaled_ray_y_pipe[SCALED_RAY_DELAY_1-1]),
        .s_axis_b_tdata(scaled_ray_x_pipe[SCALED_RAY_DELAY_1-1]),
        .s_axis_a_tvalid(block_pos_normalized_valid),
        .s_axis_b_tvalid(block_pos_normalized_valid),
        
        .m_axis_result_tdata(region_c_eq_ray),
        .m_axis_result_tvalid()
    );

    floating_point_sub sub_a_block(
        .aclk(clk_in),
        .aresetn(~rst_in),

        .s_axis_a_tdata(block_pos_normalized_y),
        .s_axis_b_tdata(block_pos_normalized_x),
        .s_axis_a_tvalid(block_pos_normalized_valid),
        .s_axis_b_tvalid(block_pos_normalized_valid),
        
        .m_axis_result_tdata(region_c_eq_block),
        .m_axis_result_tvalid()
    );

    floating_point_add add_ud_0(
        .aclk(clk_in),
        .aresetn(~rst_in),

        .s_axis_a_tdata(block_pos_normalized_y),
        .s_axis_b_tdata(MINUS_BLOCK_PLUS_EDGE_SIZE),
        .s_axis_a_tvalid(block_pos_normalized_valid),
        .s_axis_b_tvalid(block_pos_normalized_valid),
        
        .m_axis_result_tdata(ud_bounds_0_eq),
        .m_axis_result_tvalid()
    );

    floating_point_add add_ud_1(
        .aclk(clk_in),
        .aresetn(~rst_in),

        .s_axis_a_tdata(block_pos_normalized_y),
        .s_axis_b_tdata(PLUS_BLOCK_MINUS_EDGE_SIZE),
        .s_axis_a_tvalid(block_pos_normalized_valid),
        .s_axis_b_tvalid(block_pos_normalized_valid),
        
        .m_axis_result_tdata(ud_bounds_1_eq),
        .m_axis_result_tvalid()
    );

    floating_point_add add_lr_0(
        .aclk(clk_in),
        .aresetn(~rst_in),

        .s_axis_a_tdata(block_pos_normalized_x),
        .s_axis_b_tdata(MINUS_BLOCK_PLUS_EDGE_SIZE),
        .s_axis_a_tvalid(block_pos_normalized_valid),
        .s_axis_b_tvalid(block_pos_normalized_valid),
        
        .m_axis_result_tdata(lr_bounds_0_eq),
        .m_axis_result_tvalid()
    );

    floating_point_add add_lr_1(
        .aclk(clk_in),
        .aresetn(~rst_in),

        .s_axis_a_tdata(block_pos_normalized_x),
        .s_axis_b_tdata(PLUS_BLOCK_MINUS_EDGE_SIZE),
        .s_axis_a_tvalid(block_pos_normalized_valid),
        .s_axis_b_tvalid(block_pos_normalized_valid),
        
        .m_axis_result_tdata(lr_bounds_1_eq),
        .m_axis_result_tvalid()
    );

    // probably verified up to here

    // always_ff @(posedge clk_in) begin
    //     if (region_a_eq_ray_valid) begin
    //         $display("UDLR %b %b %b %b", ud_bounds_0_eq, ud_bounds_1_eq, lr_bounds_0_eq, lr_bounds_1_eq);
    //     end
    // end

    // stage 1-0-2

    // pipeline block_pos_normalized_x and block_pos_normalized_y: 11
    localparam BLOCK_POS_NORM_DELAY = 11;
    logic [31:0] block_pos_normalized_x_pipe [BLOCK_POS_NORM_DELAY-1:0];
    logic [31:0] block_pos_normalized_y_pipe [BLOCK_POS_NORM_DELAY-1:0];

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            for(int i=0; i<BLOCK_POS_NORM_DELAY; i = i+1) begin
                block_pos_normalized_x_pipe[i] <= 0;
                block_pos_normalized_y_pipe[i] <= 0;
            end
        end else begin
            block_pos_normalized_x_pipe[0] <= block_pos_normalized_x;
            block_pos_normalized_y_pipe[0] <= block_pos_normalized_y;
            for (int i=1; i<BLOCK_POS_NORM_DELAY; i = i+1) begin
                block_pos_normalized_x_pipe[i] <= block_pos_normalized_x_pipe[i-1];
                block_pos_normalized_y_pipe[i] <= block_pos_normalized_y_pipe[i-1];
            end
        end
    end

    float_less_than lt_region_a(
        .clk_in(clk_in),
        .rst_in(rst_in),

        .a(region_a_eq_ray),
        .b(region_a_eq_block),
        .v_valid(region_a_eq_ray_valid),

        .res_data(in_region_a),
        .res_valid(in_region_a_valid)
    );

    float_less_than lt_region_c(
        .clk_in(clk_in),
        .rst_in(rst_in),

        .a(region_c_eq_ray),
        .b(region_c_eq_block),
        .v_valid(region_a_eq_ray_valid),

        .res_data(in_region_c),
        .res_valid()
    );

    float_less_than lt_ud_0(
        .clk_in(clk_in),
        .rst_in(rst_in),

        .a(ud_bounds_0_eq),
        .b(scaled_ray_y_pipe[SCALED_RAY_DELAY-1]),
        .v_valid(region_a_eq_ray_valid),

        .res_data(is_in_ud_bounds_0),
        .res_valid()
    );

    float_less_than lt_ud_1(
        .clk_in(clk_in),
        .rst_in(rst_in),

        .a(scaled_ray_y_pipe[SCALED_RAY_DELAY-1]),
        .b(ud_bounds_1_eq),
        .v_valid(region_a_eq_ray_valid),

        .res_data(is_in_ud_bounds_1),
        .res_valid()
    );

    float_less_than lt_lr_0(
        .clk_in(clk_in),
        .rst_in(rst_in),

        .a(lr_bounds_0_eq),
        .b(scaled_ray_x_pipe[SCALED_RAY_DELAY-1]),
        .v_valid(region_a_eq_ray_valid),

        .res_data(is_in_lr_bounds_0),
        .res_valid()
    );

    float_less_than lt_lr_1(
        .clk_in(clk_in),
        .rst_in(rst_in),

        .a(scaled_ray_x_pipe[SCALED_RAY_DELAY-1]),
        .b(lr_bounds_1_eq),
        .v_valid(region_a_eq_ray_valid),

        .res_data(is_in_lr_bounds_1),
        .res_valid()
    );

    float_less_than x_ray_block_less_than_lt(
        .clk_in(clk_in),
        .rst_in(rst_in),

        .a(scaled_ray_x_pipe[SCALED_RAY_DELAY-1]),
        .b(block_pos_normalized_x_pipe[BLOCK_POS_NORM_DELAY-1]),
        .v_valid(region_a_eq_ray_valid),

        .res_data(x_ray_block_less_than),
        .res_valid()
    );

    float_less_than y_ray_block_less_than_lt(
        .clk_in(clk_in),
        .rst_in(rst_in),

        .a(scaled_ray_y_pipe[SCALED_RAY_DELAY-1]),
        .b(block_pos_normalized_y_pipe[BLOCK_POS_NORM_DELAY-1]),
        .v_valid(region_a_eq_ray_valid),

        .res_data(y_ray_block_less_than),
        .res_valid()
    );

    // always_ff @(posedge clk_in) begin
    //     if (in_region_a_valid) begin
    //         $display("COMPS %d %d %d %d %d %d %d %d", in_region_a, in_region_c, is_in_ud_bounds_0, is_in_ud_bounds_1, is_in_lr_bounds_0, is_in_lr_bounds_1, x_ray_block_less_than, y_ray_block_less_than);
    //     end
    // end

    // verified up to here

    // stage 1-0-3

    // pipelining scaled_sub_comp: 24 (or 25?)
    localparam SCALED_SUB_COMP_DELAY = 25; // maybe it is 25 because there is a always_ff?
    logic scaled_sub_comp_pipe [SCALED_SUB_COMP_DELAY-1:0];

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            for(int i=0; i<SCALED_SUB_COMP_DELAY; i = i+1) begin
                scaled_sub_comp_pipe[i] <= 0;
            end
        end else begin
            scaled_sub_comp_pipe[0] <= scaled_sub_comp;
            for (int i=1; i<SCALED_SUB_COMP_DELAY; i = i+1) begin
                scaled_sub_comp_pipe[i] <= scaled_sub_comp_pipe[i-1];
            end
        end
    end

    // pipelining block_dir: 48
    localparam BLOCK_DIR_DELAY = 48;
    logic [2:0] block_dir_pipe [BLOCK_DIR_DELAY-1:0];

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            for(int i=0; i<BLOCK_DIR_DELAY; i = i+1) begin
                block_dir_pipe[i] <= 0;
            end
        end else begin
            block_dir_pipe[0] <= block_dir;
            for (int i=1; i<BLOCK_DIR_DELAY; i = i+1) begin
                block_dir_pipe[i] <= block_dir_pipe[i-1];
            end
        end
    end
    
    always_comb begin
        is_in_udlr_bounds = is_in_ud_bounds_0 && is_in_ud_bounds_1 && is_in_lr_bounds_0 && is_in_lr_bounds_1;
        in_region_b = ~in_region_a;
        in_region_d = ~in_region_c;
    end

    // always_ff @(posedge clk_in) begin
    //     if (in_region_a_valid) begin
    //         $display("COMP0 %d %d %d", is_in_udlr_bounds, in_region_b, in_region_d);
    //         $display("COMP1 %b %b", scaled_sub_comp_pipe[SCALED_SUB_COMP_DELAY-1], block_dir_pipe[BLOCK_DIR_DELAY-1]);
    //     end else begin
    //         $display("    INVALID, SUBSCALEDIS %d",scaled_sub_comp_pipe[SCALED_SUB_COMP_DELAY-1]);
    //     end
    // end

    always_ff @(posedge clk_in) begin
        if(~rst_in) begin
            should_render_arrow_valid <= in_region_a_valid;

            case (block_dir_pipe[BLOCK_DIR_DELAY-1])
                UP: should_render_arrow <= scaled_sub_comp_pipe[SCALED_SUB_COMP_DELAY-1] && y_ray_block_less_than && is_in_udlr_bounds && (~in_region_b && ~in_region_d);
                RIGHT: should_render_arrow <= scaled_sub_comp_pipe[SCALED_SUB_COMP_DELAY-1] && ~x_ray_block_less_than && is_in_udlr_bounds && (~in_region_a && ~in_region_d);
                DOWN: should_render_arrow <= scaled_sub_comp_pipe[SCALED_SUB_COMP_DELAY-1] && ~y_ray_block_less_than && is_in_udlr_bounds && (~in_region_a && ~in_region_c);
                default: should_render_arrow <= scaled_sub_comp_pipe[SCALED_SUB_COMP_DELAY-1] && x_ray_block_less_than && is_in_udlr_bounds && (~in_region_b && ~in_region_c);
            endcase
        end
    end
    // VERIFIED!!
endmodule

`default_nettype wire