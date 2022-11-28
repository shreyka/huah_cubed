`timescale 1ns / 1ps
`default_nettype none

module three_dim_renderer(
    input wire clk_in,
    input wire rst_in,

    input wire [10:0] x_in,
    input wire [9:0] y_in,

    output logic [4:0] r_out,
    output logic [5:0] g_out,
    output logic [4:0] b_out
    );

    localparam WIDTH = 1024;
    localparam HEIGHT = 768;
    // localparam WIDTH = 4;
    // localparam HEIGHT = 2;

    logic [19:0] input_loc_read;
    logic [11:0] output_pixel_read;

    logic [19:0] input_loc_write;
    logic [11:0] input_pixel_write;
    logic input_write_enable;

    function int get_offset_x(logic [10:0] x);
        if (x + 2 == WIDTH) begin
            return 0;
        end else if (x + 2 == WIDTH + 1) begin
            return 1;
        end else begin
            return x + 2;
        end
    endfunction

    function int get_offset_y(logic [10:0] x, logic [9:0] y);
        if (x + 2 == WIDTH || x + 2 == WIDTH + 1) begin
            if (y + 1 == HEIGHT) begin
                return 0;
            end else begin
                return (y + 1) * WIDTH;
            end
        end else begin
            return y * WIDTH;
        end
    endfunction

    always_comb begin
        $display("WE ARE AT (%d, %d)", x_in, y_in);
        input_loc_read = get_offset_x(x_in) + get_offset_y(x_in, y_in);
        $display("READ FOR LATER %d", input_loc_read);
    end 

    xilinx_true_dual_port_read_first_1_clock_ram #(
        .RAM_WIDTH(12), //only 12 bits, since screen can only render that much
        .RAM_DEPTH(WIDTH*HEIGHT),                     // Specify RAM depth (number of entries)
        .RAM_PERFORMANCE("HIGH_PERFORMANCE"), // Select "HIGH_PERFORMANCE" or "LOW_LATENCY"
        .INIT_FILE("")                        // Specify name/location of RAM initialization file if using one (leave blank if not)
    ) rgb_buffer (
        .addra(input_loc_read),   // Port A address bus, width determined from RAM_DEPTH
        .dina(12'b0),     // Port A RAM input data, width determined from RAM_WIDTH
        .clka(clk_in),     // Port A clock
        .wea(1'b0),       // Port A write enable
        .ena(1'b1),       // Port A RAM Enable, for additional power savings, disable port when not in use
        .rsta(rst_in),     // Port A output reset (does not affect memory contents)
        .regcea(1'b1), // Port A output register enable
        .douta(output_pixel_read),   // Port A RAM output data, width determined from RAM_WIDTH

        .addrb(input_loc_write),   // Port B address bus, width determined from RAM_DEPTH
        .dinb(input_pixel_write),     // Port B RAM input data, width determined from RAM_WIDTH
        .web(input_write_enable),       // Port B write enable
        .enb(1'b1),       // Port B RAM Enable, for additional power savings, disable port when not in use
        .rstb(rst_in),     // Port B output reset (does not affect memory contents)
        .regceb(1'b1) // Port B output register enable
    );

    logic [11:0] index_test;
    assign index_test = x_in + (y_in * WIDTH);

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            input_pixel_write <= 12'b0;
        end else begin
            //start the process to update the buffer
            if(1) begin
                $display("WRITE TO  \t%d -> (%d, %d, %d)", input_loc_write, input_pixel_write[11:8], input_pixel_write[7:4], input_pixel_write[3:0]);
                input_loc_write <= x_in + (y_in * WIDTH);
                input_write_enable <= 1;

                input_pixel_write <= index_test;
            end else begin
                input_write_enable <= 0;
            end

            // send out the buffer info
            r_out <= output_pixel_read[11:8];
            g_out <= output_pixel_read[7:4];
            b_out <= output_pixel_read[3:0];
        end
    end

endmodule

`default_nettype wire