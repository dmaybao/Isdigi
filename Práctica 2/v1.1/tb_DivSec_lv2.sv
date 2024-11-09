module tb_DivSec_lv2;

    // Parámetros
    parameter tamanyo = 32;
    
    // Señales de testbench
    logic CLK;
    logic RSTa;
    logic Start;
    logic [tamanyo-1:0] Num;
    logic [tamanyo-1:0] Den;
    logic [tamanyo-1:0] Coc;
    logic [tamanyo-1:0] Res;
    logic Done;

    // Instancia del módulo DUV
    Divisor_Algoritmico #(tamanyo) uut (
        .CLK(CLK),
        .RSTa(RSTa),
        .Start(Start),
        .Num(Num),
        .Den(Den),
        .Coc(Coc),
        .Res(Res),
        .Done(Done)
    );

    // Generación de clock
    initial begin
        CLK = 0;
        forever #5 CLK = ~CLK; // 100MHz
    end

    // Generación de reset
    initial begin
        RSTa = 0;
        #15 RSTa = 1; // Asigna reset durante 15 ns
    end

    // Generación de estímulos aleatorios
    initial begin
		// Inicialización
			boot();
			#10
			
			


            // Mostrar resultados
            $display("Num: %0d, Den: %0d, Coc: %0d, Res: %0d", Num, Den, Coc, Res);
        end

        // Finalizar simulación
        $finish;
    end

    // Covergroups
    covergroup cg_division @(posedge CLK);
        coverpoint Num {
			bins num0 = $urandom_range(1, 100);
			bins num1 = $urandom_range(-100, -1);
			bins num2 = $urandom_range(-100, 100);
			}
			coverpoint Den {
			bins den0 = $urandom_range(1, 10);
			bins den1 = $urandom_range(-10, 0);
			bins den2 = $urandom_range(-10, 10);
			}
			coverpoint Coc {
			bins coc0 = 0;
			}
			coverpoint Res {
			bins res0 = 0;
			bins res1 = 1;
			}
	endgroup
	
	//task
	
	task boot(){
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
        $display("Sistema Iniciado");
	
	}
	
	
			
			
					
				
		  
		  
    endgroup

    cg_division cg = new();
	 

    // Asegurando la cobertura de los grupos
    initial begin
        forever @(posedge CLK) begin
            cg.sample();
        end
    end

endmodule
























