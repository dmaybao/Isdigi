module FIFO (DATA_IN, READ, WRITE, CLEAR, RESET_N, clk, DATA_OUT, F_FULL_N, F_EMPTY_N, USE_DW);

input READ, WRITE, CLEAR_N, RESET_N, clk;
input [7:0] DATA_IN;

output F_FULL_N, F_EMPTY_N;
output [7:0] DATA_OUT;
output [4:0] USE_DW;






endmodule 