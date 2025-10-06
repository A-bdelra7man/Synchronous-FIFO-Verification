import transaction_pkg::*; 
import shared_pkg::*;
module FIFO_tb (FIFO_if.TB intf);

    FIFO_transaction a = new(); 
    
    initial begin
        // start with reset high, set safe defaults
        //FIFO_0
        intf.rst_n     = 1;
        intf.wr_en     = 0;
        intf.rd_en     = 0;
        intf.data_in   = 0;

        // settle for a couple clocks
        repeat (2) @(negedge intf.clk); 

        // apply a clean async reset pulse
        intf.rst_n = 0;
        @(negedge intf.clk);
        intf.rst_n = 1;
        @(negedge intf.clk);

        //FIFO_1
        repeat(1000) begin
            assert (a.randomize()) else $fatal("randomize failed");
            @(negedge intf.clk);
            // Drive interface from randomized transaction
            intf.rst_n     = a.rst_n;
            intf.wr_en     = a.wr_en;
            intf.rd_en     = a.rd_en;
            intf.data_in   = a.data_in;
            
            -> sample_event; 
        end

        // Assert test_finished to stop monitor 
        test_finished = 1;
    end
endmodule