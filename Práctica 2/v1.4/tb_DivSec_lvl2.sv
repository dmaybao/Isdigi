//-----------------------------------------------------------------------------
// Universitat PolitÃ¨cnica de ValÃ¨ncia   |  2024-2025
// Isdigi           3Âº Estit
// 
// Date:     25/9/2024
// Names:     Daniel Mayoral BaÃ±os
// Module Name:     tb_DivSec_lv1
// Project Name:    tb_DivSec_lv1
// Description:     MÃ³dulo de verificaciÃ³n para Dvivisor_Algoritmico de nivel 2
//
// Dependencies:   ..CLK(CLK), .RSTa(RSTa), .Start(Start), .Num(Num), 
//		   .Den(Den), .Coc(Coc), .Res(Res), .Done(Done)
//	Parameters: 	  tamanyo = 32
//
// Revision: v 1.3
// Additional Comments:
//-----------------------------------------------------------------------------

`timescale 1ns/100ps

module tb_DivSec_lvl2;

// Parametros
	parameter tamanyo = 32;

// Señales de entrada
    reg CLK;
    reg RSTa;
    reg Start;
    reg [tamanyo-1:0] Num;  // Numerador
    reg [tamanyo-1:0] Den;  // Denominador

// Señales de salida
    wire [tamanyo-1:0] Coc;  // Cociente
    wire [tamanyo-1:0] Res;  // Resto
    wire Done;               // Fin

// RSCG  
class Bus;
	// Valores
	rand logic [tamanyo-1:0] Num_value;
	rand logic [tamanyo-1:0] Den_value;
	// Limitaciones
	constraint PosPos {Num_value[tamanyo-1]==1'b0 -> Den_value[tamanyo-1]==1'b0;};
    	constraint PosNeg {Num_value[tamanyo-1]==1'b0 -> Den_value[tamanyo-1]==1'b1;};
    	constraint NegPos {Num_value[tamanyo-1]==1'b1 -> Den_value[tamanyo-1]==1'b0;};
    	constraint NegNeg {Num_value[tamanyo-1]==1'b1 -> Den_value[tamanyo-1]==1'b1;};
    	constraint NoZero {Den_value != '0;};
endclass

Bus bus_inst;

// CoverGroup
covergroup NumDen_CG;
    // Bins para Num
    coverpoint Num {
        bins zero = {0};                          // Bin para valor cero
        bins positive = {[1:127]};                // Bin para valores positivos (ejemplo para 8 bits)
        bins negative = {[-128:-1]};              // Bin para valores negativos
        bins max_value = {(1<<(tamanyo-1))-1};             // Bin para el valor máximo
        bins min_value = {-(1<<(tamanyo-1))};            // Bin para el valor mínimo
    }

    // Bins para Den
    coverpoint Den {
        bins zero = {0};                          // Bin para valor cero (aunque tu constraint lo evita)
        bins positive = {[1:127]};                // Bin para valores positivos
        bins negative = {[-128:-1]};              // Bin para valores negativos
        bins max_value = {(1<<(tamanyo-1))-1};             // Bin para el valor máximo
        bins min_value = {-(1<<(tamanyo-1))};            // Bin para el valor mínimo
    }

    // Cross coverage
    cross Num, Den {}
endgroup

NumDen_CG cg_inst = new();

// Instancia del módulo bajo prueba (Divisor_Algoritmico)
    Divisor_Algoritmico #(tamanyo) duv (
        .CLK(CLK),
        .RSTa(RSTa),
        .Start(Start),
        .Num(Num),
        .Den(Den),
        .Coc(Coc),
        .Res(Res),
        .Done(Done)
    );

// Generación del Reloj
    always #5 CLK = ~CLK;  // Periodo de 10 unidades de tiempo (5 unidades high, 5 low)

// Pruebas
initial begin
    CLK = 0;
    RSTa = 1;
    Start = 0;
    Num = 0;
    Den = 0;
    #10 RSTa = 0; // Desactiva reset tras 10 ns

    bus_inst = new(); // Crear instancia

    // Realizar pruebas aleatorias
    repeat (50) begin // Repetir 50 pruebas aleatorias
        // Randomizar valores
        assert(bus_inst.randomize()) else $fatal("Error al randomizar valores");

        // Asignar valores aleatorios al DUT
        Num = bus_inst.Num_value;
        Den = bus_inst.Den_value;

        // Muestrear el covergroup
        cg_inst.sample();

        // Generar pulso de inicio
        Start = 1;
        #10; // Esperar un ciclo
        Start = 0;

        // Esperar a que Done se active
        @(posedge Done);

        // Verificar resultados
        if ((Coc !== Num / Den) || (Res !== Num % Den)) begin
            $error("Error en la división: Num = %d, Den = %d, Coc = %d (esperado %d), Res = %d (esperado %d)",
                   Num, Den, Coc, Num / Den, Res, Num % Den);
        end else begin
            $display("Prueba pasada: Num = %d, Den = %d, Coc = %d, Res = %d",
                     Num, Den, Coc, Res);
        end
    end

    // Mostrar cobertura funcional
    $display("Cobertura funcional alcanzada: %0.2f%%", cg_inst.get_coverage());
    $finish; // Terminar simulación
end


endmodule 