// FICHERO: tb_FIFO.vs
// Autores: Miguel Serra Ferrando, Marc Font González
// Descripción:  testbench del modulo de una FIFO de 32x8 bits.

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


module tb_FIFO;
  // Declaración de parámetros
  parameter WIDTH = 8;        // Ancho de data
  parameter DEPTH = 32;       // Longitud de la FIFO (count)

  // Declaracion de señales
  reg CLOCK;
  reg RESET_N;
  reg WRITE;
  reg READ;
  reg CLEAR_N;
  reg [WIDTH-1:0] DATA_IN;
  wire F_EMPTY_N;
  wire F_FULL_N;
  wire [WIDTH-1:0] DATA_OUT;
  wire [4:0] USE_DW;

  // Instanciación de la FIFO
  FIFO fifo (
    .CLOCK(CLOCK),
    .RESET_N(RESET_N),
    .WRITE(WRITE),
    .READ(READ),
    .CLEAR_N(CLEAR_N),
    .DATA_IN(DATA_IN),
    .F_EMPTY_N(F_EMPTY_N),
    .F_FULL_N(F_FULL_N),
    .DATA_OUT(DATA_OUT),
    .USE_DW(USE_DW)
  );

  // Generación de la señal de reloj
  always #5 CLOCK = ~CLOCK;

  // Setup inicial
  initial begin
    CLOCK = 0;
    RESET_N = 0;
    CLEAR_N = 1;
    WRITE = 0;
    READ = 0;
    DATA_IN = 8'h00;

    // Reseteamos la FIFO
    reset_fifo();
    
    // Test en el estado vacío
    test_empty_state();

    // Test en el estado otros
    test_otros_state();

    // Test en el estado lleno
    test_full_state();

    // Test CLEAR_N
    test_clear_n();

    // Test RESET_N
    test_reset_n();
    
    $stop;
  end

  // Task para reset de la FIFO
  task reset_fifo();
    begin
      RESET_N = 0;
      #20;
      RESET_N = 1;
      #10;
    end
  endtask

  // Test del estado vacío
  task test_empty_state();
    begin
      $display("Testeando estado vacío...");

      // Nos aseguramos de que la FIFO esté vacía después del reset
      assert(F_EMPTY_N == 0) else $fatal(1, "La FIFO no está vacía despues del reset");

      
      // Test 1 (Escribir y Leer a la vez)
      WRITE = 1; READ = 1;
      DATA_IN = 8'hAA;
      #10;
      // Comprobamos que DATA_OUT muestra el valor correcto
      if (DATA_OUT !== 8'hAA) begin
        $fatal(0, "DATA_OUT incorrecto con lectura y escritura simultanea en el estado vacío");
      end
    end
  endtask

  // Test de la FIFO en el estado (otros)
  task test_otros_state();
    begin
      $display("Testeando estado otros...");

      // Introducimos datos en la fifo
      repeat ((DEPTH/2)-1) begin
        WRITE = 1; READ = 0;
        DATA_IN = $random;
        #10;
      end
      WRITE = 0; READ = 0;
      
      // La FIFO deberia estar en el estado otros
      assert(F_EMPTY_N == 1 && F_FULL_N == 1) else $fatal(1, "La FIFO debería estar en el estado otros.");

      // Leemos los datos escritos para pasar al estado vacío
      repeat (DEPTH/2) begin
        WRITE = 0; READ = 1;
        #10;
      end

      // La FIFO debería estar vacía
      assert(F_EMPTY_N == 0) else $fatal(1, "La FIFO debería estar vacía.");
    end
  endtask

  // Test de la FIFO en el estado lleno (lleno)
  task test_full_state();
    begin
      $display("Testeando estado lleno...");

      // llenamos la FIFO 
      repeat (DEPTH) begin
        WRITE = 1; READ = 0;
        DATA_IN = $random;
        #30;
      end
      WRITE = 0;

      // La FIFO debería estar llena
      assert(F_FULL_N == 0) else $fatal(1, "¨La FIFO no está llena y debería estarlo.");
		
		//Lectura y escritura simultanea, debería mantener el estado
		WRITE = 1; READ = 1;
      #10;
      assert(F_FULL_N == 0) else $fatal(1, "La FIFO debería permanecer en el estado lleno.");


     
      // Leemos un dato, la FIFO debería cambiar de estado
      WRITE = 0; READ = 1;
      #10;
      assert(F_FULL_N == 1) else $fatal(1, "La FIFO no debería estar llena despúes de hacer una operación de lectura.");
    end
  endtask

  // Test CLEAR_N
  task test_clear_n();
    begin
      $display("Testeando CLEAR_N...");

      // Llenamos parcialmente la FIFO
      repeat (DEPTH/2) begin
        WRITE = 1; READ = 0;
        DATA_IN = $random;
        #10;
      end
      WRITE = 0;

      // Assert CLEAR_N
      CLEAR_N = 0;
      #10;
      CLEAR_N = 1;

      // La FIFO debería estar vacía después del clear
      assert(F_EMPTY_N == 0 && F_FULL_N == 1) else $fatal(1, "La FIFO no está vacía después del clear.");
    end
  endtask

  // Test RESET_N 
  task test_reset_n();
    begin
      $display("Testeando RESET_N...");

      // Llenamos parcialmente la FIFO
      repeat (DEPTH/4) begin
        WRITE = 1; READ = 0;
        DATA_IN = $random;
        #10;
      end
      WRITE = 0;

      // Aplicamos el reset
      reset_fifo();

      // La FIFO debería estar vacía después del reset
      assert(F_EMPTY_N == 0 && F_FULL_N == 1) else $fatal(1, "La FIFO no está vacía después del reset.");
    end
  endtask

endmodule
