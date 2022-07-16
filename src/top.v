module top(
    input sys_clk,
    input sys_reset_n,
    output [2:0] led,
    output          psram_ce_n,
    output          psram_clk,
    output [3:0]    psram_sio
);
    assign led[0] = 1'b1; // G
    assign led[1] = 1'b0; // B
    assign led[2] = 1'b1; // R

    psram psram_inst(
        .ce_n(psram_ce_n),
        .clk(psram_clk),
        .sio(psram_sio)
    );
endmodule