`timescale 1ns / 1ps
`default_nettype none

// module top_level_CAMERA_2(
module top_level(
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

  output logic[1:0] jc

  // input wire [1:0] jd

  );

  //system reset switch linking
  logic sys_rst; //global system reset
  assign sys_rst = btnc; //just done to make sys_rst more obvious

  // logic CAMERA_1; 
  // logic CAMERA_2;
  // assign CAMERA_1 = sw[0];
  // assign CAMERA_2 = ~sw[0]; 
  

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

  logic baud, TxD_busy, TxD, RxD_data_ready, start_transmit, start_byte;
  logic [7:0] RxD_data; // data being sent 

  // assign jc[1] = baud;
  logic TEST;
  assign jc[1] = uart_rxd_out;
  assign jc[0] = TEST;
  assign led[10:3] = RxD_data; // data being sent 

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
  // assign RxD_data = 8'b01010101;
  // assign RxD_data = 8'b00000000;
  // assign RxD_data = 8'b00111000; 
  logic [7:0] data1;
  logic [7:0] data2;
  logic [7:0] data3;
  logic [7:0] data4;
  assign data1 = 8'b00111000; //38
  assign data2 = 8'b10111010; // BA
  assign data3 = 8'b00010101; // 15
  assign data4 = 8'b11111111; // FF
  // assign data5 = 8'b10000000; // 80

  // assign RxD_data = 8'b10111010; 
  logic [3:0] count; 

  logic [1:0] serial_state;
  parameter IDLE = 0;
  parameter TRANSMIT = 1; 
 
  always_ff @(posedge clk_65mhz) begin
    if (sys_rst) begin
        start_byte <= 0;
        RxD_data <= data1;
        count <= 0;
        TEST <= 0;
    end else begin
      // send 3 FFs
      // send 3 bytes for hand left bottom
      // TO DO send 3 bytes for hand left top
      if (TxD_busy == 0) begin
            start_byte <= 1;

            if (count <= 7) begin 
              count <= count + 1;
            end else begin
              count <= 0;
            end 

            if (count <= 2) begin
              RxD_data <= 8'b11111111; 
            end else if (count == 3) begin 
              RxD_data <=  hand_x_left_top[11:4]; 
            end else if (count == 4) begin /// SWITCHED ORDER so FF not possible
              RxD_data <= hand_y_left_top[7:0];
            end else if (count == 5) begin
              RxD_data <= {hand_x_left_top[3:0],hand_y_left_top[11:8]};
            end else if (count == 6) begin 
              RxD_data <=  hand_x_left_bottom[11:4]; 
            end else if (count == 7) begin /// SWITCHED ORDER so FF not possible
              RxD_data <= hand_y_left_bottom[7:0];
            end else if (count == 8) begin
              RxD_data <= {hand_x_left_bottom[3:0],hand_y_left_bottom[11:8]};
            end else begin
              RxD_data <= 0; //FF
              // count <= 0; 
            end 
            // end 
        end else begin
            start_byte <= 0; 
        end
      // case(serial_state)
      //   IDLE: begin 
      //     if (start_transmit) begin 
      //       serial_state <= TRANSMIT;
      //       count <= 0; 
      //     end 
      //   end 

      //   TRANSMIT: begin
      //     if (TxD_busy == 0) begin
      //       start_byte <= 1;

      //       count <= count + 1;

      //       if (count == 0) begin
      //         RxD_data <=  hand_x_left_bottom[11:4]; 
      //       end else if (count == 1) begin
      //         RxD_data <= hand_x_left_bottom[3:0] + hand_y_left_bottom[11:8];
      //       end else if (count == 2) begin
      //         RxD_data <= hand_y_left_bottom[7:0];
      //       end else if (count == 3) begin
      //         RxD_data <= count; //FF
      //       end else begin
      //         serial_state <= IDLE;
      //         count <= 0; 
      //       end 
      //       // end 
      //   end else begin
      //       start_byte <= 0; 
      //   end
      //   end 
      // endcase 

        
        
        

    end
  end 

  // assign RxD_data = hand_x_left_bottom[11:4];

 // need to transmit x, y coordinate, 10 bits, 11 bits [10:0] [9:0]
  transmitter t1 (.clk(clk_65mhz), 
              .TxD_start(start_byte),     //pulled high when data is ready for transmit
              .rst(sys_rst),
              .TxD_data(RxD_data),   // data being sent 
              .TxD(uart_rxd_out),
              .TxD_busy(TxD_busy)); //  goes low when done transmitting


  // logic RxD_data_ready;
  logic [7:0] DATA_RECEIVED;
  // receiver TEST_RECEIVER (.clk(clk_65mhz),
  //             .RxD(jd[0]), // data from transmitter
  //             .rst(sys_rst),
  //             .RxD_data_ready(RxD_data_ready),
  //             .RxD_data(DATA_RECEIVED));

  logic [7:0] display_byte;
  assign display_byte = RxD_data; 

  seven_segment_controller ssc_uut(
        .clk_in(clk_65mhz),
        .rst_in(sys_rst),
        // .val_in({DATA_RECEIVED, 8'b00000000, RxD_data}),
        .val_in({hand_x_left_bottom, 8'b00000000, hand_y_left_bottom}),
        .cat_out({cag, caf, cae, cad, cac, cab, caa}),
        .an_out(an));
  
endmodule


`default_nettype wire
