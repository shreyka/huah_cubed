`timescale 1ns / 1ps
`default_nettype none

module top_level(
  input wire clk_100mhz, //clock @ 100 mhz
  input wire btnc,
  input wire btnl,
  input wire btnr,
  input wire btnu,
  input wire btnd,

  //TEMP for score printer
  output logic [15:0] led,

  output logic [3:0] vga_r, vga_g, vga_b,
  output logic vga_hs, vga_vs
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
  logic [11:0] hand_x_right_bottom;
  logic [11:0] hand_y_right_bottom;
  logic [13:0] hand_z_right_bottom;
  logic [11:0] hand_x_right_top;
  logic [11:0] hand_y_right_top;
  logic [13:0] hand_z_right_top;
  logic [11:0] head_x;
  logic [11:0] head_y;
  logic [13:0] head_z;
  
  ////////////////////////////////////////////////////
  // REQUIRED LOGIC/WIRES
  //
  // SECTION: GAME LOGIC AND RENDERER
  //

  logic [4:0] r_out;
  logic [5:0] g_out;
  logic [4:0] b_out;

  //TEMP to show score
  logic [11:0] score;
  assign led = score;

  ////////////////////////////////////////////////////
  // MODULES
  //
  // contains aggregated modules that are encapulated for simplicity
  // and so that unit/integration testing can be done more easily
  //

  // temporary module to test hand movement
  hand_controller hand_controller(
    .clk_in(clk_65mhz),
    .rst_in(btnc),
    .left_button(btnl),
    .right_button(btnr),
    .up_button(btnu),
    .down_button(btnd),

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
    .hand_x_left_bottom(hand_x_left_bottom),
    .hand_y_left_bottom(hand_y_left_bottom),
    .hand_z_left_bottom(hand_z_left_bottom),
    .hand_x_left_top(hand_x_left_top),
    .hand_y_left_top(hand_y_left_top),
    .hand_z_left_top(hand_z_left_top),
    .hand_x_right_bottom(hand_x_right_bottom),
    .hand_y_right_bottom(hand_y_right_bottom),
    .hand_z_right_bottom(hand_z_right_bottom),
    .hand_x_right_top(hand_x_right_top),
    .hand_y_right_top(hand_y_right_top),
    .hand_z_right_top(hand_z_right_top),
    .head_x(head_x),
    .head_y(head_y),
    .head_z(head_z),

    // outputs
    .r_out(r_out),
    .g_out(g_out),
    .b_out(b_out),
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
