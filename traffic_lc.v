`timescale 1ns / 1ps

// ============================================================
// Features: Dual-FF Synchronizer, Parametrized Timing, Moore FSM
// ============================================================

module traffic_lc #(
    parameter GREEN_TIME     = 5,   
    parameter YELLOW_TIME    = 2,   
    parameter CLEARANCE_TIME = 1,   
    parameter TIMER_WIDTH    = 5    
)(
    input  wire clk,
    input  wire reset,
    input  wire emergency,
    output reg [2:0] light_NS, // [Red, Yellow, Green]
    output reg [2:0] light_EW
);

// ---- Light Constants ----
localparam RED    = 3'b100;
localparam YELLOW = 3'b010;
localparam GREEN  = 3'b001;

// ---- State Encoding ----
localparam [2:0]
    NS_GREEN  = 3'b000,
    NS_YELLOW = 3'b001,
    ALL_RED1  = 3'b010,
    EW_GREEN  = 3'b011,
    EW_YELLOW = 3'b100,
    ALL_RED2  = 3'b101,
    EMERGENCY_ST = 3'b110;

reg [2:0] current_state, next_state;
reg [TIMER_WIDTH-1:0] timer;
reg em_sync1, em_sync2; // Synchronizer Stages

// 1. INPUT SYNCHRONIZATION (Prevents Metastability)
always @(posedge clk or posedge reset) begin
    if (reset) begin
        em_sync1 <= 1'b0;
        em_sync2 <= 1'b0;
    end else begin
        em_sync1 <= emergency;
        em_sync2 <= em_sync1;
    end
end

// 2. STATE REGISTER (Sequential)
always @(posedge clk or posedge reset) begin
    if (reset) begin
        current_state <= NS_GREEN;
        timer         <= 0;
    end else if (em_sync2) begin
        current_state <= EMERGENCY_ST;
        timer         <= 0;
    end else begin
        case (current_state)
            NS_GREEN, EW_GREEN: 
                if (timer >= GREEN_TIME) begin current_state <= next_state; timer <= 0; end 
                else timer <= timer + 1;
            NS_YELLOW, EW_YELLOW: 
                if (timer >= YELLOW_TIME) begin current_state <= next_state; timer <= 0; end 
                else timer <= timer + 1;
            ALL_RED1, ALL_RED2: 
                if (timer >= CLEARANCE_TIME) begin current_state <= next_state; timer <= 0; end 
                else timer <= timer + 1;
            EMERGENCY_ST: 
                if (!em_sync2) begin current_state <= ALL_RED2; timer <= 0; end
            default: begin current_state <= NS_GREEN; timer <= 0; end
        endcase
    end
end

// 3. NEXT STATE LOGIC (Combinational)
always @(*) begin
    case (current_state)
        NS_GREEN  : next_state = NS_YELLOW;
        NS_YELLOW : next_state = ALL_RED1;
        ALL_RED1  : next_state = EW_GREEN;
        EW_GREEN  : next_state = EW_YELLOW;
        EW_YELLOW : next_state = ALL_RED2;
        ALL_RED2  : next_state = NS_GREEN;
        EMERGENCY_ST: next_state = ALL_RED2;
        default   : next_state = NS_GREEN;
    endcase
end

// 4. OUTPUT LOGIC (Moore Machine)
always @(*) begin
    case (current_state)
        NS_GREEN  : begin light_NS = GREEN;  light_EW = RED;    end
        NS_YELLOW : begin light_NS = YELLOW; light_EW = RED;    end
        EW_GREEN  : begin light_NS = RED;    light_EW = GREEN;  end
        EW_YELLOW : begin light_NS = RED;    light_EW = YELLOW; end
        default   : begin light_NS = RED;    light_EW = RED;    end
    endcase
end

endmodule
