`timescale 1ns/100ps
//entradas
module tb2_Divisor();
//localparam T=20;
localparam tamanyo=32;
logic CLK,RSTa,Start;
logic signed [tamanyo-1:0]Num,Den,Den_NotCero;
//salidas
logic Done;
logic [tamanyo-1:0]Res,Coc;
logic [tamanyo-1:0]target_coc,target_res;



Divisor_Algoritmico Divisor_Algoritmico_inst
(
	.CLK(CLK) ,	// input  CLK_sig
	.RSTa(RSTa) ,	// input  RSTa_sig
	.Start(Start) ,	// input  Start_sig
	.Num(Num) ,	// input [tamanyo-1:0] Num_sig
	.Den(Den) ,	// input [tamanyo-1:0] Den_sig
	.Coc(Coc) ,	// output [tamanyo-1:0] Coc_sig
	.Res(Res) ,	// output [tamanyo-1:0] Res_sig
	.Done(Done) 	// output  Done_sig
);

class Bus;
	randc logic [tamanyo-1:0] valor_Num;
	randc logic [tamanyo-1:0] valor_Den;
	constraint dospositivos {valor_Num[tamanyo-1]==1'b0->valor_Den[tamanyo-1]==1'b0;}; //valor positivo de Num es 0
	constraint positivo_negativo {valor_Num[tamanyo-1]==1'b0->valor_Den[tamanyo-1]==1'b1;}; //valor negativo de Num es 1
	constraint negativo_positivo {valor_Num[tamanyo-1]==1'b1->valor_Den[tamanyo-1]==1'b0;};//valor positivo de Den es 0
	constraint dosnegativos {valor_Num[tamanyo-1]==1'b1->valor_Den[tamanyo-1]==1'b1;};//valor negativo de Num es 1
	constraint NoCero {valor_Den!='0;};
endclass

event comprobar;


//Nivel de cobertura funcional
covergroup valores;
	cp1: coverpoint Num;
   Den_NotCero: coverpoint Den{ignore_bins Den={'0};}
	cp3:cross cp1,Den_NotCero;
endgroup

// declaracion de objetos
	Bus busInst;
	valores veamos;
	
	assign target_coc=$signed(Num)/$signed(Den); //se está calculando la división de dos señales, Num y Den, después de convertirlas a tipos de datos signados utilizando la función $signed  
	assign target_res=$signed(Num)%$signed(Den); // se está calculando el módulo de dos señales, Num y Den, para asi obtener su resto.
	
always
begin
	CLK=1'b0;
	#50;
	CLK=1'b1;
	#50;
end

initial
begin
  RSTa=1'b1;
  # 1  RSTa=1'b0;
	#99 RSTa = 1'b1;
end 

initial
begin
	busInst=new; //construimos clase de valores random
	veamos=new;// construimos el covergroup
	
	Start<=1'b0;
	Num=32'd64;
	Den=32'd8;
	repeat (3) @(posedge CLK);
	Start <= 1'b1;
	@(posedge CLK);
	Start <= 1'b0;
	@(posedge Done);
	-> comprobar;
	@(negedge Done);
	
	while(veamos.cp3.get_coverage()<15)
	begin
		busInst.dospositivos.constraint_mode(1);
		busInst.positivo_negativo.constraint_mode(0);
		busInst.negativo_positivo.constraint_mode(0);
		busInst.dosnegativos.constraint_mode(0);
		busInst.NoCero.constraint_mode(0);
		$display("Probamos con dos positivos");
		assert (busInst.randomize()) else    $fatal("randomization failed");
		
		Num = busInst.valor_Num;
		Den = busInst.valor_Den;	
    	veamos.sample();
    	@(posedge CLK);
	   Start <= 1'b1;
	   @(posedge CLK);
	   Start <= 1'b0;
	   @(posedge Done);
	   -> comprobar;
	   @(negedge Done);
	end
	
	while(veamos.cp3.get_coverage()<30)
	begin
		busInst.dospositivos.constraint_mode(0);
		busInst.positivo_negativo.constraint_mode(1);
		busInst.negativo_positivo.constraint_mode(0);
		busInst.dosnegativos.constraint_mode(0);
		busInst.NoCero.constraint_mode(0);
		$display("Probamos con un positivo y un negativo");
		assert (busInst.randomize()) else    $fatal("randomization failed");
		
		Num = busInst.valor_Num;
		Den = busInst.valor_Den;
    	veamos.sample();
    	@(posedge CLK);
	   Start <= 1'b1;
	   @(posedge CLK);
	   Start <= 1'b0;
	   @(posedge Done);
	   -> comprobar;
	   @(negedge Done);
	end
	
	while(veamos.cp3.get_coverage()<45)
	begin
		busInst.dospositivos.constraint_mode(0);
		busInst.positivo_negativo.constraint_mode(0);
		busInst.negativo_positivo.constraint_mode(1);
		busInst.dosnegativos.constraint_mode(0);
		busInst.NoCero.constraint_mode(0);
		$display("Probamos un positivo y un negativo");
		assert (busInst.randomize()) else    $fatal("randomization failed");
		
		Num = busInst.valor_Num;
		Den = busInst.valor_Den;	
    	veamos.sample();
    	@(posedge CLK);
	   Start <= 1'b1;
	   @(posedge CLK);
	   Start <= 1'b0;
	   @(posedge Done);
	   -> comprobar;
	   @(negedge Done);
	end
	
	while(veamos.cp3.get_coverage()<60)
	begin
		busInst.dospositivos.constraint_mode(0);
		busInst.positivo_negativo.constraint_mode(0);
		busInst.negativo_positivo.constraint_mode(0);
		busInst.dosnegativos.constraint_mode(1);
		busInst.NoCero.constraint_mode(0);
		$display("Probamos dos negativos");
		assert (busInst.randomize()) else    $fatal("randomization failed");
		
		Num = busInst.valor_Num;
		Den = busInst.valor_Den;
    	veamos.sample();
    	@(posedge CLK);
	   Start <= 1'b1;
	   @(posedge CLK);
	   Start <= 1'b0;
	   @(posedge Done);
	   -> comprobar;
	   @(negedge Done);
	end
	
	while(veamos.cp3.get_coverage()<75)
	begin
		busInst.dospositivos.constraint_mode(0);
		busInst.positivo_negativo.constraint_mode(0);
		busInst.negativo_positivo.constraint_mode(0);
		busInst.dosnegativos.constraint_mode(0);
		busInst.NoCero.constraint_mode(1);
		$display("Probamos sin cero");
		assert (busInst.randomize()) else    $fatal("randomization failed");
		
		Num = busInst.valor_Num;
		Den = busInst.valor_Den;
    	veamos.sample();
    	@(posedge CLK);
	   Start <= 1'b1;
	   @(posedge CLK);
	   Start <= 1'b0;
	   @(posedge Done);
	   -> comprobar;
	   @(negedge Done);
	end
	
	while(veamos.cp3.get_coverage()<100)
	begin
		busInst.dospositivos.constraint_mode(0);
		busInst.positivo_negativo.constraint_mode(0);
		busInst.negativo_positivo.constraint_mode(0);
		busInst.dosnegativos.constraint_mode(0);
		busInst.NoCero.constraint_mode(0);
		$display("TODO RANDOM");
		assert (busInst.randomize()) else    $fatal("randomization failed");
		
		Num = busInst.valor_Num;
		Den = busInst.valor_Den;	
    	veamos.sample();
    	@(posedge CLK);
	   Start <= 1'b1;
	   @(posedge CLK);
	   Start <= 1'b0;
	   @(posedge Done);
	   -> comprobar;
	   @(negedge Done);
	end
	$stop;
end

always @(comprobar)
begin
	@(posedge CLK)
		assert(Coc==target_coc) else $error("operación mal realizada: el cociente de %d entre %d debería de dar %d, NO %d",Num,Den,target_coc,Coc);
		assert(Res==target_res) else $error("operación mal realizada: el resto de %d entre %d debería de dar %d, NO %d",Num,Den,target_res,Res);
end



endmodule
