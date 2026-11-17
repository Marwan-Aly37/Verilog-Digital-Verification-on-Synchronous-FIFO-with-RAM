package FIFO_coverage_dataPackage;
    import FIFO_transaction_dataPackage::*;
    
    class FIFO_coverage;
        FIFO_transaction F_cvg_txn;

        covergroup fifo_cv;
            cross F_cvg_txn.wr_en, F_cvg_txn.rd_en, F_cvg_txn.wr_ack;
            cross F_cvg_txn.wr_en, F_cvg_txn.rd_en, F_cvg_txn.overflow;
            cross F_cvg_txn.wr_en, F_cvg_txn.rd_en, F_cvg_txn.full;
            cross F_cvg_txn.wr_en, F_cvg_txn.rd_en, F_cvg_txn.empty;
            cross F_cvg_txn.wr_en, F_cvg_txn.rd_en, F_cvg_txn.almostfull;
            cross F_cvg_txn.wr_en, F_cvg_txn.rd_en, F_cvg_txn.almostempty;
            cross F_cvg_txn.wr_en, F_cvg_txn.rd_en, F_cvg_txn.underflow;
        endgroup

        function new();
            F_cvg_txn = new();
            fifo_cv = new();
        endfunction

        function void sample_data(FIFO_transaction F_txn);
            F_cvg_txn = F_txn;
            fifo_cv.sample();
        endfunction

    endclass
endpackage