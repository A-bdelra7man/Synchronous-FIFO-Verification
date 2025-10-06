module top();
    parameter FIFO_WIDTH = 16;
    parameter FIFO_DEPTH = 8;

    logic clk;

    // clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // interface instance (driven by top clock)
    FIFO_if #(FIFO_DEPTH,FIFO_WIDTH) intf (clk);

    // DUT (accepts interface modport)
    FIFO #(FIFO_DEPTH,FIFO_WIDTH) dut (intf.DUT);

    // instantiate TB to drive the interface (use TB modport)
    FIFO_tb tb_inst (intf.TB);
    
    // instantiate MONITOR 
    monitor monitor_inst (intf.MONITOR);

    // checking the functionality of the asynchronous reset
    always_comb begin
        if (!intf.rst_n) begin
            async_reset_assertion: assert final(
                !intf.data_out  && !intf.full        && !intf.almostfull && !intf.underflow &&
                intf.empty      && !intf.almostempty && !intf.overflow   && !intf.wr_ack);
            async_reset_cover: cover final(!intf.data_out && !intf.full && !intf.almostfull && intf.empty && !intf.almostempty && !intf.overflow && !intf.underflow && !intf.wr_ack);
        end
    end

endmodule
