//-----------------------------------------------------------------------------
// Universitat Politècnica de València   |  2024-2025
// Isdigi           3º Estit
// 
// Date:     25/9/2024
// Names:     Daniel Mayoral Baños
// Module Name:     tb_DivSec_lv1
// Project Name:    tb_DivSec_lv1
// Description:     Módulo de verificación para Dvivisor_Algoritmico de nivel 1
//
// Dependencies:   ..CLK(CLK), .RSTa(RSTa), .Start(Start), .Num(Num), 
//							.Den(Den), .Coc(Coc), .Res(Res), .Done(Done)
//	Parameters: 	  tamanyo = 32
//
// Revision: v 1.3
// Additional Comments:
//-----------------------------------------------------------------------------

`timescale 1ns/100ps

module tb_DivSec_lv1;
   


	// Parámetro de tamaño de los datos
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
    wire Done;               // Señal de finalización
    
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

    // Generación del reloj
    always #5 CLK = ~CLK;  // Periodo de 10 unidades de tiempo (5 unidades high, 5 low)

    // Procedimiento de inicialización y test
    initial begin
        // Inicialización de señales
        CLK = 0;
        RSTa = 0;
        Start = 0;
        Num = 0;
        Den = 0;
        
        // Reset del sistema
        #1 RSTa = 1;  // Activar reset asíncrono
        #1 RSTa = 0;  // Quitar reset
        #1 RSTa = 1;  // Vuelve al estado normal

        // Caso 1: División positiva 100 / 2
        #10 Num = 100; Den = 2; Start = 1;
        #10 Start = 0; // Retirar la señal de inicio después de un ciclo
        wait(Done);    // Espera a que la señal de "Done" se active
        #10;           // Espera un ciclo después de que "Done" esté en alto
        $display("División 100 / 2: Coc = %d, Res = %d", Coc, Res);
        
        // Caso 2: División negativa -100 / 3
        #10 Num = -100; Den = 2; Start = 1;
        #10 Start = 0;
        wait(Done);
        #10;
        $display("División -100 / 2: Coc = %d, Res = %d", Coc, Res);

        // Caso 3: División positiva 45 / -5
        #10 Num = 45; Den = -5; Start = 1;
        #10 Start = 0;
        wait(Done);
        #10;
        $display("División 45 / -5: Coc = %d, Res = %d", Coc, Res);

        // Caso 4: División negativa -45 / -5
        #10 Num = -45; Den = -5; Start = 1;
        #10 Start = 0;
        wait(Done);
        #10;
        $display("División -45 / -5: Coc = %d, Res = %d", Coc, Res);

        // Caso 5: División con residuo 37 / 4
        #10 Num = 37; Den = 4; Start = 1;
        #10 Start = 0;
        wait(Done);
        #10;
        $display("División 37 / 4: Coc = %d, Res = %d", Coc, Res);

        // Fin de la simulación
        #50;
        $finish;
    end
endmodule
