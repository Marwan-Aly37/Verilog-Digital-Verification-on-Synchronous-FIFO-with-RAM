import FIFO_transaction_dataPackage::*;
import FIFO_scoreboard_dataPackage::*;
import FIFO_coverage_dataPackage::*;
import shared_pkg::*;

module FIFO_monitor(FIFO_interface.monitor fifo_if);

    FIFO_transaction fifo_trans = new();
    FIFO_scoreboard  fifo_score = new();
    FIFO_coverage    fifo_cover = new();

    initial begin
        forever begin
            @(negedge fifo_if.clk);
            fifo_trans.data_in       = fifo_if.data_in;
            fifo_trans.rst_n         = fifo_if.rst_n;
            fifo_trans.wr_en         = fifo_if.wr_en;
            fifo_trans.rd_en         = fifo_if.rd_en;
            fifo_trans.wr_ack        = fifo_if.wr_ack;
            fifo_trans.overflow      = fifo_if.overflow;
            fifo_trans.full          = fifo_if.full;
            fifo_trans.empty         = fifo_if.empty;
            fifo_trans.almostfull    = fifo_if.almostfull;
            fifo_trans.almostempty   = fifo_if.almostempty;
            fifo_trans.underflow     = fifo_if.underflow;

            fork
                begin
                    fifo_cover.sample_data(fifo_trans);
                end

                begin
                    fifo_score.check_data(fifo_trans);    
                end
            join

            if(shared_pkg::test_finished) begin
                $display("Correct_Count: %0d, Error_Count: %0d", shared_pkg::correct_count, shared_pkg::error_count);
                $stop;
            end
        end
    end


endmodule