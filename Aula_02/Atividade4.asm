# Guarda o inicio da string
addi x11, x0, 28 

LOOP:

# Carrega o byte atual
lb x10, 0(x11) 
beq x10, x0, FIM # Se for fim de String encerra

# Escreve o byte atual
sb x10, 1024(x0)

# Avanca para o proximo byte
addi x11, x11, 1
beq x0, x0, LOOP # Volta ao inicio do loop

FIM:
halt

str1: .string "Hello World" # End 28






