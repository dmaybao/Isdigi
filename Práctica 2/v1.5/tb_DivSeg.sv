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

module tb_DivSeg;

// Parámetros
parameter tamanyo = 32;

// Interface
interface DivSecInterface #(parameter tamanyo = 32) (input logic CLK);

    // Señales del DUT
    logic RSTa;
    logic Start;
    logic [tamanyo-1:0] Num; // Numerador
    logic [tamanyo-1:0] Den; // Denominador
    logic [tamanyo-1:0] Coc; // Cociente
    logic [tamanyo-1:0] Res; // Resto
    logic Done;              // Fin

    // Clocking block
    clocking cb @(posedge CLK);
        input RSTa, Start, Num, Den;
        output Coc, Res, Done;
    endclocking

endinterface

// Señales de Testbench
logic CLK;
DivSecInterface #(tamanyo) divsec_if (CLK);

// Clase para generación de datos aleatorios
class Bus;
    rand logic [tamanyo-1:0] Num_value;
    rand logic [tamanyo-1:0] Den_value;

    // Constraints
    constraint NoZero {
        Den_value != 0; // Evita denominadores cero
    }
endclass

Bus bus_inst;

// CoverGroup
covergroup NumDen_CG;
    coverpoint divsec_if.Num {  // Eliminar $signed si no es estrictamente necesario
        bins zero       = {0};
        bins positive   = {[1:(1<<(tamanyo-1))-1]};
        bins negative   = {[-(1<<(tamanyo-1)):-1]};
        bins max_value  = {(1<<(tamanyo-1))-1};
        bins min_value  = {-(1<<(tamanyo-1))};
    }
    coverpoint divsec_if.Den {
        bins positive   = {[1:(1<<(tamanyo-1))-1]};
        bins negative   = {[-(1<<(tamanyo-1)):-1]};
        bins max_value  = {(1<<(tamanyo-1))-1};
        bins min_value  = {-(1<<(tamanyo-1))};
    }
    cross divsec_if.Num, divsec_if.Den;
endgroup

NumDen_CG cg_inst = new();

// Clase de Scoreboard
class Scoreboard;
    logic [tamanyo-1:0] exp_Coc, exp_Res; // Valores esperados
    logic [tamanyo-1:0] dut_Coc, dut_Res; // Valores del DUT

    // Métodos
    function void check_results();
        if ((dut_Coc !== exp_Coc) || (dut_Res !== exp_Res)) begin
            $error("@%0t: Mismatch! Coc DUT=%0d, Exp=%0d | Res DUT=%0d, Exp=%0d",
                   $time, dut_Coc, exp_Coc, dut_Res, exp_Res);
        end else begin
            $display("@%0t: Match! Coc=%0d, Res=%0d", $time, dut_Coc, dut_Res);
        end
    endfunction

endclass

Scoreboard sb;

// Instancia del módulo bajo prueba (DUT)
Divisor_Segmentado #(tamanyo) duv (
    .CLK(divsec_if.CLK),
    .RSTa(divsec_if.RSTa),
    .Start(divsec_if.Start),
    .Num(divsec_if.Num),
    .Den(divsec_if.Den),
    .Coc(divsec_if.Coc),
    .Res(divsec_if.Res),
    .Done(divsec_if.Done)
);

// Generación del reloj
always #5 CLK = ~CLK; // Periodo de 10 unidades de tiempo

// Inicialización y pruebas
initial begin
    // Declaraciones al inicio del bloque
    integer Num_signed, Den_signed;

    // Configuración inicial
    CLK = 0;
    divsec_if.RSTa = 1;
    divsec_if.Start = 0;
    divsec_if.Num = 0;
    divsec_if.Den = 1; // Den inicializado a valor válido
    #10 divsec_if.RSTa = 0; // Liberar reset

    // Crear instancia de la clase de randomización
    bus_inst = new();

    // Crear instancia del Scoreboard
    sb = new();

    // Configuración de dumping para simulación
    $dumpfile("waves.vcd");
    $dumpvars(0, tb_DivSec_lvl3);

    // Ejecución de pruebas aleatorias
    repeat (50) begin
        // Randomizar valores
        assert(bus_inst.randomize()) else $fatal("Error al randomizar valores");

        // Asignar valores aleatorios al DUT
        divsec_if.cb.Num <= bus_inst.Num_value;
        divsec_if.cb.Den <= bus_inst.Den_value;

        // Generar pulso de inicio
        divsec_if.cb.Start <= 1;
        #10 divsec_if.cb.Start <= 0;

        // Esperar a que Done se active
        @(posedge divsec_if.cb.Done);

        // Calcular valores esperados
        Num_signed = $signed(divsec_if.Num);
        Den_signed = $signed(divsec_if.Den);
        sb.exp_Coc = Num_signed / Den_signed;
        sb.exp_Res = Num_signed % Den_signed;

        // Capturar los valores del DUT
        sb.dut_Coc = divsec_if.Coc;
        sb.dut_Res = divsec_if.Res;

        // Verificar resultados en el Scoreboard
        sb.check_results();

        // Muestrear cobertura
        cg_inst.sample();
    end

    // Finalizar simulación
    $display("¡Simulación completada con éxito!");
    $display("Cobertura funcional alcanzada: %0.2f%%", cg_inst.get_coverage());
    #100 $finish;
end

endmodule


