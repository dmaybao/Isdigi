//-----------------------------------------------------------------------------
// Universitat Politècnica de València   |  2024-2025
// Isdigi           3º Estit
// 
// Date:     25/9/2024
// Names:     Daniel Mayoral Baños
// Module Name:     FIFO
// Project Name:    FIFO
// Description:     Módulo principal para la union de Datapath y del ControlPath
//
// Dependencies:    Read, Write, Clear_n, RSTn, Clk, [7:0] DATA_IN, 
//							[7:0] DATA_OUT, [4:0] USE_DW
//	Parameters: 	  Depth=32, Width=8
//
// Revision: v 1.3
// Additional Comments:
//-----------------------------------------------------------------------------


module FIFO (
		 input [7:0] DATA_IN,
		 input Read, Write, Clear_n, RSTn, Clk,
		 output F_FULL_N, F_EMPTY_N,
		 output [7:0] DATA_OUT,
		 output [4:0] USE_DW
	);
	
	parameter Depth=32, Width=8;
	localparam Address=$clog2(Depth-1);
		
	wire [Address-1:0] Count;
	wire modo, Enable;
	
	assign USE_DW = Count;
	
	// ControlPath
	FSM fsm_inst(
		 .F_EMPTY_N(F_EMPTY_N), 
		 .F_FULL_N(F_FULL_N), 
		 .WRITE(Write), 
		 .READ(Read),  
		 .Count(Count), 
		 .clk(Clk), 
		 .RSTn(RSTn), 
		 .ENABLE(Enable),
		 .modo(modo)
	);
	// DataPath
	shifter_2d_var shifter_inst(
		 .clock(Clk),
		 .reset(RSTn),
		 .enable(Enable),
		 .modo(modo),
		 .seleccion(Count),
		 .clear(Clear_n),
		 .entrada_serie(DATA_IN),
		 .salida_serie(DATA_OUT)
	);
	//Verificación
	
	`ifdef VERIFICACION
	
	property llenado;
		 @(posedge Clk) not (Write == 1'b1 && F_FULL_N == 1'b0 && Read == 1'b0);
	endproperty
	
	sobrellenado: assert property (llenado) else $error("Estas escribiendo sobre una FIFO llena");
	
	property vaciado;
		 @(posedge Clk) not (Read == 1'b1 && F_EMPTY_N == 1'b0 && Write == 1'b0);
	endproperty
	
	sobrevaciado: assert property (vaciado) else $error("Estas leyendo de una FIFO vacia");
	
	puntero_llenado: assert property (@(posedge Clk) disable iff (RSTn === 1'bx) $onehot(Count)) else $error("Te pillé");
	
	`endif
	
	
endmodule





















