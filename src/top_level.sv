`timescale 1ns / 1ps
`default_nettype none

module top_level(
  input wire clk_100mhz, //clock @ 100 mhz
  input wire btnc,
  input wire btnl,
  input wire btnr,
  input wire btnu,
  input wire btnd,

  input wire [15:0] sw,

  input wire [7:0] ja, //lower 8 bits of data from camera
  input wire [2:0] jb, //upper three bits from camera (return clock, vsync, hsync)
  input wire [7:0] jc,
  output logic jbclk,  //signal we provide to camera
  output logic jblock, //signal for resetting camera

  //TEMP for score printer
  output logic [15:0] led,

  output logic [3:0] vga_r, vga_g, vga_b,
  output logic vga_hs, vga_vs,
  output logic [7:0] an,
  output logic caa,cab,cac,cad,cae,caf,cag
  );

  ////////////////////////////////////////////////////
  // VGA INFORMATION
  //
  // note that the vga_gen is what gives us the hcount, vcount
  // combinations (0-1023, then 0-767)
  //

  // we need the 65mhz clock for the VGA
  // our resolution is: 1024x768 at 60Hz
  // reusing from lab 3
  logic clk_65mhz;
  clk_wiz_lab3 clk_gen(
    .clk_in1(clk_100mhz),
    .clk_out1(clk_65mhz)); 
  
  // MORE VGA REQUIRED DATA
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

  ////////////////////////////////////////////////////
  // REQUIRED LOGIC/WIRES
  //
  // SECTION: CAMERA DATA
  //

  logic [11:0] hand_x_left_bottom;
  logic [11:0] hand_y_left_bottom;
  logic [13:0] hand_z_left_bottom;
  logic [11:0] hand_x_left_top;
  logic [11:0] hand_y_left_top;
  logic [13:0] hand_z_left_top;
  logic [11:0] head_x;
  logic [11:0] head_y;
  logic [13:0] head_z;
  
  ////////////////////////////////////////////////////
  // REQUIRED LOGIC/WIRES
  //
  // SECTION: GAME LOGIC AND RENDERER
  //

  logic [3:0] r_out;
  logic [3:0] g_out;
  logic [3:0] b_out;

  logic [11:0] score;
  assign led = score;

  ////////////////////////////////////////////////////
  // MODULES
  //
  // contains aggregated modules that are encapulated for simplicity
  // and so that unit/integration testing can be done more easily
  //

  // temporary module to test hand movement
  // hand_controller hand_controller(
  //   .clk_in(clk_65mhz),
  //   .rst_in(btnc),
  //   .left_button(btnl),
  //   .right_button(btnr),
  //   .up_button(btnu),
  //   .down_button(btnd),

  //   .hand_x_left_bottom(hand_x_left_bottom),
  //   .hand_y_left_bottom(hand_y_left_bottom),
  //   .hand_z_left_bottom(hand_z_left_bottom),
  //   .hand_x_left_top(hand_x_left_top),
  //   .hand_y_left_top(hand_y_left_top),
  //   .hand_z_left_top(hand_z_left_top)
  // );

  top_level_camera_serial top_level_camera_serial(
    .clk_65mhz(clk_65mhz), //clock @ 100 mhz
    .sw(sw), //switches
    .btnc(btnc), //btnc (used for reset)
    .ja(ja), //lower 8 bits of data from camera
    .jb(jb), //upper three bits from camera (return clock(), vsync(), hsync)
    .jc(jc),

    .jbclk(jbclk),  //signal we provide to camera
    .jblock(jblock), //signal for resetting camera
    .led(), //just here for the funs
    .an(an),
    .caa(caa),
    .cab(cab),
    .cac(cac),
    .cad(cad),
    .cae(cae),
    .caf(caf),
    .cag(cag),
    .hand_x_left_bottom(hand_x_left_bottom),
    .hand_y_left_bottom(hand_y_left_bottom),
    .hand_z_left_bottom(hand_z_left_bottom),
    .hand_x_left_top(hand_x_left_top),
    .hand_y_left_top(hand_y_left_top),
    .hand_z_left_top(hand_z_left_top)
  );

  game_logic_and_renderer game_logic_and_renderer(
    .clk_in(clk_65mhz),
    .rst_in(btnc),
    // retrieve from VGA
    .x_in(hcount),
    .y_in(vcount),

    // retrieve from camera data
    .hand_x_left_bottom(hand_x_left_bottom + 1800),
    .hand_y_left_bottom(hand_y_left_bottom + 1800),
    .hand_z_left_bottom(13'b0),
    .hand_x_left_top(hand_x_left_bottom + 1800),
    .hand_y_left_top(hand_y_left_bottom + 1800),
    .hand_z_left_top(13'b0),
    .head_x(sw[0] ? 1801 : hand_x_left_top),
    .head_y(sw[0] ? 1801 : hand_y_left_top),
    .head_z(-300),

    // outputs
    .r_out(r_out),
    .g_out(g_out),  
    .b_out(b_out),
    .TEST_LED(),
    .score_out(score)
  );

  //TEMP
  

  ////////////////////////////////////////////////////
  // OUTPUT TO PIXELS
  //
  //
  //

  assign vga_r = ~blank ? r_out[3:0] : 0;
  assign vga_g = ~blank ? g_out[3:0] : 0;
  assign vga_b = ~blank ? b_out[3:0] : 0;

  assign vga_hs = ~hsync;
  assign vga_vs = ~vsync;
endmodule

`default_nettype wire
