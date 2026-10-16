`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.10.2026 04:28:54
// Design Name: 
// Module Name: traffic_tb
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


module traffic_tb();
reg clk=0;
reg rst;
reg emergency;
wire [2:0]light_NS,light_EW;


//----Light constants decode------
localparam RED=3'b100;
localparam YELLOW=3'b010;
localparam GREEN=3'b001;

integer error_count=0;

traffic_lc#(5,2,1,5) dut(clk,rst,emergency,light_NS,light_EW);

always #5 clk=~clk;

//safety monitoring test
//1.NO TWO LIGHT SHOULD BE NON RED AT ONCE
always@(posedge clk)begin
if(!rst)begin
 if(light_NS!==RED && light_EW!==RED)begin
   $display("SAFETY VILATION AT %0t ns ,NS=%b,EW=%b",$time,light_NS,light_EW);
   error_count=error_count+1'b1;
   end
 end
end

//2.INVALID ENCODING OF STATES
always@(posedge clk)begin
if(!rst)begin
  if((light_NS!==GREEN && light_NS!==YELLOW && light_NS!==RED)||
     (light_NS!==GREEN && light_NS!==YELLOW && light_NS!==RED))begin
     $display("INVALID ENCODING AT %0t",$time);
     error_count=error_count+1'b1;
     end
   end
 end
 
 //===============================================
 //MAIN TEST STIMULAS
 //===============================================
 initial begin
 $dumpfile("dump.vcd");
 $dumpvars(0,traffic_tb);
 
 emergency=0;
 
 //T1:RESET BEHAVIOUR 
 $display("-----------------------------");
 $display("T1:RESET BEHAVIOUR TEST");
 rst=1;
 #20;
 rst=0;
@(negedge clk)
if(light_NS!==GREEN || light_EW!==RED)begin
  $display("T1:Failed:RESET DID NOT WORK | Expected NS=GREEN ,EW=RED");
  error_count=error_count+1'b1;
  end
else
  $display("T1:Passed :RESET SUCCESSFULL");
 $display("-----------------------------");  
 
 //T2:NORMAL OPERATIONS
 $display("T2:NORMAL OPERATION ");
 #440;
 $display("T2:NORMAL OPERATION COMPLETED");
  $display("-----------------------------");
 
 //T3:MID CYCLE RESET(WHILE EW=GREEN AND NS=RED SO RESULT SHOULD BE REVERTED)
  $display("T3:MID CYCLE RESET");
  wait(light_EW===GREEN);
  #20;
  if(light_EW!==GREEN)begin
   $display("T3 SETUP ERROR:FSM was not in EW_GREEN before reset");
   error_count=error_count+1'b1;
   end
 //T3:MID-CYCLE RESET
 @(negedge clk);
 rst=1;
 #10;
 rst=0;
 @(negedge clk)
 if(light_NS!==GREEN||light_EW!==RED)begin
   $display("T3:Failed:MID CYCLE RESET FAILED:STATE DID NOT RETUN TO GREEN");
   error_count=error_count+1'b1;
 end
 else 
   $display("T3:Passed:MID CYCLE RESET DONE");
$display("-----------------------------");

 //T4:EMERGENCY AND INPUT RECOVERY
 $display("T4:EMERGENCY AND INPUT RECOVERY");
 #50;
 //T4(a):EMERGENCY
 @(negedge clk); emergency=1;
 //2 cycles wait for synchronization
 @(posedge clk);@(posedge clk);
 #25;
 if(light_NS!==RED || light_EW!==RED)begin
   $display("T4(a):Failed:EMERGENCY DID NOT TRIGGER ALL-RED");
   error_count=error_count+1'b1;
 end
 else
   $display("T4(a):Passed:EMERGENCY TRIGGERED ALL RED");
  
 //T4(b):RECOVERY INPUT
 @(negedge clk);
 emergency=0;
 #50;
 if(light_NS!==GREEN || light_EW!=RED)begin 
   $display("T4(b):Failed:DID NOT RETURN TO NS_GREEN AFTER EMERGENCY=0");
   error_count=error_count+1'b1;
  end
  else
   $display("T4(B):Passed:RETUNRED TO GREEN");
   
   $display("================================");
   $display("FINAL REPORT:-");
   if(error_count==0)
     $display("ALL TEST PASSED");
   else
     $display("%0d ERROR FOUND IN DESIGN",error_count);
   $display("================================");   
     
  end
  endmodule
