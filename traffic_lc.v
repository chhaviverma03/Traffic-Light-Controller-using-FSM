`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.10.2026 04:00:28
// Design Name: 
// Module Name: traffic_lc
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module traffic_lc #(
 parameter GREEN_TIME=5,
 parameter YELLOW_TIME=2,
 parameter CLEARANCE_TIME=1,
 parameter TIMER_WIDTH=5
 )(
 input wire clk,
 input wire rst,
 input wire emergency,
 output reg [2:0]light_NS,
 output reg [2:0]light_EW);
 
 //light constants
 localparam RED=3'b100;
 localparam YELLOW=3'b010;
 localparam GREEN=3'b001;
 
 //state encoding
 localparam [2:0]
 NS_GREEN=3'b000,
 NS_YELLOW=3'b001,
 ALL_RED1=3'b010,
 EW_GREEN=3'b011,
 EW_YELLOW=3'b100,
 ALL_RED2=3'b101,
 EMERGENCY_ST=3'b110;
 
 reg [TIMER_WIDTH-1:0]timer;
 reg[2:0]current_state,next_state;
 reg em_sync1,em_sync2;
 //synchronizer logic
 always@(posedge clk or posedge rst)begin
 if(rst)begin
   em_sync1<=1'b0;
   em_sync2<=1'b0;
 end
 else begin
   em_sync1<=emergency;
   em_sync2<=em_sync1;
  end
end
   
//state_registe code
always@(posedge clk or posedge rst)begin
if(rst)begin 
current_state<=NS_GREEN;
timer<=0;
end
else if(em_sync2)begin
  current_state<=EMERGENCY_ST;
  timer<=0;
  end
else begin
  case(current_state)
  NS_GREEN,EW_GREEN:begin 
                    if(timer>=GREEN_TIME)begin
                    current_state<=next_state;
                    timer<=0;
                    end
                    else 
                    timer<=timer+1'b1;
                    end
                    
   NS_YELLOW,EW_YELLOW:begin
                      if(timer>=YELLOW_TIME)begin
                      current_state<=next_state;
                      timer<=0;
                      end
                      else
                      timer<=timer+1'b1;
                      end
  ALL_RED1,ALL_RED2:begin
                    if(timer>=CLEARANCE_TIME)begin
                    current_state<=next_state;
                    timer<=0;
                    end
                    else
                    timer<=timer+1'b1;
                    end
                    
  EMERGENCY_ST:begin
               if(!em_sync2)begin
                 current_state<=ALL_RED2;
                 timer<=0;
                 end
                 end                                  
      default:begin current_state<=NS_GREEN;timer<=0;end
    endcase
   end
 end
 
 
 //next state logic 
 always@(*)begin
 case(current_state)
 NS_GREEN:next_state=NS_YELLOW;
 NS_YELLOW:next_state=ALL_RED1;
 ALL_RED1:next_state=EW_GREEN;
 EW_GREEN:next_state=EW_YELLOW;
 EW_YELLOW:next_state=ALL_RED2;
 ALL_RED2:next_state=NS_GREEN;
 EMERGENCY_ST:next_state=ALL_RED2;
 default:next_state=NS_GREEN;
 endcase
 end
 
 
 //output logic 
 always@(*)begin
 case(current_state)
 NS_GREEN: begin light_NS=GREEN;  light_EW=RED; end
 NS_YELLOW:begin light_NS=YELLOW; light_EW=RED; end
 EW_GREEN:begin  light_NS=RED;    light_EW=GREEN; end
 EW_YELLOW:begin light_NS=RED;    light_EW=YELLOW;end
 default:begin   light_NS=RED;    light_EW=RED; end
 endcase
 end
 endmodule
