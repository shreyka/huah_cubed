`timescale 1ns / 1ps
`default_nettype none

module line_test_tb;

    logic clk_in; 
    logic rst_in;
    logic  [10:0] hcount;
    logic  [9:0] vcount;
    logic  mask_cr;
    logic  lin_reg_line;

    logic signed [8:0] slope;
    logic signed [8:0] offset;

    line_test uut( 
    .clk_65mhz(clk_in), 
    .rst_in(rst_in),
    .hcount(hcount),
    .vcount(vcount),
    .mask_cr(mask_cr),
    .lin_reg_line(lin_reg_line));


    always begin
        #5;  //every 5 ns switch...so period of clock is 10 ns...100 MHz clock
        clk_in = !clk_in;
    end

    //initial block...this is our test simulation
    initial begin
        $dumpfile("line_test.vcd"); //file to store value change dump (vcd)
        $dumpvars(0,line_test_tb); //store everything at the current level and below
        $display("Starting Sim"); //print nice message
        clk_in = 0; //initialize clk (super important)
        rst_in = 0; //initialize rst (super important)


        #10;  //wait a little bit of time at beginning
        rst_in = 1; //reset system
        #10; //hold high for a few clock cycles
        rst_in=0;
        #10;
        hcount = 0;
        vcount = 0;
        mask_cr = 0;
        #100;
        slope = 2;
        offset = 1;
        for (int i = 0; i<10; i= i+1)begin
            for (int j = 0; j<10; j = j+1) begin
                hcount = i;
                vcount = j;
                if (vcount == hcount*slope + offset) begin 
                    mask_cr = 1;
                end else begin 
                    mask_cr = 0;
                end 
                #10;
            end

        end

        hcount = 0;
        vcount = 0;
        #100;

        slope = 4;
        offset = 1;

        for (int i = 0; i<100; i= i+1)begin
            for (int j = 0; j<100; j = j+1) begin
                hcount = i;
                vcount = j;
                if ($signed(vcount) == $signed(hcount*slope) + offset) begin 
                    mask_cr = 1;
                end else begin 
                    mask_cr = 0;
                end 
                #10;
            end

        end

        hcount = 0;
        vcount = 0;
        #100;

        
   //////////////  TESTING NEGATIVE SLOPE ////////////////////
  

        slope = -1; //BREAKS IT
        offset = 7;


        for (int i = 0; i<240; i= i+1)begin
            for (int j = 0; j<320; j = j+1) begin
                hcount = i;
                vcount = j;
                if (vcount == offset -hcount) begin 
                    mask_cr = 1;
                end else begin 
                    mask_cr = 0;
                end 

                $display("h: %5d   v: %5d   \nmask: %2d  lr: %2d", hcount, vcount, mask_cr, lin_reg_line);
                #10;
            end

        end

        hcount = 0;
        vcount = 0;
        #100;


        for (int i = 0; i<240; i= i+1)begin
            for (int j = 0; j<320; j = j+1) begin
                hcount = i;
                vcount = j;
                if (vcount == offset -hcount) begin 
                    mask_cr = 1;
                end else begin 
                    mask_cr = 0;
                end 

                $display("h: %5d   v: %5d   \nmask: %2d  lr: %2d", hcount, vcount, mask_cr, lin_reg_line);
                #10;
            end

        end

        hcount = 0;
        vcount = 0;
        #100;

        for (int i = 0; i<240; i= i+1)begin
            for (int j = 0; j<320; j = j+1) begin
                hcount = i;
                vcount = j;
                if (vcount == offset -hcount) begin  
                    mask_cr = 1;
                end else begin 
                    mask_cr = 0;
                end 

                $display("h: %5d   v: %5d   \nmask: %2d  lr: %2d", hcount, vcount, mask_cr, lin_reg_line);
                #10;
            end

        end

        hcount = 0;
        vcount = 0;
        #100;

        for (int i = 0; i<240; i= i+1)begin
            for (int j = 0; j<320; j = j+1) begin
                hcount = i;
                vcount = j;
                if (vcount == offset -hcount) begin 
                    mask_cr = 1;
                end else begin 
                    mask_cr = 0;
                end 

                $display("h: %5d   v: %5d   \nmask: %2d  lr: %2d", hcount, vcount, mask_cr, lin_reg_line);
                #10;
            end

        end

        hcount = 0;
        vcount = 0;
        #100;

        //////////////  TESTING NEGATIVE OFFSET ////////////////////
  
        slope = 4;
        offset = -1;

        for (int r = 0; r < 5; r = r+1)begin
            for (int i = 0; i<10; i= i+1)begin
                for (int j = 0; j<10; j = j+1) begin
                    hcount = i;
                    vcount = j;
                    if (vcount == hcount*slope -1) begin 
                        mask_cr = 1;
                    end else begin 
                        mask_cr = 0;
                    end 
                    #10;
                end

            end


            hcount = 0;
            vcount = 0;
            #100;
        end 

    

        //////////////  TESTING NEGATIVE OFFSET AND NEG SLOPE ////////////////////
  
        slope = -4;
        offset = -1;

        for (int i = 0; i<10; i= i+1)begin
            for (int j = 0; j<10; j = j+1) begin
                hcount = i;
                vcount = j;
                if (vcount == hcount*slope + offset) begin 
                    mask_cr = 1;
                end else begin 
                    mask_cr = 0;
                end 
                #10;
            end

        end

        hcount = 0;
        vcount = 0;
        #100;


        //////////////  TESTING FRACTIONAL SLOPE ////////////////////
  
        slope = 1;
        offset = 4;

        for (int i = 0; i<10; i= i+1)begin
            for (int j = 0; j<10; j = j+1) begin
                hcount = i;
                vcount = j;
                if (vcount == (hcount*slope >> 2) + offset) begin // slope 1/2 
                    mask_cr = 1;
                end else begin 
                    mask_cr = 0;
                end 
                #10;
            end

        end

        hcount = 0;
        vcount = 0;
        #100;

        //////////////  TESTING VERTICAL SLOPE ////////////////////
  
    
        for (int r = 0; r < 5; r = r+1)begin
            for (int i = 0; i<100; i= i+1)begin
                for (int j = 0; j<100; j = j+1) begin
                    hcount = i;
                    vcount = j;
                    if (vcount == 50) begin // slope 1/2 
                        mask_cr = 1;
                    end else begin 
                        mask_cr = 0;
                    end 
                    #10;
                end

            end

            hcount = 0;
            vcount = 0;
            #100;
        end 



        //////////////  TESTING HORIZONTAL LINE SLOPE ////////////////////
  
    
        for (int r = 0; r < 5; r = r+1)begin
            for (int i = 0; i<100; i= i+1)begin
                for (int j = 0; j<100; j = j+1) begin
                    hcount = i;
                    vcount = j;
                    if (hcount == 50) begin // slope 1/2 
                        mask_cr = 1;
                    end else begin 
                        mask_cr = 0;
                    end 
                    #10;
                end

            end

            hcount = 0;
            vcount = 0;
            #100;
        end 


        

        $display("Finishing Sim"); //print nice message
        $finish;

    end


endmodule

`default_nettype wire