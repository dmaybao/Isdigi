module counter(CLK, RSTn, ENABLE, UP_DOWN, TC, COUNT);

localparam N= $clog2(n);

parameter n = 32;

input CLK, ENABLE, RSTn, UP_DOWN;
output TC;
output reg[N-1:0] COUNT;


assign TC = (COUNT == n-1) ? 1: 0;

always @(posedge CLK or negedge RSTn)

if(RSTn!)
	COUNT <= 0;
	
else 

if (ENABLE)

	if (UP_DOWN)
		if(TC)
			COUNT <= 31;
		else 
			COUNT <= COUNT-1;
			
	else 
		if(TC)
			COUNT <= 0;
		else 
			COUNT <= COUNT+1;

endmodule 