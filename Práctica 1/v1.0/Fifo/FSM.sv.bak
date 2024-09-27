//-----------------------------------------------------------------------------
// Universtat Politecnica de Valencia   |2024-2025
// Isdigi           3º Estit
// 
// Date:     12/9/2024
// Names:     Dan
// Module Name:     Counter
// Project Name:    FIFO
// Description:     Contador modificado para el control de una memoria FIFO
//
// Dependencies:    CLK, RSTn, ENABLE, UP_DOWN, TC, COUNT
//
// Revision:v 1.0
// Additional Comments:
// - NO ES SINCRONO CON EL RELOJ
//-----------------------------------------------------------------------------
module FSM (F_EMPTY_N, F_FULL_N, WRITE, READ, DATA_IN, DATA_OUT, COUNT, clk, RSTn, ENABLE, UP_DOWN);

localparam N= $clog2(n);

parameter n = 32;

input [N-1:0] COUNT;

input READ, WRITE, RSTn, clk;
input [7:0] DATA_IN;

reg [1:0] IN = {READ, WRITE};

output F_FULL_N, F_EMPTY_N, count_up, count_down;
output [7:0] DATA_OUT;

wire [1:0] state, next_state;
wire [7:0] SHIFT;

wire s0 = 2'b00;		// Vacio
wire s1 = 2'b01;		// Otros
wire s2 = 2'b10;		// Lleno
wire s3 = 2'b11;		// Error, no deberia acceder a este estado.
 

always @(posedge clk or negedge RSTn)
if (!rst)
	state <= s0;
else 
	state <= next_state;
	
always @(state or READ or WRITE)
case (state)
	s0: 					// Vacio
		    
				if (IN == 2'b10)
					ENABLE = 1'b1;
					UP_DOWN = 1'b1;
					next_state <= S1;
				else
					next_state <= s0;
			
	s1:					// Otros
			 
				case (IN)
				s0: 
					next_case <= s1;
				s1:
					if (COUNT == 1)
						next_case <= s0;
						ENABLE = 1'b1;
					   UP_DOWN = 1'b0;
					else 
						next_case <= s1;
				s2:
					if (COUNT == 31)
						next_case <= s2;
						count_up <= 1'b1;
						ENABLE = 1'b1;
					   UP_DOWN = 1'b1;
					else 
						next_case <= s3;
						ENABLE = 1'b1;
					   UP_DOWN = 1'b1;
				s3:
					next_state <= s1;
					
				endcase
			
	s2:					// Lleno
			 
				if (IN==2'b10)
					next_state <= s1;
					count_down <= 1'b1;
				else 
					next_state <= s2;
									
			 
	s3:	next_state = s0;
	
	default: next_state = s0;
endcase

always @(state or READ or WRITE)

case(state)
	s0: begin F_EMPTY_N<=0; F_FULL_N<=1; end
	s1: begin F_EMPTY_N<=1; F_FULL_N<=1; end
	s2: begin F_EMPTY_N<=1; F_FULL_N<=0; end
	s3: begin F_EMPTY_N<=0; F_FULL_N<=0; end
 
	default: begin F_EMPTY_N<=0; F_FULL_N<=0; end
	
endcase
		
endmodule 