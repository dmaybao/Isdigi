//TESTBENCH DEL DIVISOR ALGORITMICO

parameter tamanyo=32;

class Bus ;
	rand logic [tamanyo-1:0] valor_Num;
	rand logic [tamanyo-1:0] valor_Den;
	constraint dospositivos {valor_Num[tamanyo-1]==1'b0 -> valor_Den[tamanyo-1]==1'b0;};  //los constraint limitan, es decir para todo valor de positivo_A que sea 0
    constraint positivo_negativo {valor_Num[tamanyo-1]==1'b0 -> valor_Den[tamanyo-1]==1'b1;};  //los constraint limitan, es decir para todo valor de negativo_A que sea 1
    constraint negativo_positivo {valor_Num[tamanyo-1]==1'b1 -> valor_Den[tamanyo-1]==1'b0;};  //los constraint limitan, es decir para todo valor de positivo_B que sea 0
    constraint dosnegativos {valor_Num[tamanyo-1]==1'b1 -> valor_Den[tamanyo-1]==1'b1;};  //los constraint limitan, es decir para todo valor de negativo_B que sea 1
	constraint NoCero {valor_Den!='0;};
endclass


module duv  (test_if.duv bus); //nombre diferente al del archivo ya que todavia no lo estamos instanciando

Divisor_Alg_seg #(.tamanyo(32)) Divisor_Algoritmico_inst
(
	
	.RSTa(bus.RSTa) ,	// input  RSTa_sig
	.Start(bus.Start) ,	// input  Start_sig
	.Num(bus.Num) ,	// input [tamanyo-1:0] Num_sig
	.Den(bus.Den) ,	// input [tamanyo-1:0] Den_sig
	.Coc(bus.Coc) ,	// output [tamanyo-1:0] Coc_sig
	.Res(bus.Res), 	// output [tamanyo-1:0] Res_sig
	.Done(bus.Done),
	.CLK(bus.CLK)
);

endmodule

//event comprobar;

`timescale 1ns/1ps

interface test_if (
   input bit CLK  , 
   input bit  RSTa
   );
   logic  Start;
   logic  Done;
   logic signed [tamanyo-1:0] Num,Den  ;
   logic signed [tamanyo-1:0] Coc,Res;

  clocking md @(posedge CLK);
	input #1ns Coc;
	input #1ns Res;
	input #1ns Num;
	input #1ns Den;
	input #1ns Start;
    input #1ns Done;
   endclocking:md;
	
	clocking sd @(posedge CLK);
    input #2ns  Coc;
	 input #2ns Res;
    output #2ns Num;
	 output #2ns Den;
    input #2ns  Done;
    output #2ns Start; 
  endclocking:sd;



  	modport monitor (clocking md);
    modport test (clocking sd);
    modport duv (
  		input          	CLK,
  		input        	RSTa,
  		output          Done,
  		input         	Start,
  		input  			Num,
		input  			Den,
  		output    		Coc,
		output    		Res
		);

endinterface

class Scoreboard ;
  logic signed[tamanyo-1:0] cola_targetsCoc[$];
  logic signed [tamanyo-1:0] cola_targetsRes[$];
  logic  signed[tamanyo-1:0] targetCoc,pretargetCoc,cociente_obtenido;
  logic signed [tamanyo-1:0] targetRes,pretargetRes,resto_obtenido;
  reg FINAL;
  virtual test_if.monitor mports;
  
   function new (virtual test_if.monitor mpuertos);
   begin
    this.mports = mpuertos;
   end
   endfunction
   
 task monitor_input;
   begin
     while (1)
       begin       
         @(mports.md);
         if (mports.md.Start==1'b1)
           begin
			    pretargetCoc=$signed(mports.md.Num)/$signed(mports.md.Den);//funcion ideal de obtencion del cociente entre en numerador y el denominador
			   
			    cola_targetsCoc={pretargetCoc,cola_targetsCoc};	
				 pretargetRes=$signed(mports.md.Num)%$signed(mports.md.Den);//funcion ideal de obtencion del cociente entre en numerador y el denominador
			   
			     cola_targetsRes={pretargetRes,cola_targetsRes};
                            end
		end
   end
 endtask
 
  task monitor_output;
   begin
     while (1)
       begin       
         @(mports.md);
         if (mports.md.Done==1'b1)
           begin
				 FINAL=mports.md.Done;
				 
			         targetCoc=cola_targetsCoc.pop_back();
				 cociente_obtenido=mports.md.Coc;
				 
				 targetRes=cola_targetsRes.pop_back();
				 resto_obtenido=mports.md.Res;
				
				 assert (cociente_obtenido==targetCoc) else $error("operacion mal realizada: el cociente de la división de %d entre %d es %d y tu diste %d",mports.md.Num,mports.md.Den,targetCoc,cociente_obtenido);
				 assert (resto_obtenido==targetRes) else $error("operacion mal realizada: el resto de la división de %d entre %d es %d y tu diste %d",mports.md.Num,mports.md.Den,targetRes,resto_obtenido);
				 
           end
		end
   end
 endtask

endclass

program estimulos
 (test_if.test testar,
  test_if.monitor monitorizar);
  
//esto nos permitirá utilizar el operador ## para los ciclos de reloj


//Nivel de cobertura funcional
covergroup valores;
	Den_no_Z: coverpoint monitorizar.md.Den{ignore_bins ib ={'0};}    //Comprobar  otros valores
	cp: cross monitorizar.md.Num,Den_no_Z;
endgroup

//declaraciones de objetos
	Bus busInst;
	valores veamos;
	Scoreboard sb; //objeto de la clase scoreboard


	
//INITIAL
initial
begin

	busInst = new;	//creacion de los casos de valores aleatorios
	veamos = new;  //creacion de covergroup
	sb=new(monitorizar);

	 fork
      sb.monitor_input; //lanzo el procedimiento de monitorizacion cambio entrada y calculo del valor target
      sb.monitor_output;//lanzo el procedimiento de monitorizacion cambio salida y comparacion ideal
    join_none	

		
	testar.sd.Start <= 1'b0;
	testar.sd.Num <= 32'd40;
	testar.sd.Den <= 32'd8;
	
	repeat(3) @(testar.sd);
	testar.sd.Start <= 1'b1;
	@(testar.sd);
	testar.sd.Start <= 1'b0;
  @(negedge testar.sd.Done);
	





while(veamos.cp.get_coverage()<15)
	begin
		busInst.dospositivos.constraint_mode(1);
		busInst.positivo_negativo.constraint_mode(0);
		busInst.negativo_positivo.constraint_mode(0);
		busInst.dosnegativos.constraint_mode(0);
		busInst.NoCero.constraint_mode(0);
		$display("Probamos con dos positivos");
		assert (busInst.randomize()) else    $fatal("randomization failed");
		
		testar.sd.Num <= busInst.valor_Num;
		testar.sd.Den <= busInst.valor_Den;	
    	veamos.sample();
			@(testar.sd);
	   testar.sd.Start <= 1'b1;
			@(testar.sd);
		testar.sd.Start <= 1'b0;
		@(negedge testar.sd.Done);
	end
	
while(veamos.cp.get_coverage()<30)
	begin
		busInst.dospositivos.constraint_mode(0);
		busInst.positivo_negativo.constraint_mode(1);
		busInst.negativo_positivo.constraint_mode(0);
		busInst.dosnegativos.constraint_mode(0);
		busInst.NoCero.constraint_mode(0);
		$display("Probamos con un positivo y un negativo");
		assert (busInst.randomize()) else    $fatal("randomization failed");
		
		testar.sd.Num <= busInst.valor_Num;
		testar.sd.Den <= busInst.valor_Den;	
    	veamos.sample();
			@(testar.sd);
	   testar.sd.Start <= 1'b1;
			@(testar.sd);
		testar.sd.Start <= 1'b0;
		@(negedge testar.sd.Done);
	end
	
while(veamos.cp.get_coverage()<45)
	begin
		busInst.dospositivos.constraint_mode(0);
		busInst.positivo_negativo.constraint_mode(0);
		busInst.negativo_positivo.constraint_mode(1);
		busInst.dosnegativos.constraint_mode(0);
		busInst.NoCero.constraint_mode(0);
		$display("Probamos un positivo y un negativo");
		assert (busInst.randomize()) else    $fatal("randomization failed");
		
		testar.sd.Num <= busInst.valor_Num;
		testar.sd.Den <= busInst.valor_Den;	
    	veamos.sample();
			@(testar.sd);
	   testar.sd.Start <= 1'b1;
			@(testar.sd);
		testar.sd.Start <= 1'b0;
		@(negedge testar.sd.Done);
	end
	
while(veamos.cp.get_coverage()<60)
	begin
		busInst.dospositivos.constraint_mode(0);
		busInst.positivo_negativo.constraint_mode(0);
		busInst.negativo_positivo.constraint_mode(0);
		busInst.dosnegativos.constraint_mode(1);
		busInst.NoCero.constraint_mode(0);
		$display("Probamos dos negativos");
		assert (busInst.randomize()) else    $fatal("randomization failed");
		
		testar.sd.Num <= busInst.valor_Num;
		testar.sd.Den <= busInst.valor_Den;	
    	veamos.sample();
			@(testar.sd);
	   testar.sd.Start <= 1'b1;
			@(testar.sd);
		testar.sd.Start <= 1'b0;
		@(negedge testar.sd.Done);
	end
	
while(veamos.cp.get_coverage()<75)
	begin
		busInst.dospositivos.constraint_mode(0);
		busInst.positivo_negativo.constraint_mode(0);
		busInst.negativo_positivo.constraint_mode(0);
		busInst.dosnegativos.constraint_mode(0);
		busInst.NoCero.constraint_mode(1);
		$display("Probamos sin cero");
		assert (busInst.randomize()) else    $fatal("randomization failed");
		
		testar.sd.Num <= busInst.valor_Num;
		testar.sd.Den <= busInst.valor_Den;	
    	veamos.sample();
			@(testar.sd);
	   testar.sd.Start <= 1'b1;
			@(testar.sd);
		testar.sd.Start <= 1'b0;
		@(negedge testar.sd.Done);
	end
	
while(veamos.cp.get_coverage()<100)
	begin
		busInst.dospositivos.constraint_mode(0);
		busInst.positivo_negativo.constraint_mode(0);
		busInst.negativo_positivo.constraint_mode(0);
		busInst.dosnegativos.constraint_mode(0);
		busInst.NoCero.constraint_mode(0);
		$display("TODO RANDOM");
		assert (busInst.randomize()) else    $fatal("randomization failed");
		testar.sd.Num <= busInst.valor_Num;
		testar.sd.Den <= busInst.valor_Den;	
    	veamos.sample();
			@(testar.sd);
	   testar.sd.Start <= 1'b1;
			@(testar.sd);
		testar.sd.Start <= 1'b0;
		@(negedge testar.sd.Done);
	end
	$stop;
end
endprogram

module tb_Divisor();

localparam T = 20;

	//inputs del DUT
	reg CLK;
	reg RSTa;
	
	
//instanciacion del interfaz
 test_if interfaz(.CLK(CLK),.RSTa(RSTa));

//instanciaciÃ³n del disenyo                  
 duv duv (.bus(interfaz));
            
//instanciacion del program  
 estimulos estim1 (.testar(interfaz),.monitorizar(interfaz));  


//CLOCK
always
begin
	CLK = 1'b0;
	#50;
	CLK =  1'b1;
    #50;
end 

// RSTa
initial
begin
  RSTa=1'b1;
  # 1  RSTa=1'b0;
	#99 RSTa = 1'b1;
end 

	  





endmodule

