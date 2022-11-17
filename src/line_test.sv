`timescale 1ns / 1ps
`default_nettype none


module line_test( 
    input wire clk_65mhz, 
    input wire rst_in,
    input wire [10:0] hcount,
    input wire [9:0] vcount,
    input wire mask_cr,
    output wire lin_reg_line

);

linear_regr lruut( // for Cb
    .clk_in(clk_65mhz),
    .rst_in(rst_in),
    .x_in(hcount),  //TODO: needs to use pipelined signal! (PS3)
    .y_in(vcount), //TODO: needs to use pipelined signal! (PS3)
    .valid_in(mask_cr),
    .tabulate_in((hcount==0 && vcount==0)),
    .a_out(lin_reg_a), // todo create this variable
    .b_out(lin_reg_b),// todo create this variable
    .valid_out(new_lin_reg)); // todo create this variable 

logic signed [14:0] lin_reg_a;
logic signed [13:0] lin_reg_b;
logic new_lin_reg;

logic signed [14:0] draw_a;
logic signed [13:0] draw_b; 

always_ff @(posedge clk_65mhz)begin
    if (new_lin_reg) begin
        draw_a <= lin_reg_a;
        draw_b <= lin_reg_b; 
    end

end

logic signed [6:0] mx_plus_b;
assign mx_plus_b = $signed({1'b0 , hcount})*(draw_b >>> 3) + (draw_a >>> 3); 

assign lin_reg_line = (vcount == mx_plus_b) ? 1 : 0;
// assign lin_reg_line = ((vcount == hcount*(draw_b >>> 3) + (draw_a >>> 3))) ? 1 : 0;

endmodule 

`default_nettype wire