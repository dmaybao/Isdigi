//-----------------------------------------------------------------------------
// Universitat Politècnica de València   |2024-2025
// Isdigi           3º Estit
// 
// Date:     12/9/2024
// Names:     Dan
// Module Name:     FSM
// Project Name:    FIFO
// Description:     Máquina de estados para el control de una memoria FIFO
//
// Dependencies:    CLK, RSTn, ENABLE, UP_DOWN, COUNT
//
// Revision: v 1.0
// Additional Comments:
//-----------------------------------------------------------------------------
module FSM (
    input clk,
    input RSTn,
    input WRITE,
    input READ,
    input [7:0] DATA_IN,
    input [$clog2(n)-1:0] COUNT,
    output logic F_FULL_N,
    output logic F_EMPTY_N,
    output logic ENABLE,
    output logic UP_DOWN,
    output logic WREN,
    output logic RDEN,
    output logic [7:0] DATA_OUT
);

parameter n = 32;
localparam N = $clog2(n);

typedef enum logic [1:0] {
    s0 = 2'b00,  // Vacio
    s1 = 2'b01,  // Otros
    s2 = 2'b10,  // Lleno
    s3 = 2'b11   // Error
} state_t;

state_t state, next_state;

always_ff @(posedge clk or negedge RSTn) begin
    if (!RSTn)
        state <= s0;
    else
        state <= next_state;
end

always_comb begin
    next_state = state;
    ENABLE = 1'b0;
    UP_DOWN = 1'b0;
    WREN = 1'b0;
    RDEN = 1'b0;

    case (state)
        s0: begin  // Vacio
            F_EMPTY_N = 1'b0;
            F_FULL_N = 1'b1;
            if (WRITE && !READ) begin
                ENABLE = 1'b1;
                UP_DOWN = 1'b1;
                WREN = 1'b1;
                next_state = s1;
            end
        end
        s1: begin  // Otros
            F_EMPTY_N = 1'b1;
            F_FULL_N = 1'b1;
            if (WRITE && !READ) begin
                if (COUNT == n-1) begin
                    next_state = s2;
                end else begin
                    ENABLE = 1'b1;
                    UP_DOWN = 1'b1;
                    WREN = 1'b1;
                end
            end else if (!WRITE && READ) begin
                if (COUNT == 1) begin
                    next_state = s0;
                end else begin
                    ENABLE = 1'b1;
                    UP_DOWN = 1'b0;
                    RDEN = 1'b1;
                end
            end
        end
        s2: begin  // Lleno
            F_EMPTY_N = 1'b1;
            F_FULL_N = 1'b0;
            if (!WRITE && READ) begin
                ENABLE = 1'b1;
                UP_DOWN = 1'b0;
                RDEN = 1'b1;
                next_state = s1;
            end
        end
        s3: begin  // Error
            F_EMPTY_N = 1'b0;
            F_FULL_N = 1'b0;
            next_state = s0;
        end
        default: next_state = s0;
    endcase
end

endmodule
