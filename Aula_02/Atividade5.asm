# Adicao do caractere * ao REG_12
addi x12, x0, 42 # 42 = ascii de *
LOOP:
# Leitura do teclado virtual
lb x10, 1025(x0)
beq    x10, x0, LOOP # Espera o caractere
beq x10, x12, FIM # Se for * leva para o halt
# Escrita na memoria
sb x10, 1024(x0)
beq x0, x0, LOOP # Reincia o Loop
FIM:
halt
