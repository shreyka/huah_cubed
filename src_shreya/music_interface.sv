`timescale 1ns / 1ps
`default_nettype none

module music_interface(
    input wire clk_65mhz,
    input wire rst,
    input wire valid_in,        //for sending a hit
    input wire start_music,
    output logic jd1
);

logic start_transmit_bit, TxD_busy;
logic [7:0] sent_data;

logic start_count;
logic [20:0] counter;

transmitter t1 (.clk(clk_65mhz), 
              .TxD_start(start_transmit_bit),     //pulled high when data is ready for transmit
              .rst(rst),
              .TxD_data(sent_data),   // data being sent 
              .TxD(jd1),
              .TxD_busy(TxD_busy)); //  goes low when done transmitting


always_ff @(posedge clk_65mhz)begin
    if (rst)begin
        start_transmit_bit <= 0;
        sent_data <= 0;
        counter <= 0;
        start_count <= 0;
    end else begin
        if (valid_in || start_music)begin
            start_count <= 1;
            counter <= 1;
            start_transmit_bit <= TxD_busy ? 0 : 1;
            sent_data <= 8'b11111111;
        end else if (start_count) begin
            start_count <= (counter == 0) ? 0 : 1;
            counter <= (counter == 0) ? 0 : (counter + 1);
            start_transmit_bit <= TxD_busy ? 0 : 1;
            sent_data <= 8'b11111111;
        end else begin
            start_transmit_bit <= 0;
            sent_data <= 0;
        end
    end
end

endmodule

`default_nettype wire