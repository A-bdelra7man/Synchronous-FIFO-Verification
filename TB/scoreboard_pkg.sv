package scoreboard_pkg;
    import transaction_pkg::*;
    import shared_pkg::*;

    parameter FIFO_WIDTH = 16;
    parameter FIFO_DEPTH = 8;

    int size = 0;

    class  FIFO_scoreboard;
        logic [FIFO_WIDTH-1 : 0] data_out_ref ;

        bit [15:0] ref_mem[$];  //queue for FIFO storage

        function void check_data (input FIFO_transaction txn);
            reference_model(txn);
            if (txn.data_out !== data_out_ref) begin
                $error(" Mismatch! DUT vs REF\n"," data_out: DUT=%0h REF=%0h\n",txn.data_out, data_out_ref);
                error_count++;
            end 
            else begin
                correct_count++;
            end
        endfunction

        function void reference_model (input FIFO_transaction txn);
            size = ref_mem.size();
            // Handle reset
            if (!txn.rst_n) begin
                ref_mem.delete();
                data_out_ref = 0;
                size = 0 ;
            end
            // Handle write only
            else if (txn.wr_en && !txn.rd_en) begin
                if (!(size==8)) begin
                    ref_mem.push_back(txn.data_in);
                end
            end
            // Handle read only
            else if (!txn.wr_en && txn.rd_en) begin
                if (!(size==0)) begin
                    data_out_ref = ref_mem.pop_front();
                end
            end
            // Handle READ && WRITE together 
            else if (txn.wr_en && txn.rd_en) begin
                if (size==0) begin               //write only
                    ref_mem.push_back(txn.data_in);
                end
                else if (size==8) begin //read only
                    data_out_ref = ref_mem.pop_front();
                end
                else begin
                    data_out_ref = ref_mem.pop_front();
                    ref_mem.push_back(txn.data_in);
                end
            end
        endfunction
    endclass
endpackage