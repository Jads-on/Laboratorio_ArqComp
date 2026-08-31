# Pseudo-codigo
# SE i = j:
# f = g + h
# SENÃO:
# f = g - h

lw x10, i
lw x11, j
lw x12, f
lw x13, g
lw x14, h

# Direciona para o final no caso falso
bne x10, x11, ELSE 

# Executado como consequencia em caso verdaderio
ESCOPO_IF:
add x12, x13, x14
beq x0, x0, FIM # Pula para o fim

ELSE:
sub x12, x13, x14

FIM:
halt


