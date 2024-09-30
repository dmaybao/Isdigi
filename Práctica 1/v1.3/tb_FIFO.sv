//-----------------------------------------------------------------------------
// Universitat Politecnica de Valencia   |  2024-2025
// Isdigi           3º Estit
// 
// Date:     25/9/2024
// Names:     Daniel Mayoral BaÃ±os
// Module Name:     tb_FIFO
// Project Name:    FIFO
// Description:     Modulo principal para la verificación
//
// Dependencies:    
//	Parameters: 	  Depth=32, Width=8
//
// Revision: v 1.3
// Additional Comments:
//-----------------------------------------------------------------------------
module tb_FIFO;

  // Declaración de señales
  reg [7:0] DATA_IN;
  reg Read, Write, Clear_n, RSTn, Clk;
  wire F_FULL_N, F_EMPTY_N;
  wire [7:0] DATA_OUT;
  wire [4:0] USE_DW;

  // Instancia del módulo FIFO
  FIFO duv (
    .DATA_IN(DATA_IN),
    .Read(Read),
    .Write(Write),
    .Clear_n(Clear_n),
    .RSTn(RSTn),
    .Clk(Clk),
    .F_FULL_N(F_FULL_N),
    .F_EMPTY_N(F_EMPTY_N),
    .DATA_OUT(DATA_OUT),
    .USE_DW(USE_DW)
  );

  // Generador de reloj
  initial begin
    Clk = 0;
    forever #5 Clk = ~Clk; // Periodo de 10 unidades de tiempo
  end

  // Estímulos de prueba
  initial begin
    // Inicialización de señales
    DATA_IN = 8'b0;
    Read = 0;
    Write = 0;
    Clear_n = 1;
    RSTn = 0;

    // Reset
    #10 RSTn = 1;

    // Escritura de datos
    #10 Write = 1; DATA_IN = 8'hA5;
    #10 Write = 0;

    // Lectura de datos
    #10 Read = 1;
    #10 Read = 0;

    // Más estímulos según sea necesario
    // ...

    // Finalización de la simulación
    #100 $finish;
  end

  // Monitor para observar las señales
  initial begin
    $monitor("Time=%0t, DATA_IN=%h, DATA_OUT=%h, F_FULL_N=%b, F_EMPTY_N=%b, USE_DW=%d", 
             $time, DATA_IN, DATA_OUT, F_FULL_N, F_EMPTY_N, USE_DW);
  end

endmodule

