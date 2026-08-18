module mux
  (
    output logic f,
    input  logic a, b, sel
  ); 

  and g1(f1, a, n_sel),
      g2(f2, b, sel);
  or  g3(f, f1, f2);
  not g4(n_sel, sel);

endmodule
