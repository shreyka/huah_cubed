// `default_nettype none

// module seven_segment_controller_decimal #(parameter COUNT_TO = 'd100_000) (
//       input wire         clk_in,
//       input wire         rst_in,
//       input wire [31:0]  val_in, // button input
//       output logic[6:0]   cat_out, // specific led light up
//       output logic[7:0]   an_out // which one to light up (disable to light up)
//   );

//   logic [7:0]	segment_state;
//   logic [31:0]	segment_counter;
//   logic [3:0]	routed_vals;
//   logic [6:0]	led_out;

//   always_comb begin
//     if(segment_state == 8'b1000_0000) begin
//         routed_vals = val_in[31:28];
//     end else if(segment_state == 8'b0100_0000) begin
//         routed_vals = val_in[27:24];
//     end else if(segment_state == 8'b0010_0000) begin
//         routed_vals = val_in[23:20];
//     end else if(segment_state == 8'b0001_0000) begin
//         routed_vals = val_in[19:16];
//     end else if(segment_state == 8'b0000_1000) begin
//         routed_vals = val_in[15:12];
//     end else if(segment_state == 8'b0000_0100) begin
//         routed_vals = val_in[11:8];
//     end else if(segment_state == 8'b0000_0010) begin
//         routed_vals = val_in[7:4];
//     end else begin// if(segment_state == 8'b0000_0001) begin
//         routed_vals = val_in[3:0];
//     end
//   end

//   bto7s mbto7s(
//     .x_in(routed_vals), .s_out(led_out)
//   );
//   assign cat_out = ~led_out;
//   assign an_out = ~segment_state;
  
//   always_ff @(posedge clk_in) begin
//     if (rst_in) begin
//       segment_state <= 8'b0000_0001; //enables only the last led to the right
//       segment_counter <= 32'b0; //reset the counter
//     end else begin
//       if (segment_counter == COUNT_TO) begin
//         segment_counter <= 32'd0; //reset the counter
//         segment_state <= {segment_state[6:0], segment_state[7]};
//     	end else begin
//     	  segment_counter <= segment_counter + 1; //increment by 1
//     	end
//     end
//   end
// endmodule // seven_segment_controller

// module bto7s(
//             input wire [3:0]   x_in,
//             output logic [6:0] s_out
//       );

//       logic [15:0] num;
//       logic sa, sb, sc, sd, se, sf, sg;
      
//       assign num[0] = ~x_in[3] && ~x_in[2] && ~x_in[1] && ~x_in[0];
//       assign num[1] = ~x_in[3] && ~x_in[2] && ~x_in[1] && x_in[0];
//       assign num[2] = x_in == 4'd2;
//       assign num[3] = x_in == 4'd3;
//       assign num[4] = x_in == 4'd4;
//       assign num[5] = x_in == 4'd5;
//       assign num[6] = x_in == 4'd6;
//       assign num[7] = x_in == 4'd7;
//       assign num[8] = x_in == 4'd8;
//       assign num[9] = x_in == 4'd9;
//       assign num[10] = x_in == 4'd10;
//       assign num[11] = x_in == 4'd11;
//       assign num[12] = x_in == 4'd12;
//       assign num[13] = x_in == 4'd13;
//       assign num[14] = x_in == 4'd14;
//       assign num[15] = x_in == 4'd15;

//       assign sa = ~(num[1] || num[4] || num[11] || num[13]);
//       assign sb = ~(num[5] || num[6] || num[11] || num[12] || num[14] || num[15]);
//       assign sc = ~(num[2] || num[12] || num[14] || num[15]);
//       assign sd = ~(num[1] || num[4] || num[7] || num[10] || num[15]);
//       assign se = ~(num[1] || num[3] || num[4] || num[5] || num[7] || num[9]);
//       assign sf = ~(num[1] || num[2] || num[3] || num[7] || num[13]);
//       assign sg = ~(num[0] || num[1] || num[7] || num[12]);
//       assign s_out = {sg, sf, se, sd, sc, sb, sa};
// endmodule

// `default_nettype wire