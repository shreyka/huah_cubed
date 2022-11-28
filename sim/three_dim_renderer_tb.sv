`default_nettype none
`timescale 1ns / 1ps

module three_dim_renderer_tb;

    logic clk, rst;

    logic [10:0] hcount;
    logic [9:0] vcount;

    logic [4:0] r_out;
    logic [5:0] g_out;
    logic [4:0] b_out;

    three_dim_renderer renderer(
        .clk_in(clk),
        .rst_in(rst),
        .x_in(hcount),
        .y_in(vcount),
        
        .r_out(r_out),
        .g_out(g_out),
        .b_out(b_out)
    );


    always begin
        #5;
        clk = !clk;
    end

    // we will increment time every 10 cycles

    initial begin
        $dumpfile("three_dim_renderer_tb.vcd");
        $dumpvars(0, three_dim_renderer_tb);
        $display("Starting Sim");

        clk = 0;
        rst = 0;
        #10;
        rst = 1;
        #10;
        rst = 0;
        #10;

        #10;

        //TODO
        hcount = 0;
        vcount = 0;
        #10;

        for(int i = 0; i < 20; i = i + 1) begin
            $display("READ FROM\t%d -> RGB: (%d, %d, %d)", hcount + (vcount * 4), r_out, g_out, b_out);
            if(hcount == 3) begin
                if(vcount == 1) begin
                    vcount = 0;
                end else begin
                    vcount = vcount + 1;
                end
                hcount = 0;
            end else begin
                hcount = hcount + 1;
            end
            $display("====");
            #10;
        end

        #10;

        $display("Finishing Sim");
        $finish;
    end

endmodule

`default_nettype none