package transaction_pkg;
    import shared_pkg::*;
    parameter FIFO_WIDTH = 16;
    parameter FIFO_DEPTH = 8;
    
    class  FIFO_transaction  ;
        logic clk ;
        rand logic rst_n ;
        rand logic wr_en ;
        rand logic rd_en ;
        rand logic [FIFO_WIDTH-1 : 0] data_in ;
        logic [FIFO_WIDTH-1 : 0] data_out ;
        logic wr_ack,overflow ;
        logic full, empty, almostfull, almostempty, underflow ;

        integer RD_EN_ON_DIST ;
        integer WR_EN_ON_DIST ;

        function new (integer RD_EN_ON = 30 ,integer WR_EN_ON = 70 );
            this.RD_EN_ON_DIST = RD_EN_ON ;
            this.WR_EN_ON_DIST = WR_EN_ON ;
        endfunction

        //Constraint the reset to be deactivated most of the time
        constraint Reset {rst_n dist {1 := 90 , 0 := 10};} ;

        //Constraint the write enable to be high with distribution of the value 
        //WR_EN_ON_DIST and to be low with 100-WR_EN_ON_DIST 
        constraint write {wr_en dist {1 := WR_EN_ON_DIST , 0 := (100-WR_EN_ON_DIST)};} ;

        //Constraint the read enable the same as write enable but using RD_EN_ON_DIST
        constraint read  {rd_en dist {1 := RD_EN_ON_DIST , 0 := (100-RD_EN_ON_DIST)};} ;
        
    endclass
endpackage