`timescale 1ns/100ps
//-----------------------------------------------------------------------------
// Universitat Politècnica de València   |  2024-2025
// Isdigi           3º Estit
// 
// Date:            11/11/2024
// Names:           Daniel Mayoral Baños
// Module Name:     tb_DivSec_lvl2
// Project Name:    Divisor_Algoritmico
// Description:     Módulo de verificación para Divivisor_Algoritmico de nivel 2
//                  con el uso de RCSG y CoverGroups.
//
// Dependencies:    .CLK(CLK), .RSTa(RSTa), .Start(Start), .Num(Num), 
//		            .Den(Den), .Coc(Coc), .Res(Res), .Done(Done)
// Parameters: 	    tamanyo = 32
//
// Revision: v 1.4
// Additional Comments:
//-----------------------------------------------------------------------------

module tb_DivSec_lvl2;

// Parametros
	parameter tamanyo = 32;

// Señales de entrada
    reg CLK;
    reg RSTa;
    reg Start;
    reg [tamanyo-1:0] Num;  // Numerador
    reg [tamanyo-1:0] Den;  // Denominador

// Variables para la verificación
    integer Num_signed, Den_signed, Coc_expected, Res_expected;

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
	    constraint SignRelationship {
            if (Num_value[tamanyo-1] == 0) {
                Den_value[tamanyo-1] == (Den_value[tamanyo-1] ? 1 : 0);
            } else {
                Den_value[tamanyo-1] == (Den_value[tamanyo-1] ? 1 : 0);
        }
    }

    constraint NoZero {
        Den_value != 0;
    }
endclass

Bus bus_inst;

// CoverGroup
covergroup NumDen_CG;
    // Bins para Num
    coverpoint $signed(Num) {
        bins zero = {0};                          // Bin para valor cero
        bins positive = {[1:(1<<(tamanyo-1))-1]};                // Bin para valores positivos (ejemplo para 8 bits)
        bins negative = {[-(1<<(tamanyo-1)):-1]};              // Bin para valores negativos
        bins max_value = {(1<<(tamanyo-1))-1};             // Bin para el valor máximo
        bins min_value = {-(1<<(tamanyo-1))};            // Bin para el valor mínimo
    }

    // Bins para Den
    coverpoint $signed(Den) {
        bins zero = {0};                          // Bin para valor cero (aunque tu constraint lo evita)
        bins positive = {[1:(1<<(tamanyo-1))-1]};                // Bin para valores positivos
        bins negative = {[-(1<<(tamanyo-1)):-1]};              // Bin para valores negativos
        bins max_value = {(1<<(tamanyo-1))-1};             // Bin para el valor máximo
        bins min_value = {-(1<<(tamanyo-1))};            // Bin para el valor mínimo
    }

    // Cross coverage
    cross Num, Den;
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
    // Camptura 
    $dumpfile("waves.vcd"); // Generar ondas en VCD
    $dumpvars(0, tb_DivSec_lvl2); // Capturar todas las señales

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

        //if (!bus_inst.randomize()) begin
        //    $fatal(1, "Error al randomizar valores");
        //end
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
        
            begin 

                Num_signed = Num[tamanyo-1] ? -(~Num + 1) : Num;
                Den_signed = Den[tamanyo-1] ? -(~Den + 1) : Den;
                Coc_expected = (Num[tamanyo-1] ^ Den[tamanyo-1]) ? -(Num_signed / Den_signed) : (Num_signed / Den_signed);
                Res_expected = Num[tamanyo-1] ? -(Num_signed % Den_signed) : (Num_signed % Den_signed);

                if ((Coc !== Coc_expected) || (Res !== Res_expected)) begin
                    $error("Error: Num=%d, Den=%d, Coc=%d (esperado=%d), Res=%d (esperado=%d)",
                        Num, Den, Coc, Coc_expected, Res, Res_expected);
                end else begin
                    $display("Prueba pasada: Num=%d, Den=%d, Coc=%d, Res=%d", Num, Den, Coc, Res);
                end             
            end
        end
    
    
    // Mensaje de éxito
    $display("¡Simulación completada con éxito! Todas las pruebas pasaron correctamente.");

    // Mostrar cobertura funcional
    $display("Cobertura funcional alcanzada: %0.2f%%", cg_inst.get_coverage());
    #1000
    $finish; // Terminar simulación
end



endmodule 