Advanced Traffic Light Controller

🚀Project Overview

This project implements an industry-standard Traffic Light Controller using a Moore Finite State Machine (FSM). Designed for high reliability, it features advanced synchronization for asynchronous inputs and a multi-stage safety clearance protocol.

🛠️ Key Features2-Stage Synchronizer:

Integrated a Dual-Flip-Flop synchronizer for the Emergency input to eliminate Metastability and ensure stable state transitions in real hardware.

Fail-Safe Recovery: Implemented an automated safety buffer that forces an All-Red Clearance Phase immediately after an Emergency Override is released, preventing sudden traffic flow.

Robust Timer Logic: Utilized >= comparison operators for state transitions to prevent FSM Deadlocks in case of timing glitches or counter overflows.

Parametrized Architecture: Timing for Green ($5$ cycles), Yellow ($2$ cycles), and Red ($1$ cycle) is fully configurable via Verilog parameters without re-writing the RTL.


📊 Technical SpecificationsLanguage:

Verilog HDLSimulation & Synthesis: Xilinx Vivado 

FSM Type: Moore Machine (Output synchronous to current state)

Verification: Exhaustive Testbench with Continuous Assertions to monitor safety violations.
