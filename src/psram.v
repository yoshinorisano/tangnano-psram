module psram(
    output ce_n,
    output clk,
    output [3:0] sio
);
    assign ce_n = 1'b1;
    assign clk = 1'b0;
    assign sio[0] = 1'b0;
    assign sio[1] = 1'b0;
    assign sio[2] = 1'b0;
endmodule