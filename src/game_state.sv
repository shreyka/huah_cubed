`timescale 1ns / 1ps
`default_nettype none

module game_state(
    input wire clk_in,
    input wire rst_in,

    input wire block_sliced,
    input wire [7:0] block_ID,
    input wire player_hit_by_obstacle,
    input wire block_missed,

    // for SPI to block_positions
    input wire block_position_ready,

    output logic[1:0]   state,
    output logic[3:0]   health_out,
    output logic[11:0]  score_out,
    output logic[2:0]   combo_out,
    output logic[17:0]  curr_time,
    output logic[17:0]  max_time,
    output logic[11:0] [7:0] sliced_blocks
    );

    localparam STATE_MENU = 0;
    localparam STATE_PLAYING = 1;
    localparam STATE_WON = 2;
    localparam STATE_LOST = 3;

    logic [19:0] curr_time_counter;

    logic block_ID_has_been_sliced;

    always_comb begin
        block_ID_has_been_sliced = 0;
        for(int i = 0; i < 12; i = i + 1) begin
            if(sliced_blocks[i] == block_ID) begin
                block_ID_has_been_sliced = 1;
            end
        end
    end

    always_ff @(posedge clk_in) begin
        if (rst_in) begin
            curr_time <= 0;
            curr_time_counter <= 0;

            health_out <= 10;
            score_out <= 0;
            combo_out <= 0;

            sliced_blocks <= 0;
        end else begin
            // every 10 milliseconds, increment curr_time
            // if clk is 65 MHz = 10^-6 seconds
            // 650000 to loop 10 milliseconds
            if(curr_time_counter == 10) begin
                curr_time_counter <= 0;
                curr_time <= curr_time + 1;
            end else begin
                curr_time_counter <= curr_time_counter + 1;
            end

            // increment score
            if (block_sliced && !block_ID_has_been_sliced) begin
                $display("SLICE BLOCK!!! %d", block_ID);
                score_out <= score_out + 1;

                for(int i = 0; i < 11; i = i + 1) begin
                    sliced_blocks[i] <= sliced_blocks[i + 1];
                end
                sliced_blocks[11] <= block_ID;
            end
        end
    end

endmodule

`default_nettype wire