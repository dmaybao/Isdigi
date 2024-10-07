//-----------------------------------------------------------------------------
// Universitat Politècnica de València   |  2024-2025
// Isdigi           3º Estit
// 
// Date:     25/9/2024
// Names:     Daniel Mayoral Baños
// Module Name:     shifter_2d_var
// Project Name:    FIFO
// Description:     Módulo shifter del Datapath
//
// Dependencies:    clock, clear,reset, enable, modo, [$clog2(tamanyo-1)-1:0] seleccion,
//							[size-1:0]entrada_serie, [size-1:0] salida_serie)
//	Parameters: 	  tamanyo=32, size=8
//
// Revision: v 1.3
// Additional Comments:
//-----------------------------------------------------------------------------
module shifter_2d_var
#(parameter tamanyo=32, parameter size=8)
(input clock, //se�al de reloj
input reset, //reset asincrono
input enable,
input modo, //entrada serie variable o fija
input [$clog2(tamanyo-1)-1:0] seleccion,
input [size-1:0]entrada_serie,
input clear,
output [size-1:0] salida_serie) ;

logic [tamanyo-1:0][size-1:0] aux;
always_ff @(posedge clock or negedge reset)
if (!reset)
        aux<={tamanyo{'0}};
else
    if (!clear)
        aux<={tamanyo{'0}};
    else
        if (enable==1'b1)
            if (modo==1'b1)
            begin
                aux<={entrada_serie,aux[tamanyo-1:1]};  
                aux[seleccion]<=entrada_serie;
            end
            else
                aux<={entrada_serie,aux[tamanyo-1:1]};          
        else
            if (modo==1'b1)
                aux[seleccion]<=entrada_serie;

assign salida_serie=aux[0];
endmodule