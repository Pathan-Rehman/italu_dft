`timescale 1ns/1ps
// Standalone self-checking testbench for tt_um_italu.
// Usage: vvp sim.vvp | tee results.txt

module tb;

    reg clk = 0;
    reg rst_n = 0;
    reg [7:0] ui_in = 0;
    reg [7:0] uio_in = 0;
    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;
    wire ena = 1'b1;

    integer errors = 0;
    integer tests  = 0;
    integer i;

    tt_um_italu dut (
        .ui_in(ui_in), .uo_out(uo_out),
        .uio_in(uio_in), .uio_out(uio_out), .uio_oe(uio_oe),
        .ena(ena), .clk(clk), .rst_n(rst_n)
    );

    always #10 clk = ~clk;

    // VCD waveform dump
    initial begin
        $dumpfile("tb.vcd");
        $dumpvars(0, tb);
    end

    // Shift a 20-bit instruction LSB-first: {opcode[3:0], B[7:0], A[7:0]}
    task load_instr(input [3:0] op, input [7:0] a, input [7:0] b);
        reg [19:0] instr;
        integer k;
        begin
            instr = {op, b, a};
            for (k = 0; k < 20; k = k + 1) begin
                // bit0 = DATA_IN, bit1 = LOAD_EN
                ui_in = {5'b00000, 1'b1, instr[k]};
                @(posedge clk);
            end
            ui_in = 8'h00;
            @(posedge clk);
        end
    endtask

    // Execute current instruction and return result
    task exec_op;
        begin
            ui_in = 8'h04; // EXECUTE
            @(posedge clk);
            ui_in = 8'h00;
            #1;
        end
    endtask

    task check(input [7:0] got, input [7:0] exp, input string name);
        begin
            tests = tests + 1;
            if (got !== exp) begin
                errors = errors + 1;
                $display("FAIL %0s: expected %02h got %02h", name, exp, got);
            end else begin
                $display("PASS %0s: %02h", name, got);
            end
        end
    endtask

    // Reference ALU model
    function [7:0] ref_alu(input [3:0] op, input [7:0] a, input [7:0] b);
        begin
            case (op)
                4'h0: ref_alu = a + b;
                4'h1: ref_alu = a - b;
                4'h2: ref_alu = a & b;
                4'h3: ref_alu = a | b;
                4'h4: ref_alu = a ^ b;
                4'h5: ref_alu = ~a;
                4'h6: ref_alu = a << 1;
                4'h7: ref_alu = a >> 1;
                4'h8: ref_alu = {a[7], a[7:1]};
                4'h9: ref_alu = {a[6:0], a[7]};
                4'hA: ref_alu = {a[0], a[7:1]};
                4'hB: ref_alu = ($signed(a) < $signed(b)) ? 8'h01 : 8'h00;
                4'hC: ref_alu = (a < b) ? a : b;
                4'hD: ref_alu = (a > b) ? a : b;
                4'hE: begin
                    ref_alu = a + b;
                    if (!a[7] && !b[7] && ref_alu[7])      ref_alu = 8'h7F;
                    else if (a[7] && b[7] && !ref_alu[7])  ref_alu = 8'h80;
                end
                4'hF: begin
                    ref_alu = a - b;
                    if (!a[7] && b[7] && ref_alu[7])       ref_alu = 8'h7F;
                    else if (a[7] && !b[7] && !ref_alu[7]) ref_alu = 8'h80;
                end
            endcase
        end
    endfunction

    initial begin

        // ------------------------------------------------------------
        // Reset
        // ------------------------------------------------------------
        repeat (5) @(posedge clk);
        rst_n = 1;
        repeat (3) @(posedge clk);

        $display("=== iTALU local RTL regression ===");

        // ------------------------------------------------------------
        // T1: all 16 opcodes vs reference model
        // ------------------------------------------------------------
        for (i = 0; i < 16; i = i + 1) begin
            load_instr(i[3:0], 8'hA5 ^ i[3:0], 8'h3C + i[3:0]);
            exec_op;
            check(uo_out, ref_alu(i[3:0], 8'hA5 ^ i[3:0], 8'h3C + i[3:0]),
                  $sformatf("op_0x%0h", i));
        end

        // ------------------------------------------------------------
        // T2: known-vector spot checks from the project regression
        // ------------------------------------------------------------
        load_instr(4'h0, 8'h0F, 8'h03); exec_op;
        check(uo_out, 8'h12, "ADD 0F+03");

        load_instr(4'h1, 8'h0A, 8'h05); exec_op;
        check(uo_out, 8'h05, "SUB 0A-05");

        // ------------------------------------------------------------
        // T3: flags - 7F+01 -> O=1 N=1 ; FF+01 -> Z=1 C=1
        // ------------------------------------------------------------
        load_instr(4'h0, 8'h7F, 8'h01); exec_op;
        tests = tests + 1;
        if (uio_out[3] === 1'b1 && uio_out[2] === 1'b1)
            $display("PASS FLAGS OV+N");
        else begin
            errors = errors + 1;
            $display("FAIL FLAGS OV+N: uio_out=%02h", uio_out);
        end

        load_instr(4'h0, 8'hFF, 8'h01); exec_op;
        tests = tests + 1;
        if (uio_out[0] === 1'b1 && uio_out[1] === 1'b1)
            $display("PASS FLAGS Z+C");
        else begin
            errors = errors + 1;
            $display("FAIL FLAGS Z+C: uio_out=%02h", uio_out);
        end

        // ------------------------------------------------------------
        // T4: fault injection - stuck-at-1 on result bit 0
        // ------------------------------------------------------------
        uio_in = 8'h03; // enable=1, type=01 (SA1), bit=000
        #1;
        load_instr(4'h0, 8'h02, 8'h02); exec_op;
        check(uo_out, 8'h05, "FAULT SA1 bit0");
        uio_in = 8'h00;
        #1;

        // ------------------------------------------------------------
        // T5: fault-free BIST - done sticky, pass=1, MISR=0x93
        // ------------------------------------------------------------
        ui_in = 8'h80; // BIST_START
        @(posedge clk);
        ui_in = 8'h00;

        i = 0;
        while (!uio_out[4] && i < 700) begin
            @(posedge clk);
            i = i + 1;
        end

        tests = tests + 1;
        if (uio_out[4])          $display("PASS BIST DONE (%0d cycles)", i);
        else begin errors = errors + 1; $display("FAIL BIST timeout"); end

        @(posedge clk);
        #1;
        tests = tests + 1;
        if (uio_out[4])          $display("PASS BIST DONE sticky (pin-level)");
        else begin errors = errors + 1; $display("FAIL BIST DONE not sticky"); end

        tests = tests + 1;
        if (uio_out[5])          $display("PASS BIST PASS=1");
        else begin errors = errors + 1; $display("FAIL BIST PASS=0"); end

        uio_in = 8'h40; // STATUS_SEL = 01 -> MISR
        #1;
        tests = tests + 1;
        if (uio_out === 8'h93)      $display("PASS MISR signature 93");
        else begin errors = errors + 1; $display("FAIL MISR=%02h", uio_out); end
        uio_in = 8'h00;
        #1;

        // ------------------------------------------------------------
        // T6: faulted BIST must fail and bump the fault counter
        // ------------------------------------------------------------
        rst_n = 0; uio_in = 8'h00;
        repeat (5) @(posedge clk);
        uio_in = 8'h81; // enable=1, type=00 (SA0), bit=111
        rst_n = 1;
        repeat (3) @(posedge clk);

        ui_in = 8'h80;
        @(posedge clk);
        ui_in = 8'h00;

        i = 0;
        while (!uio_out[4] && i < 700) begin
            @(posedge clk);
            i = i + 1;
        end
        @(posedge clk);
        #1;

        tests = tests + 1;
        if (!uio_out[5])         $display("PASS FAULTED BIST detected");
        else begin errors = errors + 1; $display("FAIL FAULTED BIST passed"); end

        uio_in = 8'h80; // STATUS_SEL = 10 -> fault counter
        #1;
        tests = tests + 1;
        if (uio_out >= 1)           $display("PASS FAULT COUNTER=%0d", uio_out);
        else begin errors = errors + 1; $display("FAIL FAULT COUNTER=0"); end
        uio_in = 8'h00;
        #1;

        // ------------------------------------------------------------
        // Summary
        // ------------------------------------------------------------
        $display("=========================================");
        if (errors == 0)
            $display("RESULT: ALL %0d CHECKS PASSED", tests);
        else
            $display("RESULT: %0d/%0d CHECKS FAILED", errors, tests);
        $display("=========================================");
        $finish;
    end

endmodule
