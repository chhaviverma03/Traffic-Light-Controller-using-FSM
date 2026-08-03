`timescale 1ns / 1ps


module traffic_tb();

    // ---- DUT signals ----
    reg        clk;
    reg        reset;
    reg        emergency;
    wire [2:0] light_NS;
    wire [2:0] light_EW;

    // ---- Light decode constants ----
    localparam RED    = 3'b100;
    localparam YELLOW = 3'b010;
    localparam GREEN  = 3'b001;

    // ---- Error counter ----
    integer error_count = 0;

    // ---- Instantiate DUT (Final Parametrized Version) ----
    traffic_lc #(
        .GREEN_TIME     (5),
        .YELLOW_TIME    (2),
        .CLEARANCE_TIME (1),
        .TIMER_WIDTH    (5)
    ) uut (
        .clk       (clk),
        .reset     (reset),
        .emergency (emergency),
        .light_NS  (light_NS),
        .light_EW  (light_EW)
    );

    // ---- Clock Generation (10ns period) ----
    initial clk = 0;
    always #5 clk = ~clk;

    // ============================================================
    // CONTINUOUS ASSERTIONS (Safety Monitoring)
    // ============================================================
    
    // Assertion 1: Safety Check (NS and EW never both non-RED)
    always @(posedge clk) begin
        if (!reset) begin
            if (light_NS !== RED && light_EW !== RED) begin
                $display("SAFETY VIOLATION at %0t ns | NS=%b EW=%b", $time, light_NS, light_EW);
                error_count = error_count + 1;
            end
        end
    end

    // Assertion 2: Invalid State Check (Encoding verification)
    always @(posedge clk) begin
        if (!reset) begin
            if ((light_NS !== RED && light_NS !== YELLOW && light_NS !== GREEN) ||
                (light_EW !== RED && light_EW !== YELLOW && light_EW !== GREEN)) begin
                $display("INVALID ENCODING at %0t ns", $time);
                error_count = error_count + 1;
            end
        end
    end

    // ============================================================
    // MAIN TEST STIMULUS
    // ============================================================
    initial begin
        $dumpfile("traffic_final_lokesh.vcd");
        $dumpvars(0, traffic_tb);

        emergency = 0;
        
        // ---- TEST 1: Initial Reset ----
        $display("\n=== TEST 1: Reset Behavior ===");
        reset = 1;
        #20 reset = 0;
        @(negedge clk);
        if (light_NS !== GREEN || light_EW !== RED) begin
            $display(" T1 FAIL: Expected NS=GREEN EW=RED");
            error_count = error_count + 1;
        end else $display("T1 PASS: Reset Successful");

        // ---- TEST 2: Normal Operation (2 Cycles) ----
        $display("\n=== TEST 2: Normal Operation (Check Waveforms) ===");
        #440; // Approx 2 full FSM cycles
        $display(" T2: Normal cycles completed.");

        // ---- TEST 3: Mid-Cycle Reset ----
        $display("\n=== TEST 3: Mid-Cycle Reset ===");
        #30; reset = 1; #10; reset = 0;
        @(negedge clk);
        if (light_NS !== GREEN) begin
            $display(" T3 FAIL: Did not return to NS_GREEN");
            error_count = error_count + 1;
        end else $display("T3 PASS: Mid-cycle reset handled");

        // ---- TEST 4: Emergency Handling (Synchronized) ----
        $display("\n=== TEST 4: Emergency Input & Recovery ===");
        #50;
        @(negedge clk); emergency = 1;
        // Wait 2 cycles for Synchronizer stages
        @(posedge clk); @(posedge clk); 
        #5; // small offset
        if (light_NS !== RED || light_EW !== RED) begin
            $display(" T4 FAIL: Emergency did not trigger All-Red");
            error_count = error_count + 1;
        end else $display(" T4 PASS: Emergency All-Red active");

        // Release Emergency and check recovery
        @(negedge clk); emergency = 0;
        #30; // Wait for safety clearance return
        if (light_NS !== GREEN) begin
            $display(" T4b FAIL: Recovery to NS_GREEN failed");
            error_count = error_count + 1;
        end else $display(" T4b PASS: Recovery Successful");

        // ---- FINAL REPORT ----
        #100;
        $display("\n========================================");
        $display("  FINAL REPORT FOR LOKESH");
        if (error_count == 0)
            $display(" ALL TESTS PASSED SUCCESSFULLY");
        else
            $display("  %0d ERRORS FOUND IN DESIGN", error_count);
        $display("========================================\n");
        $finish;
    end

endmodule
