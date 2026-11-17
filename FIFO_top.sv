module FIFO_top();

    logic clk;
    
    FIFO_interface FIFO_if(.clk(clk));

    FIFO_testbench FIFO_tb(.fifo_if(FIFO_if.tb));

    FIFO FIFO_DUT(.fifo_if(FIFO_if.DUT));

    FIFO_monitor FIFO_mon(.fifo_if(FIFO_if.monitor));

    initial begin
        clk = 0;
        forever begin
            #1;
            clk = ~clk;
        end    
    end


endmodule