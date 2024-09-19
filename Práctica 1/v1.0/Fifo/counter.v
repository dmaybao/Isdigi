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

module counter(CLK, RSTn, COUNT_UP, COUNT_DOWN, TC, COUNT);

localparam N= $clog2(n);

parameter n = 32;

input CLK, RSTn, COUNT_UP, COUNT_DOWN;
output TC;
output reg[N-1:0] COUNT;


assign TC = (COUNT == n-1) ? 1: 0;

always @(posedge CLK or negedge RSTn)

	if(RSTn!)
		COUNT <= 0;
	
	else 
		COUNT <= COUNT;
	
	
always @(posedge COUNT_UP)
	if (COUNT == n-1)	
		COUNT <= COUNT;
	else
		COUNT <= COUNT + 1;

always @(posedge COUNT_DOWN)
	if (COUNT == n-1)	
		COUNT <= COUNT;
	else
		COUNT <= COUNT - 1;
		

endmodule 
