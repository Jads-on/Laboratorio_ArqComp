module safecrack_fsm (
    input  logic       clk,      
    input  logic       rst_n,    
    input  logic [3:0] key_n,    
    output logic       unlocked,
    output logic [8:0] leds 
);

logic [3:0] btn;
assign btn = ~key_n;

localparam logic [3:0] AZUL     = 4'b0001;
localparam logic [3:0] AMARELO  = 4'b0010;
localparam logic [3:0] VERDE    = 4'b0100;
localparam logic [3:0] VERMELHO = 4'b1000;

typedef enum logic [4:0] {
    IDLE   = 5'b00001,  
    S1     = 5'b00010,  
    S2     = 5'b00100,  
    S3     = 5'b01000,  
    UNLOCK = 5'b10000    
} state_t;

state_t state, next_state;

logic [3:0] btn_prev;      
logic       btn_rise;      
logic [19:0] debounce_cnt;

// Registra o estado anterior do botao 
always_ff @(posedge clk or negedge rst_n) begin

    // Reset ativo em 0 (switch)
    if (!rst_n) begin
        btn_prev     <= 4'b0000;
        debounce_cnt <= 0;
        btn_rise     <= 0;
    end 

    else begin
        btn_rise <= 0;

        // Deteccao da ativacao do botao e deboucing
        if (btn != btn_prev) begin
            debounce_cnt <= debounce_cnt + 1;
            if (debounce_cnt == 20'hFFFFF) begin
                if (btn_prev == 4'b0000 && btn != 4'b0000) begin
                    btn_rise <= 1;
                end
                btn_prev <= btn;  
                debounce_cnt <= 0;
            end
        end 
        else begin
            debounce_cnt <= 0;
        end
    end
end

// Transicao de estados
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) state <= IDLE;
    else        state <= next_state;
end

// Descricao dos estados
always_comb begin
    next_state = state;  

    // Habilita apenas caso o botao tenha sido pressionado
    if (btn_rise) begin
        unique case (state)
            IDLE: next_state = (btn == AZUL)     ? S1 : IDLE;
            S1:   next_state = (btn == AMARELO)  ? S2 : IDLE;
            S2:   next_state = (btn == AMARELO)  ? S3 : IDLE;
            S3:   next_state = (btn == VERMELHO) ? UNLOCK : IDLE;
            UNLOCK: next_state = UNLOCK;  
            default: next_state = IDLE;
        endcase
    end
end

// Saidas

assign unlocked = (state == UNLOCK); // Saida do led para o desbloqueio

assign leds [3:0] = btn;   // LEDs 0 a 3 mostra se o botao foi pressionadp
assign leds [8:4] = state; // LEDs 4 a 8 mostra o estado atual da FSM 

endmodule