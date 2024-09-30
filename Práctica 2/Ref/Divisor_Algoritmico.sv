module Divisor_Algoritmico
 

#(parameter tamanyo=32)           
(input CLK,
input RSTa,
input Start,
input logic [tamanyo-1:0] Num,
input logic [tamanyo-1:0] Den,

output logic [tamanyo-1:0] Coc,
output logic [tamanyo-1:0] Res,
output logic Done);// equivale al fin de la ASM

logic SignNum,SignDen;
logic [tamanyo-1:0]ACCU,Q,M;
logic [$clog2(tamanyo-1)-1:0]CONT;

//vuestro código
//logic [1:0] Estado;
//localparam D0= 2'b00, D1=2'b01, D2=2'b10, D3=2'b11;
enum {D0,D1,D2,D3} Estado;

always_ff @(posedge CLK or negedge RSTa)
begin
if (!RSTa)
	begin
		{ACCU,Q,M,CONT,SignNum,SignDen}<=1'b0;
		Estado<=D0;
	end
else begin
	
case(Estado)
	D0: begin
		Done<=1'b0;
		if(Start==1'b1)
			begin
				ACCU<=0;
				CONT<=tamanyo-1;
				SignNum<=Num[tamanyo-1];
				SignDen<=Den[tamanyo-1];
				Q<=Num[tamanyo-1]?(~Num+1):Num;
				M<=Den[tamanyo-1]?(~Den+1):Den;
				Estado<=D1;
				//assert property(@(posedge CLK)Den!=0) else $info("Se puede calcular");
			end
		else
			Estado<=D0;
		end
		
	D1:begin
			{ACCU,Q}<={ACCU[tamanyo-2:0],Q,1'b0};
			Estado<=D2;
			Done<=1'b0;
		end
	
	D2:begin
			Done<=1'b0;
			CONT<=CONT-1;
			if(ACCU>=M)
				begin
				Q<=Q+1;
				ACCU<=ACCU-M;
				
				end
				 if (CONT==0)
				Estado<=D3;
			else
				Estado<=D1;
			
		end
	
	D3:begin
			Done<=1'b1;
			Coc<=(SignNum^SignDen)?(~Q+1):Q;
			Res<=SignNum?(~ACCU+1):ACCU;
			Estado<=D0;
		end
		
	default:begin
		Estado<=D0;
		ACCU<=0;
		CONT<=0;
		SignNum<=0;
		SignDen<=0;
		Q<=0;
		M<=0;
		end
endcase
end
end				
		
//fin de vuestro codigo

endmodule
