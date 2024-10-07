// FICHERO: FIFO.vs
// Autores: Miguel Serra Ferrando, Marc Font González
// Descripción:  implementación sintetizable de una FIFO de 32x8 bits.

// Entradas:
 
//CLOCK:    señal de reloj.
//RESET_N:  reset asíncrono: resetea el control, pone la FIFO como si estuviera vacía
//DATA_IN:  entrada de datos de 8 bits.
//READ:     lectura de la fifo.
//WRITE     escritura a la fifo.
//CLEAR_N:  reset síncrono: resetea el control, pone la FIFO como si estuviera vacía.

// Salidas:

//F_FULL_N:  señal que indica que la FIFO está llena.
//F_EMPTY_N: señal que indica que la FIFO está vacía.
//DATA_OUT:  salida de datos de 8 bits. 
//USE_DW:    salida que indica las posiciones ocupadas de la FIFO. 5 bits 


////////////////////////////////////////////////////////



module FIFO (
    input wire CLOCK,
    input wire RESET_N,
    input wire WRITE,
    input wire READ,
    input wire CLEAR_N,
    input wire [7:0] DATA_IN,
    output reg F_EMPTY_N,
    output reg F_FULL_N,
    output reg [7:0] DATA_OUT,
    output reg [4:0] USE_DW
);

    // Declaración de variables
    logic UP_DN;
    logic count_en;    
    logic [4:0] count;
    logic clear;
	 logic shifter_en;
	 logic shifter_modo;
	 logic [4:0]seleccion;
	 logic [7:0]salida_serie;

    // Definición de estados
    enum logic [1:0] {vacio, otros, lleno} state;
   

    // Lógica de transición de estados
    always_ff @(posedge CLOCK or negedge RESET_N) begin
        if (!RESET_N)
            state = vacio;
        else if (!CLEAR_N)
            state = vacio;
        else begin
            case (state)
                vacio: begin
                    if (WRITE && !READ)
                        state = otros;
                    else if (WRITE && READ)
                        state = vacio;
						  else
								state = vacio;
                end
                otros: begin
                    if (WRITE && !READ )
							if (count == 31)
                        state = lleno;
							 else 
								state = otros;
                    else if (!WRITE && READ)
							if (count == 1)
                        state = vacio;
							else 
								state = otros;
                end
                lleno: begin
						  if (WRITE && READ)
								state = lleno;
						 else if (WRITE && !READ)
                        state = lleno;
								
                   else if (!WRITE && READ)
                        state = otros;
								
						 else if (!WRITE && !READ)
                        state = lleno;
                end
            endcase
        end
    end

    // Instanciaciones de módulos auxiliares
    shifter_2d_var #(.tamanyo(32), .size(8)) shift (
        .clock(CLOCK),
        .reset(RESET_N),
        .enable(shifter_en),   // Revisar si es adecuado
        .modo(shifter_modo),     // Revisar si es adecuado
        .seleccion(seleccion), // No usado en el código actual
        .entrada_serie(DATA_IN),
        .clear(clear),
        .salida_serie(salida_serie)
    );

    counter counter(
        .CLK(CLOCK),
        .RSTn(RESET_N),
        .ENABLE(count_en),
        .UP_DOWN(UP_DN),
        .COUNT(count)
    );
	 
	 
    // Lógica de salida, eliminando inferencia de latches
    always_ff @(posedge CLOCK or negedge RESET_N) begin
        if (!RESET_N) begin
            // Reset de señales
            F_EMPTY_N <= 1'b0;
            F_FULL_N <= 1'b1;            
				shifter_en<= 1'b0;
				shifter_modo<= 1'b0;
				seleccion <= 5'b0;
            USE_DW <= 5'b0;
            DATA_OUT <= 8'b0;
            count_en = 1'b0;
            UP_DN = 1'b0;
        end else if (!CLEAR_N) begin
            // Clear síncrono
            F_EMPTY_N <= 1'b0;
            F_FULL_N <= 1'b1;            
				shifter_en<= 1'b0;
				shifter_modo<= 1'b0;
				seleccion <= 5'b0;
            USE_DW <= 5'b0;
            DATA_OUT <= 8'b0;
            count_en = 1'b0;
            UP_DN = 1'b0;
        end else begin
            // Valores por defecto para evitar latches
            count_en = 1'b0;
            UP_DN = 1'b0;
				seleccion <= 5'b0;

            case (state)
                vacio: begin
                    F_EMPTY_N <= 1'b0;
                    F_FULL_N <= 1'b1;
                    if (WRITE && READ) begin
                        DATA_OUT <= DATA_IN;
                    end else if (WRITE && !READ) begin
								seleccion<=count;
								shifter_en<=0;
								shifter_modo<=1;
                        USE_DW <= USE_DW + 5'b1;
                        count_en = 1;
                        UP_DN = 1; // Incrementar                       
                    end
                end
                otros: begin
                    F_EMPTY_N <= 1'b1;
                    F_FULL_N <= 1'b1;

                    if (WRITE && READ) begin
								shifter_en<=1;
								shifter_modo<=1;
                        seleccion<=count-5'b1;
								DATA_OUT<=salida_serie;
                    end else if (WRITE && !READ) begin
								shifter_en<=0;
								shifter_modo<=1;
								seleccion<=count;
                        USE_DW <= USE_DW + 5'b1;
                        count_en = 1;
                        UP_DN = 1;                        
                    end else if (!WRITE && READ) begin
								shifter_en<=1;
								shifter_modo<=0;
								DATA_OUT<=salida_serie;
                        USE_DW <= USE_DW - 5'b1;
                        count_en = 1;
                        UP_DN = 0; // Decrementar
                        
                    end
                end
                lleno: begin
                    F_EMPTY_N <= 1'b1;
                    F_FULL_N <= 1'b0;

                    if (WRITE && READ) begin
                        shifter_en<=1;
								shifter_modo<=0;
								DATA_OUT<=salida_serie;
								USE_DW <= 5'b11111;
                    end else if (!WRITE && READ) begin
								shifter_en<=1;
								shifter_modo<=0;
								DATA_OUT<=salida_serie;
                        USE_DW <= USE_DW - 5'b1;
                        count_en = 1;
                        UP_DN = 0; // Decrementar
							end
                    else
								USE_DW <= 5'b11111;
                   
                end
            endcase
        end
    end

endmodule







