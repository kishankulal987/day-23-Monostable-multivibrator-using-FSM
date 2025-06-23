# Monostable Multivibrator in Verilog

## Overview

In this project, I implemented a monostable multivibrator (one-shot circuit) in Verilog using a finite state machine. My goal was to create a circuit that generates a single output pulse of fixed duration (3 clock cycles) when triggered by a rising edge on the input signal, with debouncing to handle noisy inputs. For example, when the input din transitions from 0 to 1, the output dout goes high for 3 clock cycles, then returns low, ignoring further input changes during the pulse and waiting for the input to return low before allowing another trigger. I used a state machine with four states (idle, debounce, pulse, wait_for) and counters for debouncing and pulse duration, and wrote a testbench to verify the functionality with various input scenarios. I confirmed the design works as expected through simulation.

Module: monostable





What I Did: I designed a monostable multivibrator to produce a fixed-duration output pulse on a rising input edge.



Inputs:





clk: Clock signal.



din: Input trigger signal.



reset: Asynchronous reset signal.



Outputs:





dout: Output pulse signal (high during the pulse state).



How It Works:





I implemented a finite state machine with four states:





idle (00): Waits for a rising edge on din (din=1 and prev_in=0).



debounce (10): Ensures the input is stable for 1 clock cycle (dcounter>=1).



pulse (01): Generates the output pulse for 3 clock cycles (delay_counter>=3).



wait_for (11): Waits for din to return to 0 before re-entering idle.



State Logic:





Two always blocks handle state transitions and counter updates on the positive clock edge or reset.



prev_in stores the previous value of din to detect rising edges.



delay_counter increments in the pulse state to control pulse duration (resets to 0 otherwise).



dcounter increments in the debounce state when din=1 (resets on reset or rising edge).



A combinational always block determines next_state based on current_state, din, delay_counter, and dcounter.



Output: dout = 1 when current_state == pulse, else dout = 0.



On reset, current_state, prev_in, and counters are cleared.



Style: Behavioral modeling with a finite state machine and sequential/combinational logic.

Testbench: testbench





What I Did: I created a testbench to verify the monostable multivibrator’s behavior under various input conditions.



How It Works:





I generated a clock with a 10ns period (#5 clk = ~clk).



I tested four scenarios:





Single pulse: din goes high for 50ns, triggering one pulse.



Held high: din stays high for 100ns, ensuring only one pulse.



Rapid toggling: din toggles quickly (1 for 20ns, 0 for 10ns, 1 for 50ns), testing debouncing.



Reset during pulse: din triggers a pulse, then reset is asserted, testing reset behavior.



I used $monitor to display time, reset, din, dout, current_state, delay_counter, and dcounter whenever they change.



The simulation runs for a total of 468ns, ending with $finish.



Time Scale: I set 1ns / 1ps for precise simulation timing.



Purpose: My testbench ensures the circuit correctly generates a single pulse, debounces noisy inputs, and handles reset conditions.

Files





monostable.v: Verilog module for the monostable multivibrator.



testbench.v: Testbench for simulation.

# Circuit Diagram

Below is a conceptual diagram for the monostable multivibrator’s state machine and logic flow.


![Screenshot 2025-06-23 192406](https://github.com/user-attachments/assets/1a537188-3af4-480a-93e8-f08e7907bad0)


# Simulation Waveform

Below is the simulation waveform, showing inputs clk, din, reset, and outputs dout, current_state, delay_counter, and dcounter over time.

![Screenshot 2025-06-23 191837](https://github.com/user-attachments/assets/c213d7fb-d48b-4a82-bc39-b5c103f6ca0a)


# Console Output

Below is the console output from my testbench simulation.

![Uploading Screenshot 2025-06-23 192151.png…]()






Time=0 ns reset=1 din=0 dout=0 state=00 delay_counter=0 dcounter=0



Time=13 ns reset=0 din=0 dout=0 state=00 delay_counter=0 dcounter=0



Time=18 ns reset=0 din=1 dout=0 state=10 delay_counter=0 dcounter=0



Time=20 ns reset=0 din=1 dout=0 state=10 delay_counter=0 dcounter=1



Time=30 ns reset=0 din=1 dout=1 state=01 delay_counter=0 dcounter=0



Time=40 ns reset=0 din=1 dout=1 state=01 delay_counter=1 dcounter=0



Time=50 ns reset=0 din=1 dout=1 state=01 delay_counter=2 dcounter=0



Time=60 ns reset=0 din=1 dout=0 state=11 delay_counter=3 dcounter=0



Time=68 ns reset=0 din=0 dout=0 state=00 delay_counter=0 dcounter=0



... (continues for held high, rapid toggling, and reset during pulse scenarios)
