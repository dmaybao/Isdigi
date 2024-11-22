module Divisor_Algoritmico
#(parameter tamanyo=32)           
(input CLK,
input RSTa,
input Start,
input logic [tamanyo-1:0] Num,
input logic [tamanyo-1:0] Den,

output logic [tamanyo-1:0] Coc,
output logic [tamanyo-1:0] Res,
output logic Done);


logic SignNum,SignDen;
logic [tamanyo-1:0] ACCU,Q,M;
logic [$clog2(tamanyo-1)-1:0] Count;



enum {d0,d1,d2,d3} state;

always_ff @(posedge CLK or negedge RSTa)

begin
	if(!RSTa)
		begin	
			{ACCU,Q,M,SignNum,SignDen} <= 1'b0;
		end
	else 
		begin 
		
		case(state)

		d0: begin
			Done <= 1'b0;
			if(Start) begin
				ACCU <= 0;
				Count <= tamanyo-1;
				SignNum <= Num[tamanyo-1];
				SignDen <= Den[tamanyo-1];
				Q <= Num[tamanyo-1]?(~Num+1):Num;
				M <= Den[tamanyo-1]?(~Den+1):Den;
				state <= d1;
				end
			else
				state <= d0;
		end 
  
		d1: begin
			{ACCU,Q} <= {ACCU[tamanyo-2:0],Q,1'b0};
			state <= d2;
			Done <= 1'b0;
		end 

		d2: begin 
			Done <= 1'b0;
			Count <= Count - 1;
			if(ACCU >= M ) begin
				Q<= Q+1;
				ACCU <= ACCU-M;
				end 
			if(Count==0)
				state <= d3;
			else
				state <= d1;
		end
		
		d3: begin 
			Done <= 1'b1;
			Coc <= (SignNum^SignDen)?(~Q+1):Q;
			Res <= SignNum?(~ACCU+1):ACCU;
			state <= d0;
		end
		
		default: begin 
			state <= d0;
			ACCU <= 0;
			Count <= 0;
			SignNum <= 0;
			SignDen <= 0;
			Q <= 0;
			M <= 0;
		end
				
		endcase
	end
end 

endmodule


