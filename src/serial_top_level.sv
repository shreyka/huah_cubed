`timescale 1ns / 1ps
`default_nettype none

module serial_top_level(
    input wire clk, //clock @ 100 mhz
    input wire btnc, //btnc (used for reset)

    //UART
    input wire uart_txd_in,
    output logic uart_rxd_out,

    output logic[7:0] jc
);

    logic sys_rst; //global system reset
    assign sys_rst = btnc; //just done to make sys_rst more obvious

    //Generate 65 MHz:
    logic clk_65mhz; //65 MHz clock line
    logic clk_25mhz; //testing 25 MHz clock line too
    clk_wiz_1 clk_gen(
    .clk_in1(clk),
    .clk_out1(clk_25mhz),
    .clk_out2(clk_65mhz)); //after frame buffer everything on clk_65mhz

    logic TxD_busy, TxD, RxD_data_ready;
    logic [7:0] RxD_data;

    // assign uart_rxd_out = uart_txd_in;

    assign jc[0] = uart_txd_in;
    assign jc[1] = uart_rxd_out;


    receiver r1 (.clk(clk_65mhz),
             .RxD(uart_txd_in),
             .rst(sys_rst),
             .RxD_data_ready(RxD_data_ready),
             .RxD_data(RxD_data));


    transmitter t1 (.clk(clk_65mhz), 
                .TxD_start(RxD_data_ready),     //pulled high when data is ready for transmit
                .rst(sys_rst),
                .TxD_data(RxD_data),    //should just transmit what it receives
                .TxD(uart_rxd_out),
                .TxD_busy(TxD_busy));

    // async_receiver r1 (.clk(clk_65mhz), .RxD(uart_txd_in), .RxD_data_ready(RxD_data_ready), .RxD_data(RxD_data));

    // async_transmitter t1 (.clk(clk_65mhz), .TxD(uart_rxd_out), .TxD_start(RxD_data_ready), .TxD_data(RxD_data));

    
endmodule

`default_nettype wire