`timescale 1ns/1ps

module safecrack_fsm_tb;

    // Parâmetros de Simulação
    // Quantidade de ciclos para ultrapassar o contador de debounce (20'hFFFFF = 1.048.575)
    localparam int DEBOUNCE_WAIT = 1048580; 

    // Mapeamento das teclas (Ativo em nível BAIXO: key_n = ~btn)
    localparam logic [3:0] KEY_NONE     = 4'b1111; // Nenhum botão pressionado
    localparam logic [3:0] KEY_AZUL     = 4'b1110; // btn = 4'b0001
    localparam logic [3:0] KEY_AMARELO  = 4'b1101; // btn = 4'b0010
    localparam logic [3:0] KEY_VERDE    = 4'b1011; // btn = 4'b0100
    localparam logic [3:0] KEY_VERMELHO = 4'b0111; // btn = 4'b1000

    // Codificação de estados em One-Hot (leds[8:4])
    localparam logic [4:0] ST_IDLE   = 5'b00001;
    localparam logic [4:0] ST_S1     = 5'b00010;
    localparam logic [4:0] ST_S2     = 5'b00100;
    localparam logic [4:0] ST_S3     = 5'b01000;
    localparam logic [4:0] ST_UNLOCK = 5'b10000;

    // Sinais de estímulo e observação
    logic       clk;
    logic       rst_n;
    logic [3:0] key_n;
    logic       unlocked;
    logic [8:0] leds;
   
    // Instância do DUT (Device Under Test)
    safecrack_fsm dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .key_n    (key_n),
        .unlocked (unlocked),
        .leds     (leds)
    );

    initial clk = 0;
    always #10 clk = ~clk;

    // -------------------------------------------------------------------------
    // Task: Pressiona um botão por tempo suficiente para vencer o debounce
    // -------------------------------------------------------------------------
    task press_key(input logic [3:0] key_val, input int extra_cycles = 0);
        @(negedge clk);
        key_n = key_val; // Aplica a tecla desejada (ativo em nível baixo)
        
        // Aguarda passar o tempo do debounce para o botão ser aceito
        repeat (DEBOUNCE_WAIT + extra_cycles) @(posedge clk);
        
        @(negedge clk);
        key_n = KEY_NONE; // Solta a tecla
        
        // Aguarda estabilizar e o debounce da liberação ser processado
        repeat (DEBOUNCE_WAIT) @(posedge clk);
    endtask

    // -------------------------------------------------------------------------
    // Task: Verifica o estado atual da FSM e o sinal unlocked
    // -------------------------------------------------------------------------
    task check_state(
        input logic [4:0] expected_state, 
        input logic       expected_unlocked, 
        input string      msg
    );
        logic [4:0] current_state;
        assign current_state = leds[8:4];

        @(negedge clk);
        if (current_state === expected_state && unlocked === expected_unlocked) begin
            $display("[PASS] %s | Estado = 5'b%05b | Unlocked = %b", 
                     msg, current_state, unlocked);
        end else begin
            $display("[FAIL] %s | Esperado: Estado=5'b%05b, Unlocked=%b | Obtido: Estado=5'b%05b, Unlocked=%b", 
                     msg, expected_state, expected_unlocked, current_state, unlocked);
        end
    endtask

    // -------------------------------------------------------------------------
    // Sequência de testes
    // -------------------------------------------------------------------------
    initial begin
        // Dump de formas de onda para visualização no GTKWave
        $dumpfile("safecrack_fsm.vcd");
        $dumpvars(0, safecrack_fsm_tb);

        // Condição inicial
        rst_n = 1'b1;
        key_n = KEY_NONE; // Nenhuma tecla pressionada (4'b1111)

        // ------------------------------------------------------------------
        // Teste 1: Reset Inicial
        // ------------------------------------------------------------------
        $display("\n=== Teste 1: Reset Inicial ===");
        rst_n = 1'b0;
        repeat (5) @(posedge clk);
        rst_n = 1'b1;
        @(posedge clk);
        check_state(ST_IDLE, 1'b0, "Apos reset -> IDLE");

        // ------------------------------------------------------------------
        // Teste 2: Digitação da Senha Correta (AZUL -> AMARELO -> AMARELO -> VERMELHO)
        // ------------------------------------------------------------------
        $display("\n=== Teste 2: Sequencia Correta da Senha ===");
        
        press_key(KEY_AZUL);
        check_state(ST_S1, 1'b0, "Passo 1: Pressionou AZUL -> S1");

        press_key(KEY_AMARELO);
        check_state(ST_S2, 1'b0, "Passo 2: Pressionou AMARELO -> S2");

        press_key(KEY_AMARELO);
        check_state(ST_S3, 1'b0, "Passo 3: Pressionou AMARELO -> S3");

        press_key(KEY_VERMELHO);
        check_state(ST_UNLOCK, 1'b1, "Passo 4: Pressionou VERMELHO -> UNLOCK (Desbloqueado)");

        // ------------------------------------------------------------------
        // Teste 3: Erro de Senha (Retorno ao IDLE)
        // ------------------------------------------------------------------
        $display("\n=== Teste 3: Erro de Senha ===");
        // Reseta para reiniciar o teste no IDLE
        rst_n = 1'b0; repeat (2) @(posedge clk); rst_n = 1'b1; @(posedge clk);

        press_key(KEY_AZUL);
        check_state(ST_S1, 1'b0, "Inicio: AZUL -> S1");

        press_key(KEY_VERDE); // Botão incorreto!
        check_state(ST_IDLE, 1'b0, "Tecla errada (VERDE em S1) -> Volta para IDLE");

        // ------------------------------------------------------------------
        // Teste 4: Botão Segurado por Tempo Prolongado
        // ------------------------------------------------------------------
        $display("\n=== Teste 4: Botao segurado (nao deve avancar mais de 1 estado) ===");
        // Pressiona AZUL e segura pelo dobro do tempo
        press_key(KEY_AZUL, DEBOUNCE_WAIT * 2); 
        check_state(ST_S1, 1'b0, "AZUL segurado -> Deve ir apenas para S1");

        // ------------------------------------------------------------------
        // Teste 5: Reset durante a Operação
        // ------------------------------------------------------------------
        $display("\n=== Teste 5: Reset durante operacao ===");
        press_key(KEY_AMARELO); // Vai para S2
        check_state(ST_S2, 1'b0, "Avancou para S2");

        rst_n = 1'b0;
        repeat (3) @(posedge clk);
        rst_n = 1'b1;
        @(posedge clk);
        check_state(ST_IDLE, 1'b0, "Reset acionado em S2 -> Volta para IDLE");

        $display("\n=== Simulacao concluida com sucesso ===\n");
        $finish;
    end

endmodule