////////////////////////////////////////////////////////////////////////////////
// Author: Kareem Waseem
// Course: Digital Verification using SV & UVM
//
// Description: FIFO Design 
// 
////////////////////////////////////////////////////////////////////////////////
module FIFO(FIFO_interface.DUT fifo_if);
localparam max_fifo_addr = $clog2(fifo_if.FIFO_DEPTH);

reg [fifo_if.FIFO_WIDTH-1:0] mem [fifo_if.FIFO_DEPTH-1:0];

reg [max_fifo_addr-1:0] wr_ptr, rd_ptr;
reg [max_fifo_addr:0] count;
`ifdef SIM
property reset_behaviour;
	@(posedge fifo_if.clk) (!fifo_if.rst_n |-> (!wr_ptr && !rd_ptr && (count == 0)));
endproperty

property write_acknowledge;
	@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n) ((fifo_if.wr_en && !fifo_if.full) |=> fifo_if.wr_ack);
endproperty

property overflow_detection;
	@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n) ((fifo_if.wr_en && fifo_if.full) |=> fifo_if.overflow);
endproperty

property underflow_detection;
	@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n) ((fifo_if.rd_en && fifo_if.empty) |=> fifo_if.underflow);
endproperty

property empty_flag_assertion;
	@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n) ((count == 0) |->fifo_if.empty);
endproperty

property full_flag_assertion;
	@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n) ((count == fifo_if.FIFO_DEPTH) |-> fifo_if.full);
endproperty

property almost_full_condition;
	@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n) ((count == fifo_if.FIFO_DEPTH - 1) |-> fifo_if.almostfull);
endproperty

property almost_empty_condition;
	@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n) ((count == 1) |-> fifo_if.almostempty);
endproperty

property write_pointer_wraparound;
	@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n) ((fifo_if.wr_en && !fifo_if.full && (wr_ptr == fifo_if.FIFO_DEPTH - 1)) |=> (wr_ptr == 0));
endproperty

property read_pointer_wraparound;
	@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n) ((fifo_if.rd_en && !fifo_if.empty && (rd_ptr == fifo_if.FIFO_DEPTH - 1)) |=> (rd_ptr == 0));
endproperty

property pointer_threshold;
	@(posedge fifo_if.clk) disable iff (!fifo_if.rst_n) (((wr_ptr <= fifo_if.FIFO_DEPTH - 1) && (rd_ptr <= fifo_if.FIFO_DEPTH - 1) && (count <= fifo_if.FIFO_DEPTH)));
endproperty

assert property(reset_behaviour);
assert property(write_acknowledge);
assert property(overflow_detection);
assert property(underflow_detection);
assert property(empty_flag_assertion);
assert property(full_flag_assertion);
assert property(almost_full_condition);
assert property(almost_empty_condition);
assert property(write_pointer_wraparound);
assert property(read_pointer_wraparound);
assert property(pointer_threshold);
`endif
always @(posedge fifo_if.clk or negedge fifo_if.rst_n) begin
	if (!fifo_if.rst_n) begin
		wr_ptr <= 0;
	end
	else if (fifo_if.wr_en && count < fifo_if.FIFO_DEPTH) begin
		mem[wr_ptr] <= fifo_if.data_in;
		fifo_if.wr_ack <= 1;
		wr_ptr <= (wr_ptr == fifo_if.FIFO_DEPTH - 1) ? 0 : wr_ptr + 1;
	end
	else begin 
		fifo_if.wr_ack <= 0; 
		if (fifo_if.full && fifo_if.wr_en)
			fifo_if.overflow <= 1;
		else
			fifo_if.overflow <= 0;
	end
end

always @(posedge fifo_if.clk or negedge fifo_if.rst_n) begin
	if (!fifo_if.rst_n) begin
		rd_ptr <= 0;
	end
	else if (fifo_if.rd_en && count != 0) begin
		fifo_if.data_out <= mem[rd_ptr];
		rd_ptr <= (rd_ptr == fifo_if.FIFO_DEPTH - 1) ? 0 : rd_ptr + 1;
	end

	else begin
		if (fifo_if.empty && fifo_if.rd_en) // Underflow flag is supposed to be sequential and not combinational
			fifo_if.underflow <= 1;
		else
			fifo_if.underflow <= 0;
	end
end

always @(posedge fifo_if.clk or negedge fifo_if.rst_n) begin
	if (!fifo_if.rst_n) begin
		count <= 0;
	end
	else begin
		if	( ({fifo_if.wr_en, fifo_if.rd_en} == 2'b10) && !fifo_if.full) 
			count <= count + 1;
		else if ( ({fifo_if.wr_en, fifo_if.rd_en} == 2'b01) && !fifo_if.empty)
			count <= count - 1;
	end
end

assign fifo_if.full = (count == fifo_if.FIFO_DEPTH)? 1 : 0;
assign fifo_if.empty = (count == 0)? 1 : 0;
assign fifo_if.almostfull = (count == fifo_if.FIFO_DEPTH-1)? 1 : 0; // FIFO_DEPTH - 1 not 2 
assign fifo_if.almostempty = (count == 1)? 1 : 0;

endmodule