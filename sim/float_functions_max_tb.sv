`default_nettype none
`timescale 1ns / 1ps

module float_functions_max_tb;

    logic clk, rst;

    logic signed [31:0] a_data_in, b_data_in, c_data_in;

    logic a_valid, b_valid, c_valid;
    logic [31:0] a_data, b_data, c_data, mod_data_in_x, mod_data_in_y, mod_data_in_z;

    logic res_valid;
    logic [31:0] res_data;

    floating_point_sint32_to_float a(
        .aclk(clk),
        .aresetn(~rst),
        .s_axis_a_tvalid(1'b1),
        .s_axis_a_tdata(5),
        .m_axis_result_tvalid(a_valid),
        .m_axis_result_tdata(a_data)
    );

    floating_point_sint32_to_float b(
        .aclk(clk),
        .aresetn(~rst),
        .s_axis_a_tvalid(1'b1),
        .s_axis_a_tdata(10),
        .m_axis_result_tvalid(b_valid),
        .m_axis_result_tdata(b_data)
    );  


    floating_point_sint32_to_float c(
        .aclk(clk),
        .aresetn(~rst),
        .s_axis_a_tvalid(1'b1),
        .s_axis_a_tdata(15),
        .m_axis_result_tvalid(c_valid),
        .m_axis_result_tdata(c_data)
    );  

    vec_max mod(
        .clk_in(clk),
        .rst_in(rst),
        .v_x(mod_data_in_x),
        .v_y(mod_data_in_y),
        .v_z(mod_data_in_z),
        .v_valid(a_valid),

        .res_data(res_data),
        .res_valid(res_valid)
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
        $dumpfile("float_functions_max_tb.vcd");
        $dumpvars(0, float_functions_max_tb);
        $display("Starting Sim");

        clk = 0;
        rst = 0;
        #10;
        rst = 1;
        #20;
        rst = 0;
        #20;

        #200;

        // 5 10 10
        mod_data_in_x = a_data;
        mod_data_in_y = b_data;
        mod_data_in_z = b_data;
        #10;
        // 15 5 5
        mod_data_in_x = c_data;
        mod_data_in_y = a_data;
        mod_data_in_z = a_data;
        #10;
        mod_data_in_x = 0;
        mod_data_in_y = 0;
        mod_data_in_z = 0;

        for(int i = 0; i < 100; i = i + 1) begin
            // if(res_valid) begin
                //check the result of the add
                // $display("A AND B: %b %b", a_data, b_data);
                // $display("RESULT IS: %b %b %b %b", res_x, res_y, res_z, res_valid);
            // end
            if(res_valid) begin
                $display("%d: RESULT IS %b", i, res_data);
                // $display("a_data, b_data: %d, %d", a_data, b_data);
            end
            #10;
        end

        #10;

        $display("Finishing Sim");
        $finish;
    end

endmodule

`default_nettype none