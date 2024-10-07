// FICHERO: counter.vs
// Autores: Miguel Serra Ferrando, Marc Font González
// Descripción: contador de modulo maximo 31 con funcion de contar de manera ascendente y descendente

// Entradas:
 
//CLOCK:    señal de reloj.
//RST_n:  	reset asíncrono: resetea el control,
//ENABLE    señal de habilitacion del contador.
//UP_DOWN   señal que si es 1 el contador pasa a ser ascendente, en caso de ser 0 el contador sera descendente.

// Salidas:

//COUNT:  señal que indica el valor del modulo.


////////////////////////////////////////////////////////

module counter (CLK, RSTn, ENABLE, UP_DOWN, COUNT);
  input CLK, RSTn, ENABLE, UP_DOWN; // entradas
  output reg [4:0] COUNT; // salida

  always @(posedge CLK or negedge RSTn)
    if (~RSTn)
      COUNT <= 0;
    else if (ENABLE)
    begin
      if (UP_DOWN) // Contador hacia arriba
      begin
        if (COUNT == 31)
          COUNT <= 0;
        else
          COUNT <= COUNT + 5'b1;
      end
      else // Contador hacia abajo
      begin
        if (COUNT == 0)
          COUNT <= 31;
        else
          COUNT <= COUNT - 5'b1;
      end
    end
endmodule
