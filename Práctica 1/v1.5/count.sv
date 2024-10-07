// Universitat Politécnica de Valéncia
// Escuela Técnica Superior de Ingenieros de Telecomunicación
// --------------------------------------------------------------------
// Sistemas Digitales Programables
// Curso 2024-2025
// --------------------------------------------------------------------
// Nombre del archivo: count.v
//
// Descripción: Contador que cuennta tanto ascendente como descendente
//
// --------------------------------------------------------------------
// Versión: V1.0 | Fecha Modificacion: 13/03/2024
//
// Autor: Orlyn Leonel Morán Brito
// Ordenador de trabajo: Personal
// --------------------------------------------------------------------


module count(CLK, RSTn, ENABLE, COUNT, TC, UP_DOWN);
 
input CLK, RSTn, ENABLE, UP_DOWN;
output reg [4:0] COUNT;
output TC;
 
 
 
always_ff @(posedge CLK or negedge RSTn)
 if (~RSTn)
	COUNT <= 0;
else if (ENABLE)
  if(UP_DOWN)
		begin 
		if (COUNT == 31)
			COUNT <= 0;
		else
			COUNT <= COUNT + 1;
		end
	else if(!UP_DOWN)
		begin
		if (COUNT == 0)
			COUNT <= 31;
		else
			COUNT <= COUNT - 1;
		end
		

assign TC = (COUNT == 31) ? 1 : 0;

endmodule 