module threshold_multi(
  input wire [2:0] sel_in,
  input wire [3:0] r_in, g_in, b_in,
  input wire [3:0] y_in, cr_in, cb_in,
  input wire [3:0] lower_bound_in, upper_bound_in,
  output logic mask_out_cr,
  output logic mask_out_cb,
  output logic mask_out_green,
  output logic [3:0] channel_out
);

  logic [3:0] channel;
  assign channel_out = channel;
  always_comb begin
    case (sel_in)
      3'b000: channel = g_in;
      3'b001: channel = r_in;
      3'b010: channel = b_in;
      3'b011: channel = 0;
      3'b100: channel = y_in;
      3'b101: channel = cr_in;
      3'b110: channel = cb_in;
      3'b111: channel = 0;
      default: channel = 0;
    endcase
  end
  // assign mask_out_cr = (cr_in[2:0] > lower_bound_in) && (cr_in[3:1] < upper_bound_in);
  // assign mask_out_cb = (cb_in[2:0] > lower_bound_in) && (cb_in[3:1] < upper_bound_in);

  assign mask_out_cr = (cr_in[2:0] > lower_bound_in) && (cr_in[3:1] < upper_bound_in);
  assign mask_out_cb = (cb_in[2:0] > 3'b010) && (cb_in[3:1] < 3'b100);
  assign mask_out_green = (cb_in[2:0] > 0) && (cb_in[3:1] < 1) && (cr_in[2:0] > 0) && (cr_in[3:1] < 1);



endmodule


/*
sw[6]:
  - 1 masked values through
  - 0 regular image through
sw[7]
*/