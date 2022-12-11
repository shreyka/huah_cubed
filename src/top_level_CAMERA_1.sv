`timescale 1ns / 1ps
`default_nettype none
module top_level(
// module top_level_CAMERA_1(
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
//  input wire uart_txd_in,
  // output logic uart_rxd_out,

  input wire [7:0] jc

  );

  //system reset switch linking
  logic sys_rst; //global system reset
  assign sys_rst = btnc; //just done to make sys_rst more obvious
  
  //Generate 65 MHz:
  logic clk_65mhz; //65 MHz clock line
  logic clk_25mhz; //testing 25 MHz clock line too
  clk_wiz_1 clk_gen(
  .clk_in1(clk_100mhz),
  .clk_out1(clk_25mhz),
  .clk_out2(clk_65mhz)); //after frame buffer everything on clk_65mhz


  logic [11:0] hand_x_left_bottom; // goes from 0 to 274 (hex), or 0 to 638 (dec)
  logic [11:0] hand_y_left_bottom; // goes from 0 to 1df (hex), or 0 to 479 (dec)
  logic [13:0] hand_z_left_bottom; // same as x
  logic [11:0] hand_x_left_top; // goes from 0 to 274 (hex), or 0 to 638 (dec)
  logic [11:0] hand_y_left_top; // goes from 0 to 1df (hex), or 0 to 479 (dec)
  logic [13:0] hand_z_left_top; // same as x
  
  //  ila_0 test(.clk(clk_65mhz), 
  //             .probe0(jc[0]), 
  //             .probe1(hand_z_left_bottom), 
  //             .probe2(hand_z_left_top),
  //             .probe3(hand_x_left_top), 
  //             .probe4(hand_y_left_top)); 

  logic transmit; 

  //Generate VGA timing signals:

  logic [10:0] hcount;    // pixel on current line
  logic [9:0] vcount;     // line number
  logic hsync, vsync, blank; //control signals for vga

  vga vga_gen(
    .pixel_clk_in(clk_65mhz),
    .hcount_out(hcount),
    .vcount_out(vcount),
    .hsync_out(hsync),
    .vsync_out(vsync),
    .blank_out(blank));

  camera_top_level cam_uut(
    .clk_65mhz(clk_65mhz), //clock @ 100 mhz
    .sw(sw), //switches
    .sys_rst(sys_rst), //btnc (used for reset)

    .hcount(hcount),
    .vcount(vcount),
    .hsync(hsync),
    .vsync(vsync),
    .blank(blank),

    .ja(ja), //lower 8 bits of data from camera
    .jb(jb), //upper three bits from camera (return clock, vsync, hsync)
    .jbclk(jbclk),  //signal we provide to camera
    .jblock(jblock), //signal for resetting camera

    .hand_x_left_bottom(hand_x_left_bottom),
    .hand_y_left_bottom(hand_y_left_bottom),
    .hand_z_left_bottom(),
    .hand_x_left_top(hand_x_left_top),
    .hand_y_left_top(hand_y_left_top),
    .hand_z_left_top(),

    // outputs we can just ignore in final game
    // .led(led), //just here for the funs

    .vga_r(vga_r), .vga_g(vga_g), .vga_b(vga_b),
    .vga_hs(vga_hs), .vga_vs(vga_vs),
    .an(),
    .caa(),.cab(),.cac(),.cad(),.cae(),.caf(),.cag(),
    .transmit_xy_update(transmit)

  );


  receiver_camera_1 receiver_camera_1_uut(
    .clk_65mhz(clk_65mhz),
    .sys_rst(sys_rst), 
    .jc(jc),
    .led(led),
    .hand_z_left_top(hand_z_left_top),
    .hand_z_left_bottom(hand_z_left_bottom)
  );

  seven_segment_controller ssc_uut(
        .clk_in(clk_65mhz),
        .rst_in(sys_rst),
        // .val_in({left_hand_x_bottom_from_camera_2, 8'h00, left_hand_y_bottom_from_camera_2}),
        .val_in({hand_z_left_bottom, 8'h00, hand_z_left_top}),
        // .val_in(uart_txd_in), // this shows 1
        // .val_in(receive),  // the data is never received. RxD_data_ready does not go high
        .cat_out({cag, caf, cae, cad, cac, cab, caa}),
        .an_out(an));

  // IF CAMERA 1, need to receive y and z from camera 2
  // IF CAMERA 2, need to transmit y and z to camera 1
  
  
  // logic TxD_busy, TxD, RxD_data_ready, transmit;
  // logic [7:0] RxD_data;

  // logic uart_txd_in;
  // assign uart_txd_in = jc[0];

  // logic baud;
  // logic [15:0] counter;

  // receiver r1 (.clk(clk_65mhz),
  //             .RxD(uart_txd_in),
  //             .rst(sys_rst),
  //             .RxD_data_ready(RxD_data_ready),
  //             .RxD_data(RxD_data),
  //             .baud(baud),
  //             .counter(counter));

  // // logic [47:0] serial_buffer; 
  // logic [71:0] serial_buffer; 


  // always_ff @(posedge clk_65mhz) begin
  //   if (sys_rst) begin
  //     led <= 0;
  //     serial_buffer <= 0;
  //   end else begin 
  //     led[0] <= RxD_data_ready;
  //     led[2] <= uart_txd_in;
  //     led[10:3] <= RxD_data;

  //     if (RxD_data_ready) begin
  //       serial_buffer[7:0] <= RxD_data;
  //       serial_buffer[15:8] <= serial_buffer[7:0];
  //       serial_buffer[23:16] <= serial_buffer[15:8];
  //       serial_buffer[31:24] <= serial_buffer[23:16];
  //       serial_buffer[39:32] <= serial_buffer[31:24];
  //       serial_buffer[47:40] <= serial_buffer[39:32];
  //       serial_buffer[55:48] <= serial_buffer[47:40];
  //       serial_buffer[63:56] <= serial_buffer[55:48];
  //       serial_buffer[71:64] <= serial_buffer[63:56];


  //       if(serial_buffer[71:48] == 24'hFFFFFF) begin 
  //         left_hand_x_bottom_from_camera_2[11:4] <= serial_buffer[23:16];
  //         left_hand_x_bottom_from_camera_2[3:0] <= serial_buffer[7:4];
  //         left_hand_y_bottom_from_camera_2[11:8] <= serial_buffer[3:0];
  //         left_hand_y_bottom_from_camera_2[7:0] <= serial_buffer[15:8];

  //         left_hand_x_top_from_camera_2[11:4] <= serial_buffer[47:40];
  //         left_hand_x_top_from_camera_2[3:0] <= serial_buffer[31:28];
  //         left_hand_y_top_from_camera_2[11:8] <= serial_buffer[27:24];
  //         left_hand_y_top_from_camera_2[7:0] <= serial_buffer[31:24];
  //       end 


  //       // if(serial_buffer[47:24] == 24'hFFFFFF) begin 
  //       //   left_hand_x_bottom_from_camera_2[11:4] <= serial_buffer[23:16];
  //       //   left_hand_x_bottom_from_camera_2[3:0] <= serial_buffer[7:4];
  //       //   left_hand_y_bottom_from_camera_2[11:8] <= serial_buffer[3:0];
  //       //   left_hand_y_bottom_from_camera_2[7:0] <= serial_buffer[15:8];
  //       // end 
  //     end
        

      
  //   end 

  // end

  // logic [11:0] left_hand_x_bottom_from_camera_2; 
  // logic [11:0] left_hand_y_bottom_from_camera_2; 
  // logic [11:0] left_hand_x_top_from_camera_2; 
  // logic [11:0] left_hand_y_top_from_camera_2; 


  

 // need to transmit x, y coordinate, 10 bits, 11 bits [10:0] [9:0]
//   transmitter t1 (.clk(clk_65mhz), 
//               .TxD_start(transmit),     //pulled high when data is ready for transmit
//               .rst(sys_rst),
//               .TxD_data(RxD_data),    //should just transmit what it receives
//               .TxD(uart_rxd_out),
//               .TxD_busy(TxD_busy));
  
endmodule


`default_nettype wire
