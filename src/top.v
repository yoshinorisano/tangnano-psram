module top(
    input sys_clk,
    //input sys_reset_n,
    output [2:0] led,
    output          psram_ce_n,
    output          psram_clk,
    output [3:0]    psram_sio
);
    assign led[0] = 1'b1; // G
    assign led[1] = led_b; // B
    assign led[2] = 1'b1; // R

    reg [31:0] counter = 0;
    reg sys_reset_n = 1'd1;

    reg led_b = 0;

    always @(posedge sys_clk) begin
        if (counter <= 32'd27_000_000) begin
            counter <= counter + 1'd1;
            sys_reset_n <= 1'd1;
        end else begin
            sys_reset_n <= 1'd0;
            counter <= 32'd0;
            led_b <= !led_b;
        end
    end

    psram psram_inst(
        .sys_clk(sys_clk),
        .sys_reset_n(sys_reset_n),
        .ce_n(psram_ce_n),
        .clk(psram_clk),
        .sio(psram_sio)
    );
endmodule