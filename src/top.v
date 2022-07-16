module top(
    input sys_clk,
    input sys_reset_n,
    output [2:0] led
);
    assign led[0] = 1'b1; // G
    assign led[1] = 1'b0; // B
    assign led[2] = 1'b1; // R
endmodule