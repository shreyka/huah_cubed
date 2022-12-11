`timescale 1ns / 1ps
`default_nettype none

module transmitter_camera_2(
  input wire clk_65mhz, //clock @ 100 mhz
  input wire sys_rst, //btnc (used for reset)

  input wire [11:0] hand_x_left_bottom,
  input wire [11:0] hand_y_left_bottom,
  input wire [11:0] hand_x_left_top,
  input wire [11:0] hand_y_left_top,

  output logic uart_rxd_out,
  output logic[1:0] jc, // for transmitting data, jc[1] is data line!!
  output logic [15:0] led //debugging

  );

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
// logic [7:0] data1;
// logic [7:0] data2;
// logic [7:0] data3;
// logic [7:0] data4;
// assign data1 = 8'b00111000; //38
// assign data2 = 8'b10111010; // BA
// assign data3 = 8'b00010101; // 15
// assign data4 = 8'b11111111; // FF

// assign RxD_data = 8'b10111010; 
logic [3:0] count; 

logic baud, TxD_busy, TxD, RxD_data_ready, start_byte;
logic [7:0] RxD_data; // data being sent 

assign jc[1] = uart_rxd_out;
assign led[10:3] = RxD_data; // data being sent 

transmitter t1 (.clk(clk_65mhz), 
            .TxD_start(start_byte),     //pulled high when data is ready for transmit
            .rst(sys_rst),
            .TxD_data(RxD_data),   // data being sent 
            .TxD(uart_rxd_out),
            .TxD_busy(TxD_busy)); //  goes low when done transmitting

logic [1:0] serial_state;
parameter IDLE = 0;
parameter TRANSMIT = 1; 

always_ff @(posedge clk_65mhz) begin
    if (sys_rst) begin
        start_byte <= 0;
        RxD_data <= 0;
        count <= 0;
    end else begin
        // send 3 FFs
        // send 3 bytes for hand left top 
        // then send 3 bytes for hand left bottom
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
                RxD_data <= 0; 
            end 

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




endmodule


`default_nettype wire