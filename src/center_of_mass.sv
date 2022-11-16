`timescale 1ns / 1ps
`default_nettype none

module center_of_mass (
                         input wire clk_in,
                         input wire rst_in,
                         input wire [10:0] x_in,
                         input wire [9:0]  y_in,
                         input wire valid_in,
                         input wire tabulate_in,
                         output logic [10:0] x_out,
                         output logic [9:0] y_out,
                         output logic valid_out);

  //your design here!

  //assign x_out = 11'b0; //REMOVE ME
  //assign y_out = 10'b0; //REMOVE ME
  //assign valid_out = 1'b0; //REMOVE ME
  
  localparam RESTING = 0;
  localparam SUMMING = 1;
  localparam DIVIDING = 2; 
  localparam TABULATE = 3; 
  localparam VALID_OUT = 4;
  
  logic [2:0] state; 
  logic [20:0] m_total;
  logic [30:0] x_n;
  logic [30:0] y_n;
  logic [10:0] x_quotient; 
  logic [9:0] y_quotient; 
  logic [2:0] x_remainder; // are these needed? no
  logic [2:0] y_remainder; // are these needed?
  logic x_div_done; 
  logic y_div_done;
  logic x_error;
  logic x_busy;
  logic y_error;
  logic y_busy;
  logic got_y;
  logic got_x;
  
  divider  #(.WIDTH (32)) x_div(.clk_in(clk_in),
			.rst_in(rst_in),
			.dividend_in(x_n),
			.divisor_in(m_total),
			.data_valid_in(1),
			.quotient_out(x_quotient),
			.remainder_out(x_remainder),
			.data_valid_out(x_div_done),
			.error_out(x_error),
			.busy_out(x_busy)); // x_busy is high when dividing
			
			// busy_out and valid_out both 0 when reset
			
			
  divider #(.WIDTH (32)) y_div(.clk_in(clk_in),
			.rst_in(rst_in),
			.dividend_in(y_n),
			.divisor_in(m_total),
			.data_valid_in(1),
			.quotient_out(y_quotient),
			.remainder_out(y_remainder),
			.data_valid_out(y_div_done),
			.error_out(y_error),
			.busy_out(y_busy));
  
  always_ff @ (posedge clk_in) begin
  
  	if (rst_in)begin
  		x_out <= 0;
  		y_out <= 0;
  		valid_out <= 0;
  		m_total <= 0;
  		y_n <= 0;
  		x_n <= 0;
  		got_y <= 0;
  		got_x <= 0;
  		state <= RESTING; 
  	end else begin
  		
  		// will valid in and tabulate in ever be high at same time? no
  		
  		case (state)
  			RESTING: begin
  				if (valid_in && y_in < 317) begin // if valid in then count up
  					x_n <= x_n + x_in; 
  					y_n <= y_n + y_in;
  					m_total <= m_total + 1; 
  					state <= RESTING; 
  					//state <= SUMMING; 
  				end else if (tabulate_in) begin
  					state <= DIVIDING; 
  				end
  			end
  			
  			SUMMING: begin
  				x_n <= x_n + x_in;
  				y_n <= y_n + y_in;
  				m_total <= m_total + 1; 
  				state <= RESTING; 
  			end
  			
  			DIVIDING: begin
  				// if tabulate in then 
  				// set x_out and y_out and valid_out
  				// go to tabulate state
  				if (m_total ==0) begin
  					state <= RESTING; 
  				end else if (y_div_done && !y_busy &&
  					     x_div_done && !x_busy) begin	
  					state <= TABULATE;
  				end else if (y_div_done && !y_busy) begin
  					got_y <= 1;
  				end else if (x_div_done && !x_busy) begin // outputting too early 
  					got_x <= 1; 
  				end else if (got_x && got_y) begin
  					got_x <= 0;
  					got_y <= 0;	
  					state <= TABULATE;  // indicate valid out for 1 cycle!
  				end else begin
  					state <= DIVIDING; 
  				end
  			end
  			
  			TABULATE: begin
  				if (y_div_done && !y_busy && x_div_done && !x_busy) begin
  					y_out <= y_quotient;
  					x_out <= x_quotient; 
  					valid_out <= 1;
  					state <= VALID_OUT;
  				end else if (y_div_done && !y_busy) begin 
  					y_out <= y_quotient;
  					got_y <= 1;
  					state <= TABULATE;
  				end else if (x_div_done && !x_busy ) begin 
  					x_out <= x_quotient; 
  					got_x <= 1; 
  					state <= TABULATE;
  				end else if (got_x && got_y) begin
  					valid_out <= 1;
  					state <= VALID_OUT;
  				end else begin
  					state <= TABULATE;
  				end
  				
  			end
  			
  			VALID_OUT: begin
  				// reset x_out y_out valid_out and go back to resting
  				y_out <= 0; 
  				x_out <= 0; 
  				valid_out <= 0;
  				y_n <= 0; // reset count
  				x_n <= 0; 
  				m_total <= 0; 
  				got_y <= 0;
  				got_x <= 0;
  				state <= RESTING;
  			end
  			
  				
  		endcase 	
  		
  	end
  
  // will need to divide by the total # of pixels
  
  end
  
  

endmodule

`default_nettype wire