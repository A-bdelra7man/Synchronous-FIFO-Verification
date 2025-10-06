module FIFO #(parameter FIFO_DEPTH = 8,parameter FIFO_WIDTH = 16)(FIFO_if.DUT intf);
	
	localparam max_fifo_addr = $clog2(FIFO_DEPTH);

	reg [FIFO_WIDTH-1:0] mem [FIFO_DEPTH-1:0];
	reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
	reg [max_fifo_addr:0] count;
	
	localparam TWO_EN = 2'b11;
	localparam WR_ONLY = 2'b10;
	localparam RD_ONLY = 2'b01;

	always @(posedge intf.clk or negedge intf.rst_n) begin
		if (!intf.rst_n) begin
			wr_ptr <= 0;
			intf.wr_ack <= 0; // Fix 1: Explicit reset for wr_ack
			intf.overflow <= 0; // Fix 1: Explicit reset for overflow
		end
		else if (intf.wr_en && count < FIFO_DEPTH) begin
			mem[wr_ptr] <= intf.data_in;
			intf.wr_ack <= 1;
			wr_ptr <= (wr_ptr == FIFO_DEPTH-1) ? 0 : wr_ptr + 1;
			intf.overflow <= 0;
		end
		else begin 
			intf.wr_ack <= 0; 
			if (intf.full & intf.wr_en)
				intf.overflow <= 1;
			else
				intf.overflow <= 0;
		end
	end

	always @(posedge intf.clk or negedge intf.rst_n) begin
		if (!intf.rst_n) begin
			rd_ptr <= 0;
			intf.data_out <= 0;
			intf.underflow <= 0;
		end
		else if (intf.rd_en && count != 0) begin
			intf.data_out <= mem[rd_ptr];
			rd_ptr <= (rd_ptr == FIFO_DEPTH-1) ? 0 : rd_ptr + 1;
			intf.underflow <= 0;
		end
		else if (intf.rd_en & intf.empty) begin  
			intf.underflow <= 1;
		end
		else
			intf.underflow <= 0;
	end

	always @(posedge intf.clk or negedge intf.rst_n) begin
		if (!intf.rst_n) begin
			count <= 0;
		end
		else begin
			if	( ({intf.wr_en, intf.rd_en} == WR_ONLY && !intf.full) || 
                  ({intf.wr_en, intf.rd_en} == TWO_EN && intf.empty) ) 
				count <= count + 1;
            
			else if ( ({intf.wr_en, intf.rd_en} == RD_ONLY && !intf.empty) || 
                      ({intf.wr_en, intf.rd_en} == TWO_EN && intf.full) )
				count <= count - 1;
		end
	end

	assign intf.full        = (count == FIFO_DEPTH) ? 1 : 0 ;
	assign intf.empty       = (count == 0) ? 1 : 0 ;
	assign intf.almostfull  = (count == FIFO_DEPTH - 1) ? 1 : 0 ; // Fix 3: Almostfull at DEPTH - 1
	assign intf.almostempty = (count == 1) ? 1 : 0 ;
	
    `ifdef SIM
    // a. Reset Behavior 
    //FIFO_0
    property after_reset;
        @(posedge intf.clk) (!intf.rst_n) |=> ((wr_ptr==0) && (rd_ptr==0) && (count==0));
    endproperty
    assert property(after_reset)
    else $error("Assertion FAILED: Reset did not clear wr_ptr, rd_ptr, and count");

    //FIFO_1
    ////////////////////////////////
    // b. Write Acknowledge
    property write_ack;
        @(posedge intf.clk) disable iff(!intf.rst_n)
            (intf.wr_en && !intf.full) |=> (intf.wr_ack);
    endproperty
    assert property(write_ack)
    else $error("Assertion FAILED: wr_ack not set correctly after write");

    // c. Overflow Detection
    property overflow_detection;
        @(posedge intf.clk) disable iff(!intf.rst_n)
            (intf.wr_en && intf.full) |=> (intf.overflow);
    endproperty
    assert property(overflow_detection)
    else $error("Assertion FAILED: Overflow flag not set correctly when writing to full FIFO");

    // d. Underflow Detection
    property underflow_detection;
        @(posedge intf.clk) disable iff(!intf.rst_n)
            (intf.rd_en && intf.empty) |=> (intf.underflow);
    endproperty
    assert property(underflow_detection)
    else $error("Assertion FAILED: Underflow flag not set correctly when reading from empty FIFO");

    // e. Empty Flag Assertion
    property Empty_Flag_Assertion;
        @(posedge intf.clk) disable iff(!intf.rst_n)
            (count==0) |-> (intf.empty);
    endproperty
    assert property(Empty_Flag_Assertion)
    else $error("Assertion FAILED: empty flag mismatch with count==0");

    // f. Full Flag Assertion
    property Full_Flag_Assertion;
        @(posedge intf.clk) disable iff(!intf.rst_n)
            (count==FIFO_DEPTH) |-> (intf.full);
    endproperty
    assert property(Full_Flag_Assertion)
    else $error("Assertion FAILED: full flag mismatch with count==FIFO_DEPTH");

    // g. Almost Full Condition
    property Almost_Full_Condition;
        @(posedge intf.clk) disable iff(!intf.rst_n)
            (count==FIFO_DEPTH-1) |-> (intf.almostfull);
    endproperty
    assert property(Almost_Full_Condition)
    else $error("Assertion FAILED: almostfull flag mismatch with count==FIFO_DEPTH-2");

    // h. Almost Empty Condition
    property Almost_empty_Condition;
        @(posedge intf.clk) disable iff(!intf.rst_n)
            (count==1) |-> (intf.almostempty);
    endproperty
    assert property(Almost_empty_Condition)
    else $error("Assertion FAILED: almostempty flag mismatch with count==1");

    // i. Write Pointer Wraparound
    property write_pointer_wraparound;
        @(posedge intf.clk) disable iff(!intf.rst_n)
            (wr_ptr==FIFO_DEPTH-1 && intf.wr_en && !intf.full) |=> (wr_ptr==0);
    endproperty
    assert property(write_pointer_wraparound)
    else $error("Assertion FAILED: wr_ptr did not wrap around to 0");

    // j. Read Pointer Wraparound
    property read_pointer_wraparound;
        @(posedge intf.clk) disable iff(!intf.rst_n)
            (rd_ptr==FIFO_DEPTH-1 && intf.rd_en && !intf.empty) |=> (rd_ptr==0);
    endproperty
    assert property(read_pointer_wraparound)
    else $error("Assertion FAILED: rd_ptr did not wrap around to 0");

    // k. Write Pointer Threshold
    property write_pointer_threshold;
        @(posedge intf.clk) wr_ptr inside {[0:FIFO_DEPTH-1]};
    endproperty
    assert property(write_pointer_threshold)
    else $error("Assertion FAILED: wr_ptr exceeded valid FIFO range");

    // l. Read Pointer Threshold
    property read_pointer_threshold;
        @(posedge intf.clk) rd_ptr inside {[0:FIFO_DEPTH-1]};
    endproperty
    assert property(read_pointer_threshold)
    else $error("Assertion FAILED: rd_ptr exceeded valid FIFO range");

    // m. Count Threshold
    property count_threshold;
        @(posedge intf.clk) count inside {[0:FIFO_DEPTH]};
    endproperty
    assert property(count_threshold)
    else $error("Assertion FAILED: count exceeded FIFO_DEPTH");

    // ---- coverage points ----
    cover property(after_reset);
    cover property(write_ack);
    cover property(overflow_detection);
    cover property(underflow_detection);
    cover property(Empty_Flag_Assertion);
    cover property(Full_Flag_Assertion);
    cover property(Almost_Full_Condition);
    cover property(Almost_empty_Condition);
    cover property(write_pointer_wraparound);
    cover property(read_pointer_wraparound);
    cover property(write_pointer_threshold);
    cover property(read_pointer_threshold);
    cover property(count_threshold);
`endif
endmodule