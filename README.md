# Traffic Light Controller with Emergency Override (Verilog FSM)

A Moore FSM-based traffic light controller in Verilog, built with an emphasis on real-hardware reliability rather than just a textbook state machine. Alongside the standard Green–Yellow–Red cycle, it handles an asynchronous emergency input safely and recovers cleanly once the override is released.

---

## Why This Design

A simple traffic light FSM is easy to model, but a few practical issues come up the moment you think about real hardware:

- An external "emergency" signal (e.g., from an ambulance sensor) is asynchronous to the clock, so sampling it directly risks metastability.
- Suddenly releasing an emergency override straight back into a green light is a real safety hazard.
- Fixed-cycle timers can misbehave if counters glitch or overflow.

This design addresses each of these directly rather than assuming an idealized input.

---

## Key Features

**Two-stage synchronizer for the emergency input**
The `emergency` signal passes through two flip-flop stages (`em_sync1`, `em_sync2`) before being used anywhere in the FSM logic, reducing the risk of metastability from an asynchronous input.

**Fail-safe recovery after emergency override**
Releasing the emergency input doesn't jump straight back to green — the FSM forces an all-red clearance phase first, then resumes normal cycling, avoiding an abrupt return to traffic flow.

**Robust timer comparisons**
State transitions use `>=` rather than `==` when checking timer counts, so the FSM can't get stuck waiting for an exact value it might skip past due to a timing glitch.

**Fully parametrized timing**
Green, Yellow, and Clearance durations are Verilog parameters (`GREEN_TIME`, `YELLOW_TIME`, `CLEARANCE_TIME`), so timing can be retuned without touching the RTL itself.

---

## Technical Specifications

| Item | Detail |
|---|---|
| Language | Verilog HDL |
| Simulation & Synthesis | Xilinx Vivado |
| FSM Type | Moore Machine (outputs depend only on current state) |
| Verification | Testbench with continuous assertions monitoring safety violations and invalid state encodings |

---

## Verification Approach

The testbench doesn't just check a few expected outputs — it runs continuous assertions alongside the main test sequence:

- **Safety assertion**: flags any cycle where both North-South and East-West lights are simultaneously non-red
- **Encoding assertion**: flags any output that doesn't match a valid Red/Yellow/Green encoding

Test scenarios covered include: reset behavior, multiple normal FSM cycles, a mid-cycle reset, and a full emergency-override-and-recovery sequence.

---

## Project Files

| File | Description |
|---|---|
| `traffic_lc.v` | Main FSM design with synchronizer and parametrized timing |
| `traffic_tb.v` | Testbench with continuous safety/encoding assertions |
| `schematic_of_traffic_light_controller.png` | RTL schematic from synthesis |
| `waveform_simulation_of_traffic_light_controller.png` | Simulation waveform |

---

## Author

**Chhavi Verma**
