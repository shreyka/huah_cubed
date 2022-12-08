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
  
   ila_0 test(.clk(clk_65mhz), 
              .probe0(RxD_data_ready), 
              .probe1(jc[0]), 
              .probe2(valid_data), 
              .probe3(RxD_data), 
              .probe4(left_hand_x_bottom_from_camera_2), 
              .probe5(left_hand_y_bottom_from_camera_2),
              .probe6(serial_buffer),
              .probe7(TEST2),
              .probe8(TEST3)); 

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
    .transmit_xy_update(transmit)

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

  logic TxD_busy, TxD, RxD_data_ready, transmit;
  logic [7:0] RxD_data;

  logic uart_txd_in;
  assign uart_txd_in = jc[0];

  logic baud;
  logic [15:0] counter;

  receiver r1 (.clk(clk_65mhz),
              .RxD(uart_txd_in),
              .rst(sys_rst),
              .RxD_data_ready(RxD_data_ready),
              .RxD_data(RxD_data),
              .baud(baud),
              .counter(counter));

   // TODO change rxd data to be intermediate variable that updates on data_ready

  logic [2:0] serial_counter;

  logic [47:0] serial_buffer; 
  logic valid_data;
  logic TEST2;
  logic TEST3;

  always_comb begin 
    // valid_data = (serial_buffer[39:16] == 6'hFFFFFF);

  end 


  always_ff @(posedge clk_65mhz) begin
    if (sys_rst) begin
      led <= 0;
      serial_counter <= 0; 
      valid_data <= 0;
      TEST2 <= 0;
    end else begin 
      led[0] <= RxD_data_ready;
      led[2] <= uart_txd_in;
      led[10:3] <= RxD_data;

      if(serial_buffer[47:40] == 2'hFF) begin 
      // if(serial_buffer[39:24] == 4'hFFFF) begin 
      // if(serial_buffer[39:16] == 6'hFFFFFF) begin 
      // if(serial_buffer[39:32] == 2'hFF &&
        //  serial_buffer[31:24] == 2'hFF &&
        //  serial_buffer[23:16] == 2'hFF) begin 

        valid_data <= 1;
        // left_hand_x_bottom_from_camera_2[11:3] <= serial_buffer[31:24];
        // left_hand_x_bottom_from_camera_2[3:0] <= serial_buffer[23:20];
        // left_hand_y_bottom_from_camera_2[11:8] <= serial_buffer[19:16];
        // left_hand_y_bottom_from_camera_2[7:0] <= serial_buffer[15:8];

      end else begin
        valid_data <= 0; 
      end 

      if(serial_buffer[39:32] == 2'hFF) begin 
        TEST2 <= 1;
      end else begin
        TEST2 <= 0; 
      end 

      if (serial_buffer[23:0] != 6'hFFFFFF && serial_buffer[23:0] != 6'hFFFFEF) begin
        TEST3 <= 1;
      end else begin
        TEST3 <= 0; 
      end

      if (RxD_data_ready) begin
        serial_buffer[7:0] <= RxD_data;
        serial_buffer[15:8] <= serial_buffer[7:0];
        serial_buffer[23:16] <= serial_buffer[15:8];
        serial_buffer[31:24] <= serial_buffer[23:16];
        serial_buffer[39:32] <= serial_buffer[31:24];
        serial_buffer[47:40] <= serial_buffer[39:32];
      end
        

      
    end 

  end

  logic [11:0] left_hand_x_bottom_from_camera_2; 
  logic [11:0] left_hand_y_bottom_from_camera_2; 


  seven_segment_controller ssc_uut(
        .clk_in(clk_65mhz),
        .rst_in(sys_rst),
        .val_in({left_hand_x_bottom_from_camera_2, 2'h00, left_hand_y_bottom_from_camera_2}),
        // .val_in(uart_txd_in), // this shows 1
        // .val_in(receive),  // the data is never received. RxD_data_ready does not go high
        .cat_out({cag, caf, cae, cad, cac, cab, caa}),
        .an_out(an));

 // need to transmit x, y coordinate, 10 bits, 11 bits [10:0] [9:0]
//   transmitter t1 (.clk(clk_65mhz), 
//               .TxD_start(transmit),     //pulled high when data is ready for transmit
//               .rst(sys_rst),
//               .TxD_data(RxD_data),    //should just transmit what it receives
//               .TxD(uart_rxd_out),
//               .TxD_busy(TxD_busy));
  
endmodule


`default_nettype wire
