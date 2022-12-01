`default_nettype none
`timescale 1ns / 1ps

module does_ray_block_intersect_tb;

    logic clk, rst;

    // logic a_valid, b_valid;
    // logic [31:0] a_data, b_data;

    logic valid_in;
    logic [31:0] ray_x, block_y;

    logic res_valid;
    logic [31:0] res_x, res_y, res_z;

    logic intersects_data_out;
    logic [31:0] t_out;
    logic valid_out;

    // floating_point_sint32_to_float a(
    //     .aclk(clk),
    //     .aresetn(~rst),
    //     .s_axis_a_tvalid(1'b1),
    //     .s_axis_a_tdata(10),
    //     .m_axis_result_tvalid(a_valid),
    //     .m_axis_result_tdata(a_data)
    // );

    // floating_point_sint32_to_float b(
    //     .aclk(clk),
    //     .aresetn(~rst),
    //     .s_axis_a_tvalid(1'b1),
    //     .s_axis_a_tdata(3),
    //     .m_axis_result_tvalid(b_valid),
    //     .m_axis_result_tdata(b_data)
    // );  

    does_ray_block_intersect mod(
        .clk_in(clk),
        .rst_in(rst),

        .ray_x(32'b00110111001001111100010110101100), //0.00001
        .ray_y(32'b00110111001001111100010110101100), //0.00001
        .ray_z(32'b00111111100000000000000001010100), //1.00001
        .block_pos_x(32'b01000011100000000000000000000000), //256
        .block_pos_y(block_y),
        .block_pos_z(32'b01000011100101100000000000000000), //300
        .t_in(),
        .valid_in(valid_in),

        .intersects_data_out(intersects_data_out),
        .t_out(t_out),
        .valid_out(valid_out)
    );

    // logic signed [31:0] val_data_x, val_data_y, val_data_z;
    // logic signed val_valid_x, val_valid_y, val_valid_z;

    // floating_point_float_to_sint32 val_x(
    //     .aclk(clk),
    //     .aresetn(~rst),
    //     .s_axis_a_tvalid(res_valid),
    //     .s_axis_a_tdata(res_x),
    //     .m_axis_result_tvalid(val_valid_x),
    //     .m_axis_result_tdata(val_data_x)
    // );  

    // floating_point_float_to_sint32 val_y(
    //     .aclk(clk),
    //     .aresetn(~rst),
    //     .s_axis_a_tvalid(res_valid),
    //     .s_axis_a_tdata(res_y),
    //     .m_axis_result_tvalid(val_valid_y),
    //     .m_axis_result_tdata(val_data_y)
    // );  

    // floating_point_float_to_sint32 val_z(
    //     .aclk(clk),
    //     .aresetn(~rst),
    //     .s_axis_a_tvalid(res_valid),
    //     .s_axis_a_tdata(res_z),
    //     .m_axis_result_tvalid(val_valid_z),
    //     .m_axis_result_tdata(val_data_z)
    // );  

    always begin
        #5;
        clk = !clk;
    end

    // we will increment time every 10 cycles

    initial begin
        $dumpfile("does_ray_block_intersect_tb.vcd");
        $dumpvars(0, does_ray_block_intersect_tb);
        $display("Starting Sim");

        clk = 0;
        rst = 0;
        #10;
        rst = 1;
        #30;
        rst = 0;
        #200;

        valid_in = 1;
        block_y = 32'b01000011100000000000000000000000; //256
        #10;
        block_y = 32'b0; //0
        #10;
        valid_in = 0;
        #10;

        for(int i = 0; i < 1500; i = i + 1) begin
            if(valid_out) begin
                $display("VALIDOUT INTERSECTS? %d", intersects_data_out);
                $display("TIME: %d", t_out);
            end
            #10;
        end

        #10;

        $display("Finishing Sim");
        $finish;
    end

endmodule

`default_nettype none