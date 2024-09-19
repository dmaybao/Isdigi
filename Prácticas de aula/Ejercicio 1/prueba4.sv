 `timescale 1 ns/ 1 ps
 

module pruebas;
  
  logic [3:0] a ;
  logic b,c;
  logic clk;
  initial
  begin
  @(posedge clk) a=2;
  @(posedge clk) a=4;
  @(posedge clk) a=2;  @(posedge clk) a=2;
  @(posedge clk) a=4;
  @(posedge clk) ;
  $finish;
end

initial
begin
  clk=0;
forever #50 clk=~clk;
end


assert property (@(posedge clk)  a==2 ##1 a==4);

endmodule