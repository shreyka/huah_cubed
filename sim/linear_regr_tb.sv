`timescale 1ns / 1ps
`default_nettype none

module lin_reg_tb;

    //make logics for inputs and outputs!
    logic clk_in;
    logic rst_in;
    logic [10:0] x_in;
    logic [9:0] y_in;
    logic valid_in;
    logic tabulate_in;
    logic [10:0] a_out;
    logic [9:0] b_out;
    logic valid_out;

    linear_regr uut(.clk_in(clk_in), .rst_in(rst_in),
                         .x_in(x_in),
                         .y_in(y_in),
                         .valid_in(valid_in),
                         .tabulate_in(tabulate_in),
                         .a_out(a_out),
                         .b_out(b_out),
                         .valid_out(valid_out));
    always begin
        #5;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
        clk_in = !clk_in;
    end

    //initial block...this is our test simulation
    initial begin
        $dumpfile("lin_reg.vcd"); //file to store value change dump (vcd)
        $dumpvars(0,lin_reg_tb); //store everything at the current level and below
        $display("Starting Sim"); //print nice message
        clk_in = 0; //initialize clk (super important)
        rst_in = 0; //initialize rst (super important)

        
        $display("Testing tabulate_in w/ no valid pixels");
        x_in = 11'b0;
        y_in = 10'b0;
        valid_in = 0;
        tabulate_in = 0;
        #10  //wait a little bit of time at beginning
        rst_in = 1; //reset system
        #10; //hold high for a few clock cycles
        rst_in=0;
        #10;
        valid_in = 0;
        #100;
        tabulate_in = 1;
        #100;
        tabulate_in = 0;
        #100; 
        tabulate_in = 1;
        #1000;
        tabulate_in = 0;
        #1000; 
        tabulate_in = 1;
        #10000;
        tabulate_in = 0;
        #10000; 
        $display("a_out: %5d | b_out: %5d", a_out, b_out);

	$display("Testing every xy combo of x (0-1024) and y (0-768)");
	x_in = 11'b0;
        y_in = 10'b0;
        valid_in = 0;
        tabulate_in = 0;
        #10  //wait a little bit of time at beginning
        //rst_in = 1; //reset system
        #10; //hold high for a few clock cycles
        rst_in=0;
        #10;
        for (int i = 0; i<1024; i= i+1)begin
        	for (int j = 0; j<768; j = j+1) begin
          		x_in = i;
          		y_in = j;
          		valid_in = 1;
          		#10;
          	end
        end 
        valid_in = 0;
        #100;
        tabulate_in = 1;
        #10000; 
        $display("a_out: %5d | b_out: %5d", a_out, b_out);

	$display("Testing 2 pixels (30,490) and (20,480)");
	x_in = 11'b0;
        y_in = 10'b0;
        valid_in = 0;
        tabulate_in = 0;
        #10  //wait a little bit of time at beginning
        //rst_in = 1; //reset system
        #10; //hold high for a few clock cycles
        rst_in=0;
        #10;
        for (int i = 0; i<1; i= i+1)begin
          x_in = 30;
          y_in = 490;
          valid_in = 1;
          #10;
        end 
        x_in = 20;
        y_in = 480;
        valid_in = 1;
        #10;
        valid_in = 0;
        #100;
        tabulate_in = 1;
        #10000;
        $display("a_out: %5d | b_out: %5d", a_out, b_out); 
	
	
	$display("Testing x 0-999 and y 10");
	x_in = 11'b0;
        y_in = 10'b0;
        valid_in = 0;
        tabulate_in = 0;
        #10  //wait a little bit of time at beginning
        //rst_in = 1; //reset system
        #10; //hold high for a few clock cycles
        rst_in=0;
        #10;
        for (int i = 0; i<1000; i= i+1)begin
          x_in = i;
          y_in = 10;
          valid_in = 1;
          #10;
        end // x should be 499, y should be 10  
        valid_in = 0;
        #100;
        tabulate_in = 1;
        #10000; 
        $display("a_out: %5d | b_out: %5d", a_out, b_out); 

        $display("Testing x and y 0-999");
        x_in = 11'b0;
        y_in = 10'b0;
        valid_in = 0;
        tabulate_in = 0;
        #10  //wait a little bit of time at beginning
        //rst_in = 1; //reset system
        #10; //hold high for a few clock cycles
        rst_in=0;
        #10;
        for (int i = 0; i<1000; i= i+1)begin
          x_in = i;
          y_in = i;
          valid_in = 1;
          #10;
        end // x, y should be 499 yes 
        valid_in = 0;
        #100;
        tabulate_in = 1;
        #10000; 
        $display("a_out: %5d | b_out: %5d", a_out, b_out); 

	$display("OG test case");
	x_in = 11'b0;
        y_in = 10'b0;
        valid_in = 0;
        tabulate_in = 0;
        #10  //wait a little bit of time at beginning
        //rst_in = 1; //reset system
        #10; //hold high for a few clock cycles
        rst_in=0;
        #10;
        for (int i = 0; i<1000; i= i+1)begin // used to be i<1000, making shorter for waveform
          x_in = i;
          y_in = i/2;
          valid_in = 1;
          #10;
        end
        valid_in = 0;
        #100;
        tabulate_in = 1;
        #10000;
	

        $display("Finishing Sim"); //print nice message
        $finish;

    end
endmodule //counter_tb

`default_nettype wire