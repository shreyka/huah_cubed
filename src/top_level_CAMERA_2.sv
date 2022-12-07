`timescale 1ns / 1ps
`default_nettype none

module top_level_CAMERA_2(
// module top_level(
  input wire clk_100mhz, //clock @ 100 mhz
  input wire [15:0] sw, //switches
  input wire btnc, //btnc (used for reset)

  input wire [7:0] ja, //lower 8 bits of data from camera
  input wire [2:0] jb, //upper three bits from camera (return clock, vsync, hsync)
  output logic jbclk,  //signal we provide to camera
  output logic jblock, //signal for resetting camera

  output logic [15:0] led, //just here for the funs

  output logic [3:0] vga_r, vga_g, vga_b,
  output logic vga_hs, vga_vs,
  output logic [7:0] an,
  output logic caa,cab,cac,cad,cae,caf,cag,

  //UART
  input wire uart_txd_in,
  output logic uart_rxd_out,

  output logic[7:0] jc

  );

  //system reset switch linking
  logic sys_rst; //global system reset
  assign sys_rst = btnc; //just done to make sys_rst more obvious

  logic CAMERA_1; 
  logic CAMERA_2;
  assign CAMERA_1 = sw[0];
  assign CAMERA_2 = ~sw[0]; 
  

  logic [11:0] hand_x_left_bottom;
  logic [11:0] hand_y_left_bottom;
  logic [13:0] hand_z_left_bottom;
  logic [11:0] hand_x_left_top;
  logic [11:0] hand_y_left_top;
  logic [13:0] hand_z_left_top;

  camera_top_level cam_uut(
    .clk_65mhz(clk_65mhz), //clock @ 100 mhz
    .sw(sw), //switches
    .sys_rst(sys_rst), //btnc (used for reset)

    .ja(ja), //lower 8 bits of data from camera
    .jb(jb), //upper three bits from camera (return clock, vsync, hsync)
    .jbclk(jbclk),  //signal we provide to camera
    .jblock(jblock), //signal for resetting camera

    .hand_x_left_bottom(hand_x_left_bottom),
    .hand_y_left_bottom(hand_y_left_bottom),
    .hand_z_left_bottom(hand_z_left_bottom),
    .hand_x_left_top(hand_x_left_top),
    .hand_y_left_top(hand_y_left_top),
    .hand_z_left_top(hand_z_left_top),

    // outputs we can just ignore in final game
    // .led(led), //just here for the funs

    .vga_r(vga_r), .vga_g(vga_g), .vga_b(vga_b),
    .vga_hs(vga_hs), .vga_vs(vga_vs),
    .an(an),
    .caa(caa),.cab(cab),.cac(cac),.cad(cad),.cae(cae),.caf(caf),.cag(cag),
    .transmit_xy_update(start_transmit)

  );

  // IF CAMERA 1, need to receive y and z from camera 2
  // IF CAMERA 2, need to transmit y and z to camera 1
  
  //Generate 65 MHz:
  logic clk_65mhz; //65 MHz clock line
  logic clk_25mhz; //testing 25 MHz clock line too
  clk_wiz_1 clk_gen(
  .clk_in1(clk_100mhz),
  .clk_out1(clk_25mhz),
  .clk_out2(clk_65mhz)); //after frame buffer everything on clk_65mhz

  logic TxD_busy, TxD, RxD_data_ready, start_transmit, start_byte;
  logic [7:0] RxD_data;

  assign jc[0] = uart_txd_in;
  assign jc[1] = uart_rxd_out;

//   receiver r1 (.clk(clk_65mhz),
//               .RxD(uart_txd_in),
//               .rst(sys_rst),
//               .RxD_data_ready(RxD_data_ready),
//               .RxD_data(RxD_data));

  /////////////////////////////
  // TRANSMIT INFO: 
  // start_transmit goes high for a cycle when com's are ready to transmit
  // start_byte has to go high at the start of each byte
  //
  // need to transmit:
  //     - logic [11:0] hand_x_left_bottom;  12 bits
  //     - logic [11:0] hand_y_left_bottom;  12 bits
  // bytes sent: 
  //     - [11:4] hand_x_left_bottom;
  //     - [3:0] hand_x_left_bottom  +  [11:8] hand_y_left_bottom;
  //     - [7:0] hand_y_left_bottom;

  // FOR NOW just transmit 1 byte of 01010101 :) 
  assign RxD_data = 8'b01010101;
  always_ff @(posedge clk_65mhz) begin
    if (sys_rst) begin
        start_byte <= 0;
    end else begin
        if (TxD_busy == 0) begin
            start_byte <= 1;
        end else begin
            start_byte <= 0; 
        end
        
        if (start_byte == 1) begin
            start_byte <= 0; 
        end

    end
  end 

 // need to transmit x, y coordinate, 10 bits, 11 bits [10:0] [9:0]
  transmitter t1 (.clk(clk_65mhz), 
              .TxD_start(start_byte),     //pulled high when data is ready for transmit
              .rst(sys_rst),
              .TxD_data(RxD_data),    //should just transmit what it receives
              .TxD(uart_rxd_out),
              .TxD_busy(TxD_busy)); //  goes low when done transmitting
  
endmodule


`default_nettype wire
