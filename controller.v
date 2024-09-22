/*
    MODUŁ KONTROLI:
    11 - trójkat 
    10 - piła góra -> dół 
    01 - piła doł -> góra 
    00 - wolne (teraz przypisujemy zero)
*/

module direction_controller (
    input logic clk,
    input logic reset,
    input logic [4:0] count,
    input logic [1:0] mode,
    input logic [3:0] fraction,
    output logic up
);

parameter UP = 1;
parameter DOWN = 0;

logic state;
logic next_state;

// Logika sekwencyjna
always @(posedge clk) begin
    if (reset) begin
        state <= UP;
    end else begin
        state <= next_state;
    end
end

// Logika przejść między stanami
always @(state, count, mode) begin
    case (mode)
        2'b11: begin // trojkat
        case (state)
            UP: begin
                if (count == 31) begin
                    next_state <= DOWN;
                end else begin
                    next_state <= UP;
                end
            end
            DOWN: begin
                if (count == 0) begin
                    next_state <= UP;
                end else begin
                    next_state <= DOWN;
                end
            end
        endcase
        end
        2'b01: begin // piła w górę
                next_state <= UP;
        end
        2'b10: begin
                next_state <= DOWN; 
        end
            default: next_state <= UP;
    endcase 
end

// Logika wyjść
always @(state, count) begin
    case (state)
        UP: up <= UP;
        DOWN: up <= DOWN;
        default: up <= UP;
    endcase
end
endmodule
