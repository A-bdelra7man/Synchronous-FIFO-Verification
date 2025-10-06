🚀 Synchronous FIFO Verification Project

A complete SystemVerilog verification environment for a parameterized Synchronous FIFO, implemented with OOP-based constrained-random testing, functional coverage, and SystemVerilog Assertions (SVA).
Project completed under the guidance of Eng. Kareem Waseem.

🔧 Project Overview

This project verifies a parameterized Synchronous FIFO design using a modular SystemVerilog testbench.
The verification environment achieves 100% code, functional, and assertion coverage, and identifies multiple design bugs fixed during the process.

🧱 Features

Object-Oriented SystemVerilog Testbench (Transaction, Scoreboard, Coverage, and Monitor classes)

Constrained-Random Testing with Weighted Distributions (70% write, 30% read)

Functional Coverage with 7 Cross-Coverage Groups

13+ SystemVerilog Assertions (SVA) for flags, thresholds, and wraparound checks

Modular Interface with DUT, Testbench, and Monitor connections

Complete Verification Plan covering 12 design requirements

QuestaSim Simulation and Waveform Analysis

🐛 Key RTL Bugs Detected & Fixed

Missing reset for wr_ack and overflow

Incorrect almostfull and underflow logic

Missing simultaneous read/write handling

Converted combinational underflow to registered logic

Pointer threshold and wraparound behavior corrections

📈 Coverage Results

Code Coverage: 100% (Statement, Branch, Toggle)

Functional Coverage: 100%

Assertion Coverage: 100%

Assertion Failures: 0

🧰 Tools & Technologies

Language: SystemVerilog

Simulator: QuestaSim

Methodology: UVM-style (OOP classes for verification components)

📂 Repository Structure
design/          → RTL design files ( FIFO with SVA)
tb/              → Testbench, scoreboard, coverage, monitor, interface
scripts/         → Simulation .do files
reports/         → Coverage 
docs/            → PDF documentation and verification plan

📊 Deliverables

Complete Verification Environment (SystemVerilog files)

Bug Report (Before/After Fixes)

Coverage Reports (Code / Functional / Assertion)

Verification Plan

👨‍💻 Author

Abdelrahman Mahmoud
