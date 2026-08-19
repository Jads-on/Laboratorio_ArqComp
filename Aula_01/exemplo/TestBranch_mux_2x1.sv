`timescale 1ns/1ps

module tb_mux;
   logic [2:0]count;
   logic muxOut;

   mux dut(.f(muxOut), .a(count[2]), .b(count[1]), .sel(count[0]));

   initial begin
     $monitor($time,"a = %b | b = %b | sel = %b | muxOut = %b", count[2], count[1], count[0], muxOut);
     for(count = 0; count != 3'b111; count++) #10;     
     #10 $stop;
   end

endmodule: tb_mux
