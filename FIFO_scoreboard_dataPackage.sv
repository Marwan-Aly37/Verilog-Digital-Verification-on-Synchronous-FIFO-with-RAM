package FIFO_scoreboard_dataPackage;
    import FIFO_transaction_dataPackage::*;
    import shared_pkg::*;

    class FIFO_scoreboard;
        localparam FIFO_WIDTH = 16;
        localparam FIFO_DEPTH = 8;

        FIFO_transaction fifo_trans;

        logic [FIFO_WIDTH-1:0] data_out_ref;
        logic wr_ack_ref, overflow_ref;
        logic full_ref, empty_ref, almostfull_ref, almostempty_ref, underflow_ref;

        localparam max_fifo_addr = $clog2(FIFO_DEPTH);

        logic [FIFO_WIDTH-1:0] mem [FIFO_DEPTH-1:0];

        logic [max_fifo_addr-1:0] wr_ptr, rd_ptr;
        logic [max_fifo_addr:0] count;

        function new();
            fifo_trans = new();
        endfunction

        task check_data(FIFO_transaction fifo_data);
            reference_model(fifo_data);
            if((fifo_data.data_out != data_out_ref)) begin
                shared_pkg::error_count = shared_pkg::error_count + 1;
                $display("ERROR!\nData_out: %0d, Data_out_ref: %0d, WR_ACK: %b, WR_ACK_ref: %b, Overflow: %b, Overflow_ref: %b, Full: %b, Full_ref: %b, Empty: %b, Empty_ref: %b, ALmostFull: %b, AlmostFull_ref: %b, AlmostEmpty: %b, AlmostEmpty_ref: %b, Underflow: %b, Underflow_ref: %b", fifo_data.data_out, data_out_ref, fifo_data.wr_ack, wr_ack_ref, fifo_data.overflow, overflow_ref, fifo_data.full, full_ref, fifo_data.empty, empty_ref, fifo_data.almostfull, almostfull_ref, fifo_data.almostempty, almostempty_ref, fifo_data.underflow, underflow_ref);
            end

            else begin
                shared_pkg::correct_count = shared_pkg::correct_count + 1;
            end
        endtask

        task reference_model(FIFO_transaction fifo_ref);
            if(!fifo_ref.rst_n) begin
                data_out_ref = 0;
                overflow_ref = 0;
                full_ref = 0;
                empty_ref = 0;
                almostfull_ref = 0;
                almostempty_ref = 0;
                underflow_ref = 0;
                wr_ack_ref = 0;
                wr_ptr = 0;
                rd_ptr = 0;
                count = 0;
            end

            else begin
                if(fifo_ref.wr_en && !full_ref) begin
                    mem[wr_ptr] = fifo_ref.data_in;
                    wr_ptr = wr_ptr + 1;
                    count = count + 1;
                    overflow_ref = 1'b0;
                    wr_ack_ref = 1'b1;
                end

                else if(fifo_ref.wr_en && full_ref) begin
                    overflow_ref = 1'b1;
                    wr_ack_ref = 1'b0;
                end

                if(fifo_ref.rd_en && !empty_ref) begin
                    data_out_ref = mem[rd_ptr];
                    rd_ptr = rd_ptr + 1;
                    count = count - 1;
                    underflow_ref = 1'b0;
                end

                else if(fifo_ref.rd_en && empty_ref) begin
                    underflow_ref = 1'b1;
                end

                full_ref = (count >= fifo_ref.FIFO_DEPTH)? 1'b1 : 1'b0;
                empty_ref = (count == 0)? 1'b1 : 1'b0;
                almostfull_ref = (count >= fifo_ref.FIFO_DEPTH - 1)? 1'b1 : 1'b0;
                almostempty_ref = (count == 1)? 1'b1 : 1'b0;
            end
        endtask
    endclass

endpackage