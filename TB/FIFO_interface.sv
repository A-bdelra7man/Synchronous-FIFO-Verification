interface FIFO_if #(parameter FIFO_DEPTH = 8,parameter FIFO_WIDTH = 16)(input logic clk);
    logic [FIFO_WIDTH-1:0] data_in;
    logic  rst_n, wr_en, rd_en;

    // signals driven by the DUT must be var
    var logic [FIFO_WIDTH-1:0] data_out;
    var logic wr_ack, overflow ;
    var logic full, empty, almostfull, almostempty, underflow ;

    // Modports
    modport DUT (
        input  clk, rst_n, wr_en, rd_en, data_in,
        output data_out, wr_ack, overflow, underflow, full, empty, almostfull, almostempty
    );

    modport TB (
        output rst_n, wr_en, rd_en, data_in,
        input  clk, data_out, wr_ack, overflow, underflow, full, empty, almostfull, almostempty
    );

    modport MONITOR (
        input  clk, rst_n, wr_en, rd_en, data_in,
        input data_out, wr_ack, overflow, underflow, full, empty, almostfull, almostempty
    );

endinterface
