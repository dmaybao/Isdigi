<<<<<<< HEAD
module lleno(F_EMPTY_N, F_FULL_N, WRITE, READ, DATA_IN, DATA_OUT, COUNT, clk);

input READ, WRITE, RESET_N, clk;
input [7:0] DATA_IN;

output F_FULL_N, F_EMPTY_N;
output [7:0] DATA_OUT;

=======
module lleno(F_EMPTY_N, F_FULL_N, WRITE, READ, DATA_IN, DATA_OUT, COUNT, clk);

input READ, WRITE, RESET_N, clk;
input [7:0] DATA_IN;

output F_FULL_N, F_EMPTY_N;
output [7:0] DATA_OUT;

>>>>>>> e99947d70da2da51086db8548407630d59b0de8b
endmodule 