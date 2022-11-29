`timescale 1ns / 1ps
`default_nettype none

module perpendicularize (
                         input wire clk_in,
                         input wire rst_in,
                         input wire [24:0] m_in,  // shifted up by 8 bits 1b.16bits.8bits sign.whole num.decimal
                         input wire [17:0]  b_in,
                         input wire [10:0] x_com,  
                         input wire [9:0]  y_com,
                         input wire valid_in,
                         input wire tabulate_in,
                         output logic signed [24:0] m_out,
                         output logic signed [17:0]  b_out,
                         output logic valid_out);
  
  logic [47:0] dividend;
//   assign dividend = 48'h1000_0000_0000; // will need to shift it down by 47 bits.. but instead shift it by 39 so that we still have 8b decimal
  assign dividend = 1000; 
  // quotient will just be already in 16bits.8bits whole num.decimal form

  logic [10:0] quotient; 
  logic [2:0] remainder; // are these needed? no
  logic [23:0] reciprocal_m; 
  
  logic m_out_sign; 
  logic [23:0] m_unsigned;
  assign m_out_sign = ~m_in[24];
  assign m_unsigned = m_in[23:0];


  logic div_done; 
  logic error;
  logic busy;
  logic got_new_m;
  logic divide;

  logic [1:0] state;
  localparam RESTING = 0;
  localparam DIVIDING = 1; 
  localparam TABULATE = 2; 
  localparam VALID_OUT = 3;
  
  ////////////////// calculates 1/m ///////////////////
  divider  #(.WIDTH (50)) reciprocal_m_division(
            .clk_in(clk_in),
			.rst_in(rst_in),
			.dividend_in(dividend),
			.divisor_in(m_unsigned),
			.data_valid_in(divide),
			.quotient_out(reciprocal_m),
			.remainder_out(remainder),
			.data_valid_out(div_done),
			.error_out(error),
			.busy_out(busy)); // x_busy is high when dividing
			
			// busy_out and valid_out both 0 when reset
			
  /// TODO figure out where to calculate new b 

  always_ff @ (posedge clk_in) begin
  
  	if (rst_in)begin
  		divide <= 0; 
  		state <= RESTING; 
  	end else begin
  		
  		// will valid in and tabulate in ever be high at same time? no
  		
  		case (state)
  			RESTING: begin
  				if (valid_in) begin // if valid in then count up
  					state <= DIVIDING; 
  					divide <= 1;
  				end 
  			end
  			
  			DIVIDING: begin
  				// if tabulate in then 
  				// set x_out and y_out and valid_out
  				// go to tabulate state
  				if (div_done && !busy) begin	
  					state <= TABULATE;

  				end 
  			end
  			
  			TABULATE: begin
  				if (div_done && !busy) begin
  					// set quotients and new slope
                    m_out <= $signed({m_out_sign, reciprocal_m});
                    got_new_m <= 1;

  					
  				end 

                if (got_new_m) begin
                    b_out <= m_out * $signed({1'b0, x_com}) + y_com;
                    valid_out <= 1;
  					state <= VALID_OUT;
                end

  				
  			end
  			
  			VALID_OUT: begin
  				// reset x_out y_out valid_out and go back to resting
  				b_out <= 0; 
  				m_out <= 0; 
  				valid_out <= 0;
  				got_new_m <= 0;
				divide <= 0; 
  				state <= RESTING;
  			end
  			
  				
  		endcase 	
  		
  	end
  
  // will need to divide by the total # of pixels
  
  end
  
  

endmodule

`default_nettype wire