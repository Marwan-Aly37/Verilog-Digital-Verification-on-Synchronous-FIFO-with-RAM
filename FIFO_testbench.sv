import FIFO_scoreboard_dataPackage::*;
import shared_pkg::*;

module FIFO_testbench(FIFO_interface.tb fifo_if);
    
    FIFO_scoreboard fifo_score = new();

    initial begin
        fifo_if.rst_n = 0;
        @(negedge fifo_if.clk);
        fifo_if.rst_n = 1;

        repeat(100000) begin
            assert(fifo_score.fifo_trans.randomize());
            fifo_if.data_in = fifo_score.fifo_trans.data_in;
            fifo_if.rst_n =   fifo_score.fifo_trans.rst_n;
            fifo_if.wr_en =   fifo_score.fifo_trans.wr_en;
            fifo_if.rd_en =   fifo_score.fifo_trans.rd_en;
            @(negedge fifo_if.clk);
        end

        shared_pkg::test_finished = 1'b1;    
    end

endmodule