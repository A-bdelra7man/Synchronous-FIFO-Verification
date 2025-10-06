import transaction_pkg::*;
import coverage_pkg::*;
import scoreboard_pkg::*;
import shared_pkg::*;
module monitor #(parameter FIFO_DEPTH = 8,parameter FIFO_WIDTH = 16)(FIFO_if.MONITOR intf);
    
    FIFO_transaction trans = new();
    FIFO_coverage    cov = new();
    FIFO_scoreboard  score = new();

    initial begin
        forever begin
            wait(sample_event.triggered);
            @(negedge intf.clk)

            //assign interface data variables  to the data variables of the trans
            trans.data_in     = intf.data_in;
            trans.clk         = intf.clk;
            trans.rst_n       = intf.rst_n;
            trans.wr_en       = intf.wr_en;
            trans.rd_en       = intf.rd_en;
            trans.data_out    = intf.data_out;
            trans.wr_ack      = intf.wr_ack;
            trans.overflow    = intf.overflow;
            trans.underflow   = intf.underflow;
            trans.full        = intf.full;
            trans.empty       = intf.empty;
            trans.almostfull  = intf.almostfull;
            trans.almostempty = intf.almostempty;

            fork
            begin
                cov.sample_data(trans);
            end
            begin
                score.check_data(trans);
            end
            join

            if (test_finished) begin
            $display("Simulation finished..... Correct_counts = %0d, Errors_counts = %d", correct_count, error_count);
            $stop;
            end
        end
    end
endmodule
