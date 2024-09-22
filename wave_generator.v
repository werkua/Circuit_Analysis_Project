/*----------- OZNACZENIA W KODZIE ---------------
(...)

    MODE:
        10 - piła w dół;
        01 - piła w górę;
        11 - trójkąt;
        00 - do wykorzystania. 

    STEP_SIZE - ułamek skalujący wyjściowe wartości

(...)
*/


/*
count31 to funckja pomocnicza realizujaca wewnetrzny zegar modulu top 
Pozwala na kontrolę całego układu, dopilnowując,
by wszystko mieściło się w granicy 32 cykli zegara
*/
module count31 ( 
    input logic clk,
    input logic reset,
    input logic up,
    input logic [1:0] mode,
    output logic [4:0] count // Zmienna licząca 0-31
);

always @(posedge clk) begin
    if (reset) begin
        if(mode == 2'b10)begin // pila w dol 
            count<=31;
        end
        else begin
        count <= 0;  // Ustawienie wartości początkowej
        end
    end else begin
        if(mode == 2'b01 && count == 31)begin // resecik
                count <=0;
        end else if (mode == 2'b10 && count == 0)begin
                count <= 31;
        end else
        if (up) begin
                count <= count + 1;
        end else begin
                count <= count - 1;
        end
    end
end
endmodule

/*
value_calculator przelicza odpowiednio wartości
dla danego cyklu zegara oraz ułamka wejściowego
output tej funkcji to to, co widzimy na wyjściu modułu
*/
module value_calculator (
    input logic clk,
    input logic reset,
    input logic up,               
    input logic [1:0] mode,
    input logic [3:0] step_size, 
    input logic [4:0] count,
    output logic [4:0] out        
);

logic [8:0] accumulated_value;   // lepsza precyzja dla 9 bitow izi

always @(posedge clk) begin
    if (reset) begin
        if(mode == 2'b10)begin
            accumulated_value <= 31 * step_size ; // uwazam ze takie mnozenie na tych typach danych jest ryzykowne, ale sie na nich nie znam jeszcze
        end else if(mode == 2'b01) begin
            accumulated_value <=  step_size;
        end else begin
        accumulated_value <= 0;
        end
        out <= 0;
    end else begin
        if(mode == 2'b10 && count == 0) begin
            accumulated_value <=  31 * step_size ;
        end else if(mode == 2'b01 && count == 30) begin
            accumulated_value <= 0;
        end else if (up) begin
            accumulated_value <= accumulated_value + step_size;
        end else begin
            accumulated_value <= accumulated_value - step_size;
        end
        
        out <= accumulated_value[8:4];  // Na wyjście podajemy 5 najstarszych bitów z 9-bitowej inaczej ciezko
    end
end
endmodule

/*
Kontroler kierunku w zależności od trybu pracy (3 zajete {10, 01, 11}, 1 wolny {00})
Mówi czy wartości mają w danym kroku rosnąć czy maleć
*/
module direction_controller (
    input logic clk,
    input logic reset,
    input logic [4:0] count,  
    input logic [1:0] mode,   
    output logic up     
);

parameter UP = 1;
parameter DOWN = 0;

parameter SAW_UP = 2'b01;
parameter SAW_DOWN = 2'b10;
parameter TRIANGLE = 2'b11;

logic state;
logic next_state;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= UP;
    end else begin
        state <= next_state;
    end
end

always @(state, count, mode) begin
    case (mode)
        SAW_UP: next_state <= UP;
        SAW_DOWN: next_state <= DOWN;
        TRIANGLE: begin
            case (state)
                UP: begin
                    if (count == 30) begin
                        next_state <= DOWN;
                    end else begin
                        next_state <= UP;
                    end
                end
                DOWN: begin
                    if (count == 1) begin
                        next_state <= UP;
                    end else begin
                        next_state <= DOWN;
                    end
                end
                default: next_state <= UP;
            endcase
        end
        default: next_state <= UP;
    endcase
end

always @(state, mode) begin
    up = (mode == SAW_UP) ? UP :
         (mode == SAW_DOWN) ? DOWN :
         state;
end
endmodule

/*
Jak mawiał Z. Boniek: "top"
Nie ma to nic wspólnego z tym, że jest jakiś dobry w kopanie piłki (choć dobre piłki rysuje :) ),
ale stanowi nadrzędny moduł całego układu, łącząc powyższe moduly w jedną, średnio działającą
a co najważniejsze zbyt skomplikowaną i złożoną, całość. 
*/
module top (
    input clk,
    input reset,
    input [3:0] step_size, 
    input [1:0] mode,     
    output [4:0] out      
);

wire [4:0] count_internal; 


count31 i_count31 (
    .clk(clk),
    .reset(reset),
    .up(up_signal),
    .mode(mode),
    .count(count_internal)  
);

value_calculator i_value_calculator (
    .clk(clk),
    .reset(reset),
    .up(up_signal),
    .mode(mode),
    .step_size(step_size),
    .count(count_internal),
    .out(out)
);

direction_controller i_control (
    .clk(clk),
    .reset(reset),
    .count(count_internal),  
    .mode(mode),
    .up(up_signal)
);

endmodule
