`timescale 1ns / 1ps
`default_nettype none
module receiver_camera_1(
  input wire clk_65mhz,
  input wire sys_rst, 
  input wire [7:0] jc,


  output logic [15:0] led,
  output logic [11:0] hand_z_left_top,
  output logic [11:0] hand_z_left_bottom

  );

  logic TxD_busy, TxD, RxD_data_ready;
  logic [7:0] RxD_data;

  logic uart_txd_in;
  assign uart_txd_in = jc[0];

  // logic baud;
  // logic [15:0] counter;


  // ila_0 test(.clk(clk_65mhz), 
  //             .probe0(RxD_data_ready), 
  //             .probe1(jc[0]), 
  //             .probe2(baud), 
  //             .probe3(RxD_data), 
  //             .probe4(left_hand_x_bottom_from_camera_2), 
  //             .probe5(left_hand_y_bottom_from_camera_2),
  //             .probe6(left_hand_x_top_from_camera_2), 
  //             .probe7(left_hand_y_top_from_camera_2),
  //             .probe8(serial_buffer)); 

  receiver r1 (.clk(clk_65mhz),
              .RxD(uart_txd_in),
              .rst(sys_rst),
              .RxD_data_ready(RxD_data_ready),
              .RxD_data(RxD_data));
              // .baud(baud),
              // .counter(counter));

  // logic [47:0] serial_buffer; 
  logic [71:0] serial_buffer; 
  logic [11:0] left_hand_x_bottom_from_camera_2; 
  logic [11:0] left_hand_y_bottom_from_camera_2; 
  logic [11:0] left_hand_x_top_from_camera_2; 
  logic [11:0] left_hand_y_top_from_camera_2; 

  // assign hand_z_left_top = left_hand_x_top_from_camera_2;
  // assign hand_z_left_bottom = left_hand_x_bottom_from_camera_2;

  always_comb begin 
    if (left_hand_x_top_from_camera_2 >= 12'h274) begin 
      hand_z_left_top = last_x_top;
    end else begin 
      hand_z_left_top = left_hand_x_top_from_camera_2;
    end 

    if (left_hand_x_bottom_from_camera_2 >= 12'h274) begin 
      hand_z_left_bottom = last_x_bottom ;
    end else begin 
      hand_z_left_bottom = left_hand_x_bottom_from_camera_2;
    end 

  end 

  logic [11:0] last_y_bottom;
  logic [11:0] last_x_bottom;
  logic [11:0] last_y_top;
  logic [11:0] last_x_top;


  always_ff @(posedge clk_65mhz) begin
    if (sys_rst) begin
      led <= 0;
      serial_buffer <= 0;
      last_y_bottom <= 0;
      last_x_bottom <= 0;
      last_y_top <= 0;
      last_x_top <= 0;
    end else begin 
      led[0] <= RxD_data_ready;
      led[2] <= uart_txd_in;
      led[10:3] <= RxD_data;

      if (RxD_data_ready) begin
        serial_buffer[7:0] <= RxD_data;
        serial_buffer[15:8] <= serial_buffer[7:0];
        serial_buffer[23:16] <= serial_buffer[15:8];
        serial_buffer[31:24] <= serial_buffer[23:16];
        serial_buffer[39:32] <= serial_buffer[31:24];
        serial_buffer[47:40] <= serial_buffer[39:32];
        serial_buffer[55:48] <= serial_buffer[47:40];
        serial_buffer[63:56] <= serial_buffer[55:48];
        serial_buffer[71:64] <= serial_buffer[63:56];


        if(serial_buffer[71:48] == 24'hFFFFFF) begin 

          if (left_hand_y_bottom_from_camera_2 <= 12'h1df) begin
            last_y_bottom <= left_hand_y_bottom_from_camera_2;
          end 
          
          if (left_hand_x_bottom_from_camera_2 <= 12'h274) begin 
            last_x_bottom <= left_hand_x_bottom_from_camera_2;
          end

          if (left_hand_y_top_from_camera_2 <= 12'h1df) begin
            last_y_top <= left_hand_y_top_from_camera_2;
          end 

          if (left_hand_x_top_from_camera_2 <= 12'h274) begin 
            last_x_top <= left_hand_x_top_from_camera_2;
          end

          left_hand_x_bottom_from_camera_2[11:4] <= serial_buffer[23:16];
          left_hand_x_bottom_from_camera_2[3:0] <= serial_buffer[7:4];
          left_hand_y_bottom_from_camera_2[11:8] <= serial_buffer[3:0];
          left_hand_y_bottom_from_camera_2[7:0] <= serial_buffer[15:8];

          left_hand_x_top_from_camera_2[11:4] <= serial_buffer[47:40];
          left_hand_x_top_from_camera_2[3:0] <= serial_buffer[31:28];
          left_hand_y_top_from_camera_2[11:8] <= serial_buffer[27:24];
          left_hand_y_top_from_camera_2[7:0] <= serial_buffer[39:32];
        end 


        // if(serial_buffer[47:24] == 24'hFFFFFF) begin 
        //   left_hand_x_bottom_from_camera_2[11:4] <= serial_buffer[23:16];
        //   left_hand_x_bottom_from_camera_2[3:0] <= serial_buffer[7:4];
        //   left_hand_y_bottom_from_camera_2[11:8] <= serial_buffer[3:0];
        //   left_hand_y_bottom_from_camera_2[7:0] <= serial_buffer[15:8];
        // end 
      end
        

      
    end 

  end

  


endmodule


`default_nettype wire
