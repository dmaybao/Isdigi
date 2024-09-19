<<<<<<< HEAD
module 

ram_dp #(parameter mem_depth=32, parameter size=8)
(
input [size-1:0] data_in,
input wren,clock,rden,
input [$clog2(mem_depth-1)-1:0] wraddress, 
input [$clog2(mem_depth-1)-1:0] rdaddress,
output logic [size-1:0] data_out
);

logic [size-1:0] mem [mem_depth-1 :0];

always_ff @(posedge clock)
begin
  if (wren==1'b1)
        mem[wraddress]<=data_in;
  if (rden==1'b1)
        data_out<=mem[rdaddress];   
end     

=======
module 

ram_dp #(parameter mem_depth=32, parameter size=8)
(
input [size-1:0] data_in,
input wren,clock,rden,
input [$clog2(mem_depth-1)-1:0] wraddress, 
input [$clog2(mem_depth-1)-1:0] rdaddress,
output logic [size-1:0] data_out
);

logic [size-1:0] mem [mem_depth-1 :0];

always_ff @(posedge clock)
begin
  if (wren==1'b1)
        mem[wraddress]<=data_in;
  if (rden==1'b1)
        data_out<=mem[rdaddress];   
end     

>>>>>>> e99947d70da2da51086db8548407630d59b0de8b
endmodule