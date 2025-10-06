package coverage_pkg;
    import transaction_pkg::*;
    parameter FIFO_WIDTH = 16;
    parameter FIFO_DEPTH = 8;
    
    class FIFO_coverage;
        FIFO_transaction F_cvg_txn = new();

        covergroup FIFO_cg;
            option.per_instance = 1;

            // simple coverpoints for wr_en / rd_en
            cp_wr : coverpoint F_cvg_txn.wr_en {
                bins write_0 = {0};
                bins write_1 = {1};
            }
            cp_rd : coverpoint F_cvg_txn.rd_en {
                bins read_0 = {0};
                bins read_1 = {1};
            }

            // status / event coverpoints
            cp_full : coverpoint F_cvg_txn.full {
                bins full_0 = {0};
                bins full_1 = {1};
            }

            cp_almostfull : coverpoint F_cvg_txn.almostfull {
                bins almostfull_0 = {0};
                bins almostfull_1 = {1};
            }

            cp_empty : coverpoint F_cvg_txn.empty {
                bins empty_0 = {0};
                bins empty_1 = {1};
            }

            cp_almostempty : coverpoint F_cvg_txn.almostempty {
                bins almostempty_0 = {0};
                bins almostempty_1 = {1};
            }

            // event-like coverpoints (these we will protect with ignore_bins)
            cp_overflow : coverpoint F_cvg_txn.overflow {
                bins overflow_0 = {0};
                bins overflow_1 = {1};
            }

            cp_underflow : coverpoint F_cvg_txn.underflow {
                bins underflow_0 = {0};
                bins underflow_1 = {1};
            }

            cp_wr_ack : coverpoint F_cvg_txn.wr_ack {
                bins wr_ack_0 = {0};
                bins wr_ack_1 = {1};
            }

            // ---------- crosses --------
            cross_almostfull : cross cp_wr, cp_rd, cp_almostfull;
            cross_almostempty : cross cp_wr, cp_rd, cp_almostempty;
            cross_empty : cross cp_wr, cp_rd, cp_empty;
            // full: ignore cases where full==1 but wr_en=={0,1} ,rd_en==1
            cross_full : cross cp_wr, cp_rd, cp_full {
                //full flag can not be high after reading data 
                ignore_bins case1_full = binsof(cp_full.full_1) && binsof(cp_rd.read_1)&& binsof(cp_wr.write_0);
                ignore_bins case2_full = binsof(cp_full.full_1) && binsof(cp_rd.read_1)&& binsof(cp_wr.write_1);
            }
            // overflow: ignore cases where overflow==1 but wr_en==0 ,rd_en=={0,1}
            cross_overflow : cross cp_wr, cp_rd, cp_overflow {
                //overflow flag can not be high without writing new data in memory 
                ignore_bins case1_overflow = binsof(cp_overflow.overflow_1) && binsof(cp_rd.read_0)&& binsof(cp_wr.write_0);
                ignore_bins case2_overflow = binsof(cp_overflow.overflow_1) && binsof(cp_rd.read_1)&& binsof(cp_wr.write_0);
            }
            // underflow: ignore cases where underflow==1 but wr_en=={0,1} ,rd_en==0
            cross_underflow : cross cp_wr, cp_rd, cp_underflow {
                //underflow flow flag can not be high without reading data from memory
                ignore_bins case1_underflow = binsof(cp_underflow.underflow_1) && binsof(cp_rd.read_0)&& binsof(cp_wr.write_0);
                ignore_bins case2_underflow = binsof(cp_underflow.underflow_1) && binsof(cp_rd.read_0)&& binsof(cp_wr.write_1);
            }
            // wr_ack: ignore cases where wr_ack==1 but wr_en==0 ,rd_en=={0,1}
            cross_wr_ack : cross cp_wr, cp_rd, cp_wr_ack {
                //wr_ack flag can not be high without writing new data in memory 
                ignore_bins case1_wr_ack = binsof(cp_wr_ack.wr_ack_1) && binsof(cp_rd.read_0)&& binsof(cp_wr.write_0);
                ignore_bins case2_wr_ack = binsof(cp_wr_ack.wr_ack_1) && binsof(cp_rd.read_1)&& binsof(cp_wr.write_0);
            }
        endgroup

        // constructor
        function new();
            FIFO_cg = new();
        endfunction

        function void sample_data(FIFO_transaction F_txn);
            F_cvg_txn = F_txn;
            FIFO_cg.sample();
        endfunction
    endclass
endpackage
