`timescale 1ns / 1ps
`default_nettype none

module linear_regr (
                         input wire clk_in,
                         input wire rst_in,
                         input wire [10:0] x_in,
                         input wire [9:0]  y_in,
                         input wire valid_in,
                         input wire tabulate_in,
                         output logic [10:0] a_out, // y = mx + b 
                         output logic [9:0] b_out,
                         output logic valid_out);


  ////////// 
  //
  //  lin reg formulas:
  //        m = [sum(y)*sum (x^2) - sum(x)*sum(xy)] / [n*sum(x^2) - (sum(x))^2 ]
  //        b = [n*sum(xy) - sum(x)*sum(y)] / [n*sum(x^2) - (sum(x))^2]    
  //                         

  //your design here!
  
  localparam RESTING = 0;
  localparam SUMMING = 1;
  localparam DIVIDING = 2; 
  localparam TABULATE = 3; 
  localparam VALID_OUT = 4;
  
  logic [2:0] state; 
  logic [20:0] m_total;
  logic [30:0] x_n; // sum of x's 
  logic [30:0] y_n; // sum of y's 
  logic [60:0] xy_n; // sum of xy's
  logic [60:0] xx_n; // sum of x^2's 
  logic [60:0] a_numerator; // sum of x's 
  logic [60:0] a_denominator; // sum of y's 
  logic [60:0] b_denominator; // sum of xy's
  logic [60:0] b_numerator; // sum of x^2's 
  
  logic [10:0] a_quotient; 
  logic [9:0] b_quotient; 
  logic [2:0] a_remainder; // are these needed? no
  logic [2:0] b_remainder; // are these needed?
  logic a_div_done; 
  logic b_div_done;
  logic a_error;
  logic a_busy;
  logic b_error;
  logic b_busy;
  logic got_b;
  logic got_a;
  
  divider  #(.WIDTH (32)) a_div(.clk_in(clk_in),
			.rst_in(rst_in),
			.dividend_in(a_numerator),
			.divisor_in(a_denominator),
			.data_valid_in(1),
			.quotient_out(a_quotient),
			.remainder_out(a_remainder),
			.data_valid_out(a_div_done),
			.error_out(a_error),
			.busy_out(a_busy)); // x_busy is high when dividing
			
			// busy_out and valid_out both 0 when reset
			
			
  divider #(.WIDTH (32)) b_div(.clk_in(clk_in),
			.rst_in(rst_in),
			.dividend_in(b_numerator),
			.divisor_in(b_denominator),
			.data_valid_in(1),
			.quotient_out(b_quotient),
			.remainder_out(b_remainder),
			.data_valid_out(b_div_done),
			.error_out(b_error),
			.busy_out(b_busy));
  
  always_ff @ (posedge clk_in) begin
  
  	if (rst_in)begin
  		a_out <= 0;
  		b_out <= 0;
  		valid_out <= 0;
  		m_total <= 0;
  		y_n <= 0;
  		x_n <= 0;
        xy_n <= 0;
        xx_n <= 0; 
  		got_b <= 0;
  		got_a <= 0;
        a_numerator <= 0;
        a_denominator <= 0;
        b_numerator <= 0;
        b_denominator <= 0;
  		state <= RESTING; 
  	end else begin
  		
  		// will valid in and tabulate in ever be high at same time? no
  		
  		case (state)
  			RESTING: begin
  				if (valid_in && y_in < 317) begin // if valid in then count up
  					x_n <= x_n + x_in; 
  					y_n <= y_n + y_in;
                    xy_n <= xy_n + x_in*y_in;
                    xx_n <= xx_n + x_n*x_n;  
  					m_total <= m_total + 1; 
  					state <= RESTING; 
  				end else if (tabulate_in) begin
                    a_numerator <= (y_n * xx_n) - (x_n * xy_n);
                    a_denominator <= (m_total*xx_n) - (x_n * x_n);  
                    b_numerator <= (m_total*xy_n) - (x_n*y_n);
                    b_denominator <= (m_total*xx_n) - (x_n*x_n);
  					state <= DIVIDING; 
  				end
  			end
  			
  			DIVIDING: begin
  				// if tabulate in then 
  				// set x_out and y_out and valid_out
  				// go to tabulate state
  				if (m_total ==0) begin
  					state <= RESTING; 
  				end else if (b_div_done && !b_busy &&
  					     a_div_done && !a_busy) begin	
  					state <= TABULATE;
  				end else if (b_div_done && !b_busy) begin
  					got_b <= 1;
  				end else if (a_div_done && !a_busy) begin // outputting too early 
  					got_a <= 1; 
  				end else if (got_a && got_b) begin
  					got_a <= 0;
  					got_b <= 0;	
  					state <= TABULATE;  // indicate valid out for 1 cycle!
  				end else begin
  					state <= DIVIDING; 
  				end
  			end
  			
  			TABULATE: begin
  				if (b_div_done && !b_busy && a_div_done && !a_busy) begin
  					b_out <= b_quotient;
  					a_out <= a_quotient; 
  					valid_out <= 1;
  					state <= VALID_OUT;
  				end else if (b_div_done && !b_busy) begin 
  					b_out <= b_quotient;
  					got_b <= 1;
  					state <= TABULATE;
  				end else if (a_div_done && !a_busy ) begin 
  					a_out <= a_quotient; 
  					got_a <= 1; 
  					state <= TABULATE;
  				end else if (got_a && got_b) begin
  					valid_out <= 1;
  					state <= VALID_OUT;
  				end else begin
  					state <= TABULATE;
  				end
  				
  			end
  			
  			VALID_OUT: begin
  				// reset x_out y_out valid_out and go back to resting
  				a_out <= 0; 
  				b_out <= 0; 
  				valid_out <= 0;
  				y_n <= 0; // reset count
  				x_n <= 0; 
                xx_n <= 0;
                xy_n <= 0;  
  				m_total <= 0; 
  				got_a <= 0;
  				got_b <= 0;
  				state <= RESTING;
  			end
  			
  				
  		endcase 	
  		
  	end
  
  // will need to divide by the total # of pixels
  
  end
  
  

endmodule

`default_nettype wire