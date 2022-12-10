`default_nettype none
`timescale 1ns / 1ps

/*

Tested so far

add, sub, scale, dot

*/
module eye_to_pixel_tb;

    logic clk, rst;

    // logic a_valid, b_valid;
    // logic [31:0] a_data, b_data;

    logic res_valid;
    logic [31:0] res_x, res_y, res_z;

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

    logic valid_in;

    eye_to_pixel mod(
        .clk_in(clk),
        .rst_in(rst),
        .x_in(11'd100),
        .y_in(10'd100),
        .head_x_float(32'b01000100111000010000000000000001), //1800
        .head_y_float(32'b01000100111000010000000000000001), //1800
        .head_z_float(32'b11000011100101100000000000000011), //-300
        .valid_in(valid_in),

        .dir_x(res_x),
        .dir_y(res_y),
        .dir_z(res_z),
        .dir_valid(res_valid)
    );

    logic signed [31:0] val_data_x, val_data_y, val_data_z;
    logic signed val_valid_x, val_valid_y, val_valid_z;

    floating_point_float_to_sint32 val_x(
        .aclk(clk),
        .aresetn(~rst),
        .s_axis_a_tvalid(res_valid),
        .s_axis_a_tdata(res_x),
        .m_axis_result_tvalid(val_valid_x),
        .m_axis_result_tdata(val_data_x)
    );  

    floating_point_float_to_sint32 val_y(
        .aclk(clk),
        .aresetn(~rst),
        .s_axis_a_tvalid(res_valid),
        .s_axis_a_tdata(res_y),
        .m_axis_result_tvalid(val_valid_y),
        .m_axis_result_tdata(val_data_y)
    );  

    floating_point_float_to_sint32 val_z(
        .aclk(clk),
        .aresetn(~rst),
        .s_axis_a_tvalid(res_valid),
        .s_axis_a_tdata(res_z),
        .m_axis_result_tvalid(val_valid_z),
        .m_axis_result_tdata(val_data_z)
    );  

    always begin
        #5;
        clk = !clk;
    end

    // we will increment time every 10 cycles

    initial begin
        $dumpfile("eye_to_pixel_tb.vcd");
        $dumpvars(0, eye_to_pixel_tb);
        $display("Starting Sim");

        clk = 0;
        rst = 0;
        #10;
        rst = 1;
        #100;
        rst = 0;
        #10;
        valid_in = 1'b1;
        #10;
        valid_in = 1'b0;
        #100;

        for(int i = 0; i < 1000; i = i + 1) begin
            if(res_valid) begin
                $display("EYETOPIXEL %d: VALID IS %b %b %b", i, res_x, res_y, res_z);
            end
            // if(val_valid_x) begin
            //     $display("RESULT IS %d %d %d", val_data_x, val_data_y, val_data_z);
            // end
            #10;
        end

        #10;

        $display("Finishing Sim");
        $finish;
    end

endmodule

`default_nettype none