
module Divisor_Sementado
#(parameter tamanyo=32) 
(input logic CLK, RSTa,Start,
input logic[tamanyo-1:0]Num,Den,
output logic [tamanyo-1:0]Coc,Res,
output logic Done
);

//Nueva forma de contador
localparam etapas=2*tamanyo+1;

logic [etapas-1:0][tamanyo-1:0]ACCU,Q,M;
logic [etapas-1:0]SignNum,SignDen,Start_aux;


always_ff @(posedge CLK or negedge RSTa)
if(!RSTa)
	begin
		{ACCU,Q,M,SignNum,SignDen,Start_aux}<='0;		
	end
else begin
	      Start_aux[etapas-1]<=Start;
	
			ACCU[etapas-1]<='0;
			Start_aux[etapas-1]<=Start;
			SignNum[etapas-1]<=Num[tamanyo-1];
			SignDen[etapas-1]<=Den[tamanyo-1];
			Q[etapas-1]<=Num[tamanyo-1]?(~Num+1):Num;
			M[etapas-1]<=Den[tamanyo-1]?(~Den+1):Den;
		
		
	for(int i=(etapas-2);i>=0;i=i-1)
		begin
			Start_aux[i]<=Start_aux[i+1];
			M[i] <= M[i+1];
			SignNum[i]<=SignNum[i+1];
			SignDen[i]<=SignDen[i+1];
			if(i%2==1)
			
				{ACCU[i],Q[i]}<={ACCU[1+i][tamanyo-2:0],Q[1+i],1'b0};
			else
				if(ACCU[i+1]>=M[i+1])
				begin
					Q[i]<=Q[i+1]+1;
					ACCU[i]<=ACCU[i+1]-M[i+1];
				end
				else 
				begin
					Q[i] <= Q[i+1];
					ACCU[i]<=ACCU[i+1];
				end
			end
			
		end
		
DenNoZero: assert property (@(posedge CLK) Start ->Den !=0) else $info("Denominador es 0");
assign Done =Start_aux[0];
assign Coc = (SignNum[0]^SignDen[0])? (~Q[0]+1):Q[0];
assign Res = SignNum[0]? (~ACCU[0]+1):ACCU[0];
endmodule
