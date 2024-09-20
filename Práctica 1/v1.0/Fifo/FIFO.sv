module FIFO (DATA_IN, READ, WRITE, CLEAR_N, RESET_N, CLOCK, DATA_OUT, F_FULL_N, F_EMPTY_N, USE_DW);

input [7:0] DATA_IN;
input READ, WRITE, CLEAR_N, RESET_N, CLOCK;

output F_FULL_N, F_EMPTY_N;
input [7:0] DATA_OUT;
input [4:0] USE_DW;


wire [4:0] COUNT;
wire ECOUNT,UP_DOWN;

//CONTROLPATH
.FSM FSM(
	.F_EMPTY_N(F_EMPTY_N), 
	.F_FULL_N(F_FULL_N), 
	.WRITE(WRITE), 
	.READ(READ), 
	.DATA_IN(), 
	.DATA_OUT(), 
	.COUNT(COUNT), 
	.clk(CLOCK), 
	.RSTn(RESET_N), 
	.ENABLE(ECOUNT), 
	.UP_DOWN(UP_DOWN)
	);


.counter counter( //CLK, RSTn, ENABLE, COUNT, TC, UP_DOWN
	.CLK(CLOCK),
	.RSTn(RESET_N),
	.ENABLE(ECOUNT),
	.COUNT(COUNT),
	.TC(),
	.UP_DOWN(UP_DOWN)
	);

//DATAPATH

.shifter_2d_var shifter_2d_var(
		.clock(CLOCK),
		.reset(RESET_N),
		.enable(),
		.modo(1'b1),
		.seleccion(COUNT),
		.clear(CLEAR_N),
		.entrada_serie(),
		.salida_serie()
		);
		
		
endmodule
