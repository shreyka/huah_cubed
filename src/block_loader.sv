`timescale 1ns / 1ps
`default_nettype none

/*

Given the current time,
pass out up to 12 blocks in order of appearance,
where the first index is the closest block to the
player and so on

*/
module block_loader(
    input wire clk_in,
    input wire rst_in,

    input wire [17:0] curr_time_in,

    output logic [11:0] [11:0] block_x,
    output logic [11:0] [11:0] block_y,
    output logic [11:0] [17:0] block_time,
    output logic [11:0] block_color,
    output logic [11:0] [2:0] block_direction,
    output logic [11:0] [7:0] block_ID,
    output logic [17:0] curr_time_out
    );

    typedef enum {
        UP, RIGHT, DOWN, LEFT, ANY
    } direction;

    typedef enum {
        BLUE, RED
    } block_color_enum;

    // TODO: in the future, this should read from a BRAM. for simplicity, this will only return 3 blocks at preset times
    /*
    -> pretend the song is only 4 seconds long, max_time=400
    -> each block takes one second to get to the player
    -> each block will have 3 frames until it reaches the player at z=0, which occurs at timesteps t (spawn), t+33, t+66, t+99 (player)
    -> block 0
        -> ()
    */

    localparam MAX_BLOCK_SIZE = 256;

    logic [$clog2(MAX_BLOCK_SIZE):0] input_block_line;
    logic [$clog2(MAX_BLOCK_SIZE):0] block_index;
    logic [47:0] loaded_block_data;

    logic [1:0] pending_shift;
    logic fill_first_time;

    xilinx_single_port_ram_read_first #(.RAM_WIDTH(48), .RAM_DEPTH(MAX_BLOCK_SIZE + 1), .INIT_FILE("data/out.mem")) blocks(.addra(input_block_line), .dina(48'b0), .clka(clk_in), .wea(1'b0), .ena(1'b1), .rsta(rst_in), .regcea(1'b1), .douta(loaded_block_data));

    always_ff @(posedge clk_in) begin
        if(rst_in) begin
            input_block_line <= 1;
            pending_shift <= 0;
            fill_first_time <= 1;
            //nothing
        end else begin
            curr_time_out <= curr_time_in;

            if(input_block_line < 12) begin
                input_block_line <= input_block_line + 1;

                // first time populating the array
                block_index <= input_block_line - 2;
            end else begin
                if(block_index == 11) begin
                    block_index <= 0;
                end else begin
                    block_index <= block_index + 1;
                end

                if(pending_shift > 0) begin
                    //remove first block and shift all other down one
                    if(pending_shift == 1) begin
                        for(int i = 0; i < 11; i = i + 1) begin
                            block_x[i] <= block_x[i + 1];
                            block_y[i] <= block_y[i + 1];
                            block_time[i] <= block_time[i + 1];
                            block_color[i] <= block_color[i + 1];
                            block_direction[i] <= block_direction[i + 1];
                            block_ID[i] <= block_ID[i + 1];
                        end
                        block_x[11] <= loaded_block_data[45:34];
                        block_y[11] <= loaded_block_data[33:22];
                        block_time[11] <= loaded_block_data[21:4];
                        block_color[11] <= loaded_block_data[3];
                        block_direction[11] <= loaded_block_data[2:0];
                        block_ID[11] <= block_ID[11] + 1;
                    end
                    pending_shift <= pending_shift - 1;
                end else begin
                    // remove the first block if it's no longer in our timeframe
                    if(curr_time_in > block_time[0] && input_block_line <= MAX_BLOCK_SIZE) begin
                        input_block_line <= input_block_line + 1;
                        pending_shift <= 3;
                    end
                end
            end

            // INITIAL BUFFER LOAD
            if(input_block_line >= 2 && fill_first_time) begin
                block_x[block_index] <= loaded_block_data[45:34];
                block_y[block_index] <= loaded_block_data[33:22];
                block_time[block_index] <= loaded_block_data[21:4];
                block_color[block_index] <= loaded_block_data[3];
                block_direction[block_index] <= loaded_block_data[2:0];
                block_ID[block_index] <= block_index + 1;

                if(block_index == 11) begin
                    fill_first_time <= 0;
                end
            end
        end
    end

endmodule

`default_nettype wire