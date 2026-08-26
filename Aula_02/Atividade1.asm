lw x10, a
lw x11, b
lw x12, m

# Copia por soma com REG_0 
add x12, x10, x0 

# Direciona para o final no caso falso
bge x11, x12, FIM_IF 

# Executado como consequencia em caso verdaderio
ESCOPO_IF:
add x12, x10, x11

FIM_IF:
halt

a: .word 25
b: .word 12
m: .word 0
