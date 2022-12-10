`timescale 1ns / 1ps
`default_nettype none

module baudGen(
    input wire clk,    //65 MHz Clock 
    input wire rst,
    output logic baudBit
    );
    // 65 MHz
    localparam ACC_SIZE = 14;
    localparam INCREMENT = 29;
    
    // 25MHz
    // localparam ACC_SIZE = 13;
    // localparam INCREMENT = 19;
    logic [ACC_SIZE:0] acc = 0; //15 bits total


    assign baudBit = acc[ACC_SIZE];

    always_ff @(posedge clk)begin
        if (rst)begin
            acc <= 0;
        end else begin
            acc <= acc[ACC_SIZE-1:0] + INCREMENT;
        end 
    end

    
endmodule



module transmitter(
    input  wire clk,
    input  wire TxD_start,
    input  wire [7:0] TxD_data,
    input wire rst,
    output logic TxD,
    output logic TxD_busy
    );

    logic [3:0] state;
    logic [2:0] i;
    logic ready;

    logic baud;

    baudGen baud1 (.clk(clk), .rst(rst), .baudBit(baud));

    always_comb begin
        ready = (state == 0);
        TxD_busy = ~ready;
    end

    always_ff @(posedge clk)begin
        if (rst)begin
            TxD <= 1;
            state <= 0;
            i <= 0;
        end else begin
            case(state)
                0: begin
                    if (TxD_start)begin
                        TxD <= 0;  //start bit
                        state <= state + 1;
                    end else begin
                        TxD <= 1;   //idle
                    end
                end
                1: begin
                    if (baud)begin
                        TxD <= TxD_data[i];
                        i <= i + 1;

                        if (i >= 7)begin
                            i <= 0;
                            state <= state + 1;
                        end
                    end
                end
                2: begin
                    if (baud)begin
                        TxD <= 1;          //stop bit
                        state <= 0; 
                    end
                end
            endcase
        end
    end
endmodule

module receiver(
    input wire clk,
    input wire RxD,
    input wire rst,
    output logic RxD_data_ready,
    output logic [7:0] RxD_data
    // output logic baud,
    // output logic[15:0] counter
    );

    logic [3:0] state;
    logic [7:0] data_out;
    logic [2:0] i;
    logic baud;
    logic baud_rst;
   baudGen baud2 (.clk(clk), .rst(baud_rst), .baudBit(baud));

   logic [15:0] counter; 
    parameter HALF_CYCLE = 282;
    parameter FULL_CYCLE = 564;

    always_ff @(posedge clk)begin
        if (rst)begin
            state <= 0;
            data_out <= 0;
            i <= 0;
            RxD_data_ready <= 0;
            RxD_data <= 0;
            counter <= 0;
            baud_rst <= 0;
        end else begin
            case(state)
                0: begin    //idle state
                    RxD_data_ready <= 0;
                    data_out <= 0;
                    if (~RxD)begin
                        state <= state + 1;
                        counter <= 1;
                    end
                end

                1: begin  // half cycle counter
                    counter <= counter + 1; 
                    if (counter == HALF_CYCLE) begin
                        if (~RxD) begin // if its still low then not a glitch
                            baud_rst <= 1;
                            state <= state + 1;
                        end else begin  // otherwise return to state 0
                            state <= 0;
                        end
                    end
                end

                2: begin    //receiving data
                    baud_rst <= 0; 
                    if (baud)begin
                        data_out[i] <= RxD;
                        i <= i + 1;
                        if (i >= 7) begin
                            i <= 0;
                            state <= state + 1;
                        end
                    end
                end
                3: begin    //done receiving
                    if (baud) begin
                        if (RxD)begin   //stop bit = 1
                            state <= 0;
                            // state <= 4;
                            RxD_data_ready <= 1;
                            RxD_data <= data_out;
                        end else begin
                            data_out <= 0;
                            RxD_data_ready <= 0;
                            state <= 0;
                        end
                    end
                end

                // 4: begin 
                //     if (baud) begin 
                //         RxD_data_ready <= 1;
                //         state <= 0;
                //     end
                // end

                default: state <= 0;
            endcase
            // case(state)
            //     0: begin    //idle state
            //         RxD_data_ready <= 0;
            //         data_out <= 0;
            //         if (~RxD && baud)begin
            //             state <= state + 1;
            //         end
            //     end
            //     1: begin    //receiving data
            //         if (baud)begin
            //             data_out[i] <= RxD;
            //             i <= i + 1;
            //             if (i >= 7) begin
            //                 i <= 0;
            //                 state <= state + 1;
            //             end
            //         end
            //     end
            //     2: begin    //done receiving
            //         if (baud) begin
            //             if (RxD)begin   //stop bit = 1
            //                 state <= 0;
            //                 RxD_data_ready <= 1;
            //                 RxD_data <= data_out;
            //             end else begin
            //                 data_out <= 0;
            //                 RxD_data_ready <= 0;
            //                 state <= 0;
            //             end
            //         end
            //     end
            //     default: state <= 0;
            // endcase

            // if (RxD_data_ready) begin
            //     RxD_data <= data_out;
            // end 
        end
    end

endmodule

`default_nettype wire