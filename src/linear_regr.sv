`timescale 1ns / 1ps
`default_nettype none

module linear_regr (
                         input wire clk_in,
                         input wire rst_in,
                         input wire [10:0] x_in,
                         input wire [9:0]  y_in,
                         input wire valid_in,
                         input wire tabulate_in,
                         output logic signed [17:0] a_out, // the b in y = mx + b 
                         output logic signed [24:0] b_out, // the m in y = mx + b  
						 // a_out and b_out are both SCALED by factor of 10 so that can divide and get fraction later
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
  logic [60:0] yy_n; 

  logic signed [60:0] a_num_signed; 
  logic signed [60:0] b_num_signed; 
  logic signed [60:0] denom_signed; 

  logic signed [60:0] a_num_signed_2; 
  logic signed [60:0] b_num_signed_2; 
  logic signed [60:0] denom_signed_2;
  
  
  logic [17:0] a_quotient; 
  logic [24:0] b_quotient; 
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

  logic [17:0] a_quotient_2; 
  logic [24:0] b_quotient_2; 
  logic a_div_done_2; 
  logic b_div_done_2;
  logic a_error_2;
  logic a_busy_2;
  logic b_error_2;
  logic b_busy_2;
  logic got_b_2;
  logic got_a_2;



  logic divide;
  assign divide = (state == DIVIDING);


  logic a_sign;
  logic b_sign; 
  assign a_sign = a_num_signed[60] ^ denom_signed[60];
  assign b_sign = b_num_signed[60] ^ denom_signed[60];
  logic signed [60:0] a_num_unsigned; 
  logic signed [60:0] b_num_unsigned; 
  logic signed [60:0] denom_unsigned; 

  logic a_sign_2;
  logic b_sign_2; 
  assign a_sign_2 = a_num_signed_2[60] ^ denom_signed_2[60];
  assign b_sign_2 = b_num_signed_2[60] ^ denom_signed_2[60];
  logic signed [60:0] a_num_unsigned_2; 
  logic signed [60:0] b_num_unsigned_2; 
  logic signed [60:0] denom_unsigned_2; 



  ///////////// calculating absolute value ///////////////
  // og version///
  always_comb begin 
	if (a_num_signed < 0) begin
		a_num_unsigned = ~a_num_signed + 1; // making it unsigned 
	end else begin
		a_num_unsigned = a_num_signed;
	end

	if (denom_signed < 0) begin
		denom_unsigned = ~denom_signed + 1; // making it unsigned 
	end else begin
		denom_unsigned = denom_signed;
	end

	if (b_num_signed < 0) begin
		b_num_unsigned = ~b_num_signed + 1; // making it unsigned 
	end else begin
		b_num_unsigned = b_num_signed;
	end
  end

 //// for the reverse version // 
  always_comb begin 
	if (a_num_signed_2 < 0) begin
		a_num_unsigned_2 = ~a_num_signed_2 + 1; // making it unsigned 
	end else begin
		a_num_unsigned_2 = a_num_signed_2;
	end

	if (denom_signed_2 < 0) begin
		denom_unsigned_2 = ~denom_signed_2 + 1; // making it unsigned 
	end else begin
		denom_unsigned_2 = denom_signed_2;
	end

	if (b_num_signed_2 < 0) begin
		b_num_unsigned_2 = ~b_num_signed_2 + 1; // making it unsigned 
	end else begin
		b_num_unsigned_2 = b_num_signed_2;
	end
  end
  //////////////// calculating absolute value ///////////////////////

  ///////////////// linear regression dividers //////////////////
  
  divider  #(.WIDTH (60)) a_div(.clk_in(clk_in),
			.rst_in(rst_in),
			.dividend_in(a_num_unsigned),
			.divisor_in(denom_unsigned),
			.data_valid_in(divide),
			.quotient_out(a_quotient),
			.remainder_out(a_remainder),
			.data_valid_out(a_div_done),
			.error_out(a_error),
			.busy_out(a_busy)); // x_busy is high when dividing
			
			// busy_out and valid_out both 0 when reset
			
			
  divider #(.WIDTH (60)) b_div(.clk_in(clk_in),
			.rst_in(rst_in),
			.dividend_in(b_num_unsigned << 10),
			.divisor_in(denom_unsigned),
			.data_valid_in(divide),
			.quotient_out(b_quotient),
			.remainder_out(b_remainder),
			.data_valid_out(b_div_done),
			.error_out(b_error),
			.busy_out(b_busy));

divider  #(.WIDTH (60)) a_div_2(.clk_in(clk_in),
			.rst_in(rst_in),
			.dividend_in(a_num_unsigned_2 << 3),
			.divisor_in(denom_unsigned_2),
			.data_valid_in(divide),
			.quotient_out(a_quotient_2),
			.remainder_out(a_remainder),
			.data_valid_out(a_div_done_2),
			.error_out(a_error_2),
			.busy_out(a_busy_2)); // x_busy is high when dividing
			
			// busy_out and valid_out both 0 when reset
			
			
  divider #(.WIDTH (60)) b_div_2(.clk_in(clk_in),
			.rst_in(rst_in),
			.dividend_in(b_num_unsigned_2 << 10),
			.divisor_in(denom_unsigned_2),
			.data_valid_in(divide),
			.quotient_out(b_quotient_2),
			.remainder_out(b_remainder),
			.data_valid_out(b_div_done_2),
			.error_out(b_error_2),
			.busy_out(b_busy_2));


///////////////// linear regression dividers //////////////////
  
  always_ff @(posedge clk_in) begin
  
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
        a_num_signed <= 0;
        denom_signed <= 0;
        b_num_signed <= 0;
        denom_signed <= 0;
  		state <= RESTING; 
  	end else begin
  		
  		// will valid in and tabulate in ever be high at same time? no
  		
  		case (state)
  			RESTING: begin
  				if (valid_in ) begin // TODO add if y_in < 317 for real// if valid in then count up 
  					x_n <= x_n + x_in; 
  					y_n <= y_n + y_in;
                    xy_n <= xy_n + x_in*y_in;
                    xx_n <= xx_n + x_in*x_in;  
  					m_total <= m_total + 1; 
  					state <= RESTING; 
  				end else if (tabulate_in) begin
                    a_num_signed <= (y_n * xx_n) - (x_n * xy_n);
                    denom_signed <= (m_total*xx_n) - (x_n * x_n);  
                    b_num_signed <= (m_total*xy_n) - (x_n*y_n);
					
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
					if (a_sign) begin
						a_out <= $signed({1'b0, a_quotient}) * -1;				// quotient should be neg
					end else begin
						a_out <= $signed({1'b0, a_quotient}); // quotient should be positive
					end 

  					if (b_sign) begin
						// b_out <= $signed({1'b1, b_quotient});
						b_out <= $signed({1'b0, b_quotient}) * -1;					// quotient should be neg
					end else begin
						b_out <= $signed({1'b0, b_quotient}); // quotient should be positive
					end 

  					valid_out <= 1;
  					state <= VALID_OUT;
  				end else if (b_div_done && !b_busy) begin 
  					if (b_sign) begin
						// b_out <= $signed({1'b1, b_quotient});
						b_out <= $signed({1'b0, b_quotient}) * -1;					// quotient should be neg
					end else begin
						b_out <= $signed({1'b0, b_quotient}); // quotient should be positive
					end 
  					got_b <= 1;
  					state <= TABULATE;
  				end else if (a_div_done && !a_busy ) begin 
  					if (a_sign) begin
						a_out <= $signed({1'b0, a_quotient}) * -1;				// quotient should be neg
					end else begin
						a_out <= $signed({1'b0, a_quotient}); // quotient should be positive
					end 
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