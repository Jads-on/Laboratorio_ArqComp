`timescale 1ns/1ps

module tb_mux;
   logic [5:0]count;
   logic muxOut;

   mux dut(.f(muxOut), .a(count[5]), .b(count[4]), .c(count[3]), .d(count[2]), .sel1(count[1]), .sel2(count[0]));

   initial begin
     $monitor($time,"a = %b | b = %b | c = %b | d = %b | sel1 = %b | sel2 = %b | muxOut = %b", count[5], count[4], count[3], count[2], count[1], count[0], muxOut);
     for(count = 0; count != 64'b1000000; count++) #10;     
     #10 $stop;
   end

endmodule: tb_mux
