module FIFO (
    input [7:0] DATA_IN,
    input READ, WRITE, CLEAR_N, RESET_N, CLOCK,
    output F_FULL_N, F_EMPTY_N,
    output [7:0] DATA_OUT,
    output [4:0] USE_DW
);

wire [4:0] COUNT;
wire ECOUNT, UP_DOWN;

// CONTROLPATH
FSM fsm_inst (
    .F_EMPTY_N(F_EMPTY_N), 
    .F_FULL_N(F_FULL_N), 
    .WRITE(WRITE), 
    .READ(READ), 
    .DATA_IN(DATA_IN), 
    .DATA_OUT(DATA_OUT), 
    .COUNT(COUNT), 
    .clk(CLOCK), 
    .RSTn(RESET_N), 
    .ENABLE(ECOUNT), 
    .UP_DOWN(UP_DOWN)
);

// COUNTER
counter counter_inst (
    .CLK(CLOCK),
    .RSTn(RESET_N),
    .ENABLE(ECOUNT),
    .COUNT(COUNT),
    .TC(),
    .UP_DOWN(UP_DOWN)
);

// DATAPATH
shifter_2d_var shifter_inst (
    .clock(CLOCK),
    .reset(RESET_N),
    .enable(ECOUNT),
    .modo(1'b1),
    .seleccion(COUNT),
    .clear(CLEAR_N),
    .entrada_serie(DATA_IN),
    .salida_serie(DATA_OUT)
);

ram_dp ram_inst (
    .data_in(DATA_IN),
    .wren(WRITE),
    .clock(CLOCK),
    .rden(READ),
    .wraddress(COUNT), 
    .rdaddress(COUNT),
    .data_out(DATA_OUT)
);

endmodule
