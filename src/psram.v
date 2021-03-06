// I used the original code of TangNano example and modify it:
// https://github.com/sipeed/Tang-Nano-examples/blob/master/nano/src/LCD_PSRAM.v

module psram(
    input sys_clk,
    input sys_reset_n,
    output reg ce_n,
    output clk,
    output reg [3:0] sio,
    input in // SO pin
);
    assign clk = !ce_n & sys_clk;

    // Finite state machine's state variables.
    reg [7:0] sm_state_main;
    reg [7:0] sm_state_command;
    reg [7:0] sm_state_output_byte;

    // Main State Machine
    // Use negative edge of sys_clk to match datasheet's signal diagram.
    always @(negedge sys_clk or negedge sys_reset_n) begin
        if (!sys_reset_n) begin
            ce_n <= 1'b1;
            sio[0] <= 1'b0;
            sio[1] <= 1'b0;
            sio[2] <= 1'b0;
            sm_state_main <= 8'd0;
            sm_state_command <= 8'd0;
            sm_state_output_byte <= 8'd0;
        end else begin
            case (sm_state_main)
                // Signal control sequences start from here.
                8'd0: psram_reset(8'd1);
                8'd1: psram_write(8'd2, 24'h70f0fe, 8'h66);
                8'd2: psram_read(8'd3, 24'h70f0fe);
                8'd3: begin
                    // Do nothing
                end
            endcase
        end
    end

    // Execute Reset operation.
    task psram_reset;
        input [7:0] next_state;
        begin
            // Command State Machine
            case (sm_state_command)
                8'd0: output_byte(8'd1, 8'h66); // Reset Enable
                8'd1: output_delimiter(8'd3, 1'd1);
                8'd3: output_byte(8'd4, 8'h99); // Reset
                8'd4: output_delimiter(8'd5, 1'd1);
                8'd5: output_byte(8'd6, 8'h9f); // Read ID
                8'd6: output_byte(8'd7, 8'hff);
                8'd7: output_byte(8'd8, 8'hff);
                8'd8: output_byte(8'd9, 8'hff);

                // Observe SIO pin of PSRAM using a logic analyzer.
                // You will see the signals: MF ID (0x0D) and Known Good Die (0x5D).
                8'd9: noop(8'd10);
                8'd10: noop(8'd11);
                8'd11: noop(8'd12);
                8'd12: noop(8'd13);
                8'd13: noop(8'd14);
                8'd14: noop(8'd15);
                8'd15: noop(8'd16);
                8'd16: noop(8'd17);
                8'd17: noop(8'd18);
                8'd18: noop(8'd19);
                8'd19: noop(8'd20);
                8'd20: noop(8'd21);
                8'd21: noop(8'd22);
                8'd22: noop(8'd23);
                8'd23: noop(8'd24);
                8'd24: noop(8'd25);
                8'd25: noop(8'd26);
                8'd26: output_delimiter(8'd27, 1'd1);
                8'd27: begin
                    sm_state_command <= 8'd0;
                    sm_state_main <= next_state;
                end
            endcase
        end
    endtask

    // Execute SPI Write operation.
    task psram_write;
        input [7:0] next_state;
        input [23:0] address;
        input [7:0] data;
        begin
            // Command State Machine
            case (sm_state_command)
                8'd0: output_byte(8'd1, 8'h02); // Write Command
                8'd1: output_byte(8'd2, address[23: 16]);
                8'd2: output_byte(8'd3, address[15: 8]);
                8'd3: output_byte(8'd4, address[7: 0]);
                8'd4: output_byte(8'd5, data);
                8'd5: output_delimiter(8'd6, 1'd1);
                8'd6: begin
                    sm_state_command <= 8'd0;
                    sm_state_main <= next_state;
                end
            endcase
        end
    endtask

    // Execute SPI Read operation.
    task psram_read;
        input [7:0] next_state;
        input [23:0] address;
        begin
            // Command State Machine
            case (sm_state_command)
                8'd0: output_byte(8'd1, 8'h03); // Read Command
                8'd1: output_byte(8'd2, address[23: 16]);
                8'd2: output_byte(8'd3, address[15: 8]);
                8'd3: output_byte(8'd4, address[7: 0]);

                // Observe SIO pin of PSRAM using a logic analyzer.
                // You will see the written value.
                8'd4: noop(8'd5);
                8'd5: noop(8'd6);
                8'd6: noop(8'd7);
                8'd7: noop(8'd8);
                8'd8: begin
                    sm_state_command <= 8'd0;
                    sm_state_main <= next_state;
                end
            endcase
        end
    endtask

    // No operation. Only consumes just 1 clock.
    task noop;
        input [7:0] next_state;
        begin
            sm_state_command <= next_state;
        end
    endtask

    // Output just 1 byte via sio[0] pin.
    task output_byte;
        input [7:0] next_state;
        input [7:0] output_data;

        begin
            // Output Byte State Machine
            case (sm_state_output_byte)
                8'd0: begin
                    ce_n <= 1'b0; // TODO: Fix timing issue.
                    sio[0] <= output_data[7];
                    sm_state_output_byte <= 8'd1;
                end
                8'd1: begin
                    sio[0] <= output_data[6];
                    sm_state_output_byte <= 8'd2;
                end
                8'd2: begin
                    sio[0] <= output_data[5];
                    sm_state_output_byte <= 8'd3;
                end
                8'd3: begin
                    sio[0] <= output_data[4];
                    sm_state_output_byte <= 8'd4;
                end
                8'd4: begin
                    sio[0] <= output_data[3];
                    sm_state_output_byte <= 8'd5;
                end
                8'd5: begin
                    sio[0] <= output_data[2];
                    sm_state_output_byte <= 8'd6;
                end
                8'd6: begin
                    sio[0] <= output_data[1];
                    sm_state_output_byte <= 8'd7;
                end
                8'd7: begin
                    sio[0] <= output_data[0];
                    sm_state_command <= next_state;
                    sm_state_output_byte <= 8'd0;
                end
            endcase
        end
    endtask

    // Control #CE signal.
    task output_delimiter;
        input [7:0] next_state;
        input new_ce_n;

        begin
            ce_n = new_ce_n;
            sm_state_command <= next_state;
            sm_state_output_byte <= 8'd0;
        end
    endtask

endmodule