`default_nettype none
`timescale 1ns / 1ps

/*

Tested so far

add, sub, scale, dot

*/
module float_functions_tb;

    logic clk, rst;

    logic a_valid, b_valid;
    logic [31:0] a_data, b_data;

    logic res_valid;
    logic [31:0] res_x, res_y, res_z;

    floating_point_sint32_to_float a(
        .aclk(clk),
        .aresetn(~rst),
        .s_axis_a_tvalid(1'b1),
        .s_axis_a_tdata(10),
        .m_axis_result_tvalid(a_valid),
        .m_axis_result_tdata(a_data)
    );

    floating_point_sint32_to_float b(
        .aclk(clk),
        .aresetn(~rst),
        .s_axis_a_tvalid(1'b1),
        .s_axis_a_tdata(3),
        .m_axis_result_tvalid(b_valid),
        .m_axis_result_tdata(b_data)
    );  

    vec_dot mod(
        .clk_in(clk),
        .rst_in(rst),
        .v1_x(a_data),
        .v1_y(a_data),
        .v1_z(a_data),
        .v2_x(b_data),
        .v2_y(b_data),
        .v2_z(b_data),
        .v_valid(a_valid), 

        .res_data(res_x),
        .res_valid(res_valid)
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
        $dumpfile("float_functions_tb.vcd");
        $dumpvars(0, float_functions_tb);
        $display("Starting Sim");

        clk = 0;
        rst = 0;
        #10;
        rst = 1;
        #10;
        #10;
        rst = 0;
        #10;

        #200;

        for(int i = 0; i < 500; i = i + 1) begin
            // if(res_valid) begin
                //check the result of the add
                // $display("A AND B: %b %b", a_data, b_data);
                // $display("RESULT IS: %b %b %b %b", res_x, res_y, res_z, res_valid);
            // end
            if(val_valid_x) begin
                $display("RESULT IS %d %d %d", val_data_x, val_data_y, val_data_z);
            end
            #10;
        end

        #10;

        $display("Finishing Sim");
        $finish;
    end

endmodule

`default_nettype none