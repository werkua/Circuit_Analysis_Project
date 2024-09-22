module const(
    input logic clk,
    output logic [3:0] c
);


always @(posedge clk) begin
        c<=  4'b1111;
end


endmodule