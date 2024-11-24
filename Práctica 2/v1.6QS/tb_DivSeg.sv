`timescale 1ns/100ps
//-----------------------------------------------------------------------------
// Universitat Politècnica de València   |  2024-2025
// Isdigi           3º Estit
// 
// Date:            20/11/2024
// Names:           Daniel Mayoral Baños
// Module Name:     tb_DivSeg
// Project Name:    Divisor_Segmentado
// Description:     Módulo de verificación para Divisor_Segmentado 
//                  
//
// Dependencies:    .CLK(CLK), .RSTa(RSTa), .Start(Start), .Num(Num), 
//                  .Den(Den), .Coc(Coc), .Res(Res), .Done(Done)
// Parameters:      tamanyo = 32
//
// Revision:        v 1.5
// Additional Comments:
//-----------------------------------------------------------------------------

// Parámetros
    parameter tamanyo = 32;
    parameter numtest = 100;

// Clase para generación de datos aleatorios
class Bus;
    rand logic [tamanyo-1:0] Num_value;
    rand logic [tamanyo-1:0] Den_value;

    // Constraints
    constraint Pos_Pos {                //Dos valores positivos
        Num_value[tamanyo-1]==1'b0 -> Den_value[tamanyo-1]==1'b0;
        };  
    constraint Neg_Neg {                //Dos valores negativos
        Num_value[tamanyo-1]==1'b1 -> Den_value[tamanyo-1]==1'b1;
        };
    constraint Pos_Neg {                //Valor Num positivo, Den negativo
        Num_value[tamanyo-1]==1'b0 -> Den_value[tamanyo-1]==1'b1;
        };  
    constraint Neg_Pos {                //Valor Num negativo, Den positivo
        Num_value[tamanyo-1]==1'b1 -> Den_value[tamanyo-1]==1'b0;
        };
	constraint NoZero {                 // Evita denominadores cero
        Den_value != 0;
        }   
endclass

// Instancia del módulo bajo prueba (DUT)
module duv(DivSecIF.duv bus);

    Divisor_Segmentado #(.tamanyo(32)) dut (
        .CLK(bus.CLK),
        .RSTa(bus.RSTa),
        .Start(bus.Start),
        .Num(bus.Num),
        .Den(bus.Den),
        .Coc(bus.Coc),
        .Res(bus.Res),
        .Done(bus.Done)
    );
endmodule

// Interface
interface DivSecIF(input bit CLK, input bit RSTa);
    logic Start, Done;
    logic signed [tamanyo-1:0] Num, Den, Coc, Res;

    // Monitor
    clocking md @(posedge CLK);
        input #1ns Coc;
        input #1ns Res;
        input #1ns Num;
        input #1ns Den;
        input #1ns Start;
        input #1ns Done;
    endclocking:md

    clocking sd @(posedge CLK);
        input #2ns Coc;  
        input #2ns Res;
        input #2ns Done;
        output #2ns Start; 
        output #2ns Num;
        output #2ns Den;
    endclocking:sd

    // Modports
    modport Monitor (
        clocking md 
    );
    modport test (
        clocking sd    
    );
    modport duv (
        input CLK, RSTa, Start, Num, Den,
        output Coc, Res, Done
    );
endinterface

// Clase de Scoreboard
class Scoreboard;
    // Variables internas
    logic signed [tamanyo-1:0] targetCoc, preTargetCoc, cocienteObtenido;
    logic signed [tamanyo-1:0] targetRes, preTargetRes, restoObtenido;
    logic signed [tamanyo-1:0] colaCocientes[$];
    logic signed [tamanyo-1:0] colaRestos[$];
    reg finalflag;

    // Interfaz virtual para el acceso
    virtual DivSecIF.Monitor mports;

    // Constructor
    function new(virtual DivSecIF.Monitor mp);
        begin
        this.mports = mp;
        end
    endfunction

    // Tarea para monitorear entradas
    task monitor_input;
        begin
            while (1) begin
                @(mports.md); // Esperar cualquier cambio en el clocking block
                if (mports.md.Start==1'b1) begin
                    // Calcular valores ideales de cociente y resto
                    
                    preTargetCoc=$signed(mports.md.Num)/$signed(mports.md.Den);
                    colaCocientes={preTargetCoc,colaCocientes};	

				    preTargetRes=$signed(mports.md.Num)%$signed(mports.md.Den);
			        colaRestos={preTargetRes,colaRestos};
                            
                end
            end
        end
    endtask

    // Tarea para monitorear salidas
    task monitor_output;
        begin
            while (1) begin
                @(mports.md); // Esperar cambios en el clocking block
                if (mports.md.Done==1'b1) begin
                    finalflag = mports.md.Done;

                    // Recuperar valores esperados de las colas
                    targetCoc = colaCocientes.pop_back();
                    targetRes = colaRestos.pop_back();

                    // Leer las salidas reales del DUT
                    cocienteObtenido = mports.md.Coc;
                    restoObtenido = mports.md.Res;

                    // Verificación: Comparar las salidas reales con los valores esperados
                    assert (cocienteObtenido == targetCoc)
                        else $error(
                            "Error en el cociente: Num=%d, Den=%d, Esperado=%d, Obtenido=%d",
                            mports.md.Num, mports.md.Den, targetCoc, cocienteObtenido
                        );

                    assert (restoObtenido == targetRes)
                        else $error(
                            "Error en el resto: Num=%d, Den=%d, Esperado=%d, Obtenido=%d",
                            mports.md.Num, mports.md.Den, targetRes, restoObtenido
                        );
                end
            end
        end
    endtask
endclass

//Programa
program estimulos
 (DivSecIF.test prueba,
  DivSecIF.Monitor monitor);
  
    // CoverGroup
    covergroup NumDen_CG;
        
        Den_no_Z: coverpoint monitor.md.Den{ignore_bins ib ={'0};}

        coverpoint monitor.md.Num {
            bins zero       = {0};
            bins positive   = {[1:(1<<(tamanyo-1))-1]};
            bins negative   = {[-(1<<(tamanyo-1)):-1]};
            bins max_value  = {(1<<(tamanyo-1))-1};
            bins min_value  = {-(1<<(tamanyo-1))};
        }
        coverpoint monitor.md.Den {
            bins positive   = {[1:(1<<(tamanyo-1))-1]};
            bins negative   = {[-(1<<(tamanyo-1)):-1]};
            bins max_value  = {(1<<(tamanyo-1))-1};
            bins min_value  = {-(1<<(tamanyo-1))};
        }
        //NoCero: coverpoint monitor.md.Den {
        //    bins Cero = ignore_bins ib ={'0};
        //}
        cs: cross prueba.sd.Num, prueba.sd.Den;
    endgroup


    // Inicialización y pruebas
    initial begin

        // Instancias y declaraciones de todo

        Bus bus_inst = new();              //Instanciación del RSCG
        NumDen_CG cg_inst = new();               // Instanciación del CoverGroup
        Scoreboard sb = new(monitor);             // Instanciación del Scoreboard

    
        fork
            sb.monitor_input();  // Monitoreo de entradas y cálculo ideal
            sb.monitor_output(); // Verificación de las salidas
        join_none

        prueba.sd.Start <= 1'b0;
	    prueba.sd.Num <= 32'd32;
	    prueba.sd.Den <= 32'd2;
	
	    repeat(3) @(prueba.sd);
	    prueba.sd.Start <= 1'b1;
	    @(prueba.sd);
	    prueba.sd.Start <= 1'b0;
        @(negedge prueba.sd.Done);
	
        // Ciclos de pruebas con cobertura funcional

        //Primera parte: Den + , Num +
        while(cg_inst.cs.get_coverage()<20)
	    begin
		    bus_inst.Pos_Pos.constraint_mode(1);
            bus_inst.Neg_Neg.constraint_mode(0);
		    bus_inst.Pos_Neg.constraint_mode(0);
		    bus_inst.Neg_Pos.constraint_mode(0);
		
		    bus_inst.NoZero.constraint_mode(0);

		    $display("Primera parte: Den + , Num +");
		    assert (bus_inst.randomize()) else $fatal("randomization failed");
		
		    prueba.sd.Den <= bus_inst.Den_value; 
            prueba.sd.Num <= bus_inst.Num_value;	
    	    cg_inst.sample();
			@(prueba.sd);
	        prueba.sd.Start <= 1'b1;
			@(prueba.sd);
		    prueba.sd.Start <= 1'b0;
		    @(negedge prueba.sd.Done);
	    end
	
        // Segunda parte: Den - , Num -
        while(cg_inst.cs.get_coverage()<40)
	    begin
		    bus_inst.Pos_Pos.constraint_mode(0);
            bus_inst.Neg_Neg.constraint_mode(1);
		    bus_inst.Pos_Neg.constraint_mode(0);
		    bus_inst.Neg_Pos.constraint_mode(0);
		
		    bus_inst.NoZero.constraint_mode(0);

		    $display("Segunda parte: Den - , Num -");
		    assert (bus_inst.randomize()) else $fatal("randomization failed");
		
		    prueba.sd.Den <= ##1 bus_inst.Den_value; 
            prueba.sd.Num <= ##1 bus_inst.Num_value;	
    	    cg_inst.sample();
		    @(prueba.sd);
	        prueba.sd.Start <= 1'b1;
			@(prueba.sd);
		    prueba.sd.Start <= 1'b0;
		    @(negedge prueba.sd.Done);
	    end 
	
        // Tercera parte: Den + , Num -
        while(cg_inst.cs.get_coverage()<60)
	    begin
	    	bus_inst.Pos_Pos.constraint_mode(0);
            bus_inst.Neg_Neg.constraint_mode(0);
	    	bus_inst.Pos_Neg.constraint_mode(1);
	    	bus_inst.Neg_Pos.constraint_mode(0);
		
		    bus_inst.NoZero.constraint_mode(0);

		    $display("Tercera parte: Den + , Num -");
		    assert (bus_inst.randomize()) else $fatal("randomization failed");
		
		    prueba.sd.Den <= ##1 bus_inst.Den_value; 
            prueba.sd.Num <= ##1 bus_inst.Num_value;	
    	    cg_inst.sample();
			@(prueba.sd);
	     prueba.sd.Start <= 1'b1;
			@(prueba.sd);
		    prueba.sd.Start <= 1'b0;
		    @(negedge prueba.sd.Done);
	    end
	
        // Cuarta parte: Den - , Num +
        while(cg_inst.cs.get_coverage()<80)
	    begin
	    	bus_inst.Pos_Pos.constraint_mode(0);
            bus_inst.Neg_Neg.constraint_mode(0);
		    bus_inst.Pos_Neg.constraint_mode(0);
		    bus_inst.Neg_Pos.constraint_mode(1);
		
		    bus_inst.NoZero.constraint_mode(0);

		    $display("Cuarta parte: Den - , Num +");
		    assert (bus_inst.randomize()) else $fatal("randomization failed");
		
		    prueba.sd.Den <= ##1 bus_inst.Den_value; 
            prueba.sd.Num <= ##1 bus_inst.Num_value;	
    	    cg_inst.sample();
		    @(prueba.sd);
	        prueba.sd.Start <= 1'b1;
		    @(prueba.sd);
		    prueba.sd.Start <= 1'b0;
		    @(negedge prueba.sd.Done);
	    end
	
        // Quinta parte: no cero
        while(cg_inst.cs.get_coverage()<90)
	    begin
		    bus_inst.Pos_Pos.constraint_mode(0);
            bus_inst.Neg_Neg.constraint_mode(0);
		    bus_inst.Pos_Neg.constraint_mode(0);
		    bus_inst.Neg_Pos.constraint_mode(0);
		
		    bus_inst.NoZero.constraint_mode(1);

		    $display("Quinta parte: no cero");
		    assert (bus_inst.randomize()) else $fatal("randomization failed");
		
		    prueba.sd.Den <= ##1 bus_inst.Den_value; 
            prueba.sd.Num <= ##1 bus_inst.Num_value;
    	    cg_inst.sample();
		    @(prueba.sd);
	        prueba.sd.Start <= 1'b1;
		    @(prueba.sd);
		    prueba.sd.Start <= 1'b0;
		    @(negedge prueba.sd.Done);
	    end
	
        // Sexta parte: Aleatorio
        while(cg_inst.cs.get_coverage()<100)
	    begin
		    bus_inst.Pos_Pos.constraint_mode(0);
            bus_inst.Neg_Neg.constraint_mode(0);
		    bus_inst.Pos_Neg.constraint_mode(0);
		    bus_inst.Neg_Pos.constraint_mode(0);
		
		    bus_inst.NoZero.constraint_mode(0);

		    $display("Sexta parte: Aleatorio");
		    assert (bus_inst.randomize()) else $fatal("randomization failed");

		    prueba.sd.Den <= ##1 bus_inst.Den_value; 
            prueba.sd.Num <= ##1 bus_inst.Num_value;
    	    cg_inst.sample();
		    @(prueba.sd);
	        prueba.sd.Start <= 1'b1;
		    @(prueba.sd);
		    prueba.sd.Start <= 1'b0;
		    @(negedge prueba.sd.Done);
	    end

        // Reporte final
    
        $display("Cobertura funcional completa alcanzada: %0.2f%%", cg_inst.get_coverage());
        $finish; // Terminar simulación
        end
 
    // Cierre forzado para evitar bloquear mi pc
    //    #500000000000 
    //    $display("Tiempo limite alcanzado");
    //    $display("Cobertura funcional alcanzada: %0.2f%%", cg_inst.get_coverage());
    //    $finish; // Terminar simulación
    //    $finish; // Terminar simulación después de 5000000 unidades de tiempo
    //end
endprogram

//Modulo de Test
module tb_DivSeg();

    localparam T = 20;

	//inputs del DUT
	    reg CLK;
	    reg RSTa;

    //instanciacion del interfaz
        DivSecIF interfaz(.CLK(CLK),.RSTa(RSTa));

    //instanciación del disenyo                  
        duv duv (.bus(interfaz));
            
    //instanciacion del program  
        estimulos estimulos_inst(.prueba(interfaz.test), .monitor(interfaz.Monitor));

   
    // Generación del reloj
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
            #1  RSTa=1'b0;
            #99 RSTa = 1'b1;
    end    
endmodule