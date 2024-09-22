module count9Bit(
    input logic clk,
    input logic reset,
    input logic up,   // Nowe wejście sterujące kierunkiem liczenia
    input logic [3:0] fraction,
    input logic [1:0] mode,
    output logic [4:0] main_out,
    output logic [4:0] count
);
// na razie licze 5 bitowo i bede skalowac wyjscie tylko idk 
always @(posedge clk) begin
    if (reset) begin
        count <= 0;  // Ustawienie wartości początkowej
        main_out <= 0;
    end case(mode)
        2'b11:
        if (up) begin
                    if (count < 31) begin
                        count <= count + 1;
                        main_out <= count + fraction;
                    end
                    else begin
                    if (count > 0) begin
                        count <= count - 1;
                        main_out <= count - fraction;
                    end
                end
            end
        2'b01: 
            if (count < 31) begin
                count <= count + 1;
                main_out <= count + fraction;
            end else begin
                count <= 0;
            end

        2'b10: 
            if (count > 0) begin
                count <= count - 1;
                main_out <= count - fraction;
            end else begin
                count <= 31;
            end
    endcase
end


endmodule 