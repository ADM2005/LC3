# LC-3 SystemVerilog Implementation

A synthesizable, multi-cycle implementation of the LC-3 instruction set architecture in SystemVerilog, accompanied by a hand-written two-pass assembler in Python. The design implements the full LC-3 data-processing, memory-access, and control-flow instruction classes over a shared, tri-state external bus, with correctness treated as a first-class design constraint throughout.

> **Scope note:** this implementation deliberately excludes `TRAP`/`RTI` and interrupt/exception handling. Everything else in the base ISA — `ADD`, `AND`, `NOT`, `LD`, `LDR`, `LDI`, `LEA`, `ST`, `STR`, `STI`, `BR`, and `JMP` — is implemented and verified.

---

## Architecture Overview

This is a **multi-cycle, FSM-driven** processor rather than a single-cycle or pipelined design: each instruction moves through a variable number of clock cycles depending on its class, and a centralized control unit (`State.sv`) sequences the datapath one micro-operation at a time. This mirrors the classic LC-3 educational architecture (as opposed to a performance-oriented pipeline), prioritizing a clean separation between **control** and **datapath** that makes the design easy to reason about, verify, and extend.

### Control unit (`State.sv` / `State_pkg.sv`)

An 11-state Moore-ish FSM (`UPDATE_PC → FETCH → DECODE → {ALU | TARGET_PC | MEMORY_ADDR} → ... → WRITE_REGISTER/UPDATE_PC`) drives every enable signal in the datapath. State transitions branch on the decoded instruction class (`cCtrl_t`: ALU / memory / control) and, for memory-class instructions, further branch on access type (direct read, direct write, indirect read, indirect write). Any transition that touches external memory stalls in place until `eREADY` is asserted by the memory interface — the FSM is explicitly designed to tolerate a variable-latency memory, not just a fixed one. An `ILLEGAL` sink state catches undecodable opcodes and is also used by the testbench as a natural simulation-termination condition.

### Fetch / Decode / Execute

- **Fetch** drives the program counter onto the external address bus as a read request.
- **Decode** (`Decode.sv` + `Decode_pkg.sv`) is a purely combinational opcode decoder that derives register IDs, sign-extended immediates/offsets, ALU operation selects, destination-mux selects, and the control-unit's instruction-class tag from the fetched instruction word — plus the branch-taken condition, computed directly from the condition codes (`psr`) and the instruction's `n/z/p` bits.
- **Registers** (`Registers.sv`) is an 8×16-bit register file that also derives the 3-bit condition-code register (`psr`: N/Z/P) as a side effect of every register write, matching the LC-3's "every ALU/load writeback sets NZP" semantics.
- **ALU** (`ALU.sv`) implements `ADD`/`ADD-immediate`/`AND`/`AND-immediate`/`NOT` with 5-bit sign-extended immediates.
- **Address** (`Address.sv`) computes the second addressing mode needed by every memory and control-flow instruction: PC-relative (`PC + SEXT(offset9)`) or base+offset (`SR1 + SEXT(offset6)`), selected by `aOp` — this single adder is reused for `LD/LDI/LEA/ST/STI/BR` (PC-relative) and `LDR/STR/JMP` (base+offset).
- **DrMux** selects what gets written back to the register file: ALU output, computed address (for `LEA`), or memory read data (for loads).
- **UpdatePC** is a simple PC register that either increments (`PC+1`) or loads a computed target (for taken branches and `JMP`), gated by the FSM.

### Memory interface & bus arbitration

- **MemoryIF** (`MemoryIF.sv`) turns the 3-bit `mOp` control word (enable / read-write / direct-indirect) into a bus request, handling all four memory access shapes required by the ISA: direct read, direct write, indirect read (pointer dereference for `LDI`), and indirect write (`STI`).
- **BusDriver** (`BusDriver.sv`) arbitrates the single shared, tri-stated external bus (`eADDR`/`eWEA`) between the Fetch stage and the Memory stage, since both can independently need to talk to memory within an instruction's lifetime (fetch the instruction, then possibly fetch/store data).
- **MemoryModel** (`MemoryModel.sv`, testbench-only) models a **non-deterministic-latency** memory: each request incurs a randomized wait (`$urandom % 10` cycles) before `eREADY` is asserted. This is a deliberate choice — it forces the control FSM to be correct under variable memory latency rather than implicitly assuming a fixed-cycle memory, closer to how a real cache/DRAM interface behaves. The model also supports loading a structured binary memory image (a sequence of `{start, size, words...}` blocks) at simulation start, matching the assembler's output format.

### Top-level integration (`LC3.sv`)

Wires all of the above into a single `LC3` module exposing only the external memory-facing signals (`eDIN`, `eDOUT`, `eADDR`, `eWEA`, `eREADY`) plus `clk`/`reset` — the entire multi-cycle core is a black box from outside, which keeps the testbench and any future memory subsystem (cache, MMU, etc.) cleanly decoupled from the CPU core.

---

## Toolchain: the assembler (`assembler.py`)

A two-pass assembler, written from scratch, that turns LC-3 assembly into the binary memory-image format consumed by `MemoryModel`:

1. **Pass 1** iterates through the assembly lines and classifies them into instructions, assembler directives, or label definitions. Once identified, these are validated to ensure correct syntax. A symbol table is also built up, a dictionary mapping labels to memory locations.
2. **Pass 2** outputs the program as raw binary, and converts the arguments in each instruction into data to be written.

The output format of the assembler is as follows:
1. 16-bit unsigned word for the number of contiguous blocks
2. A list of pairs of 16-bit unsigned words for the memory block start address and their sizes respectively
3. The instructions/data listed in binary.

Supported mnemonics mirror the hardware exactly: `add`, `and`, `not`, `ld`, `ldr`, `ldi`, `lea`, `st`, `str`, `sti`, the branch variants (`brn`/`brz`/`brp`/`brnz`/`brzp`/`brnp`/`brnzp`), `jmp`, plus `org`/`defw` assembler directives. (`halt` is reserved in the opcode table for future trap support — see below.)

---

## Verification

`tb_lc3_testbench.sv` instantiates the CPU against `MemoryModel`, loads a compiled program (`a.out`), releases reset, and free-runs the clock until the control FSM lands in `ILLEGAL` (a clean, self-checking termination condition rather than a fixed cycle count) or a 1000-cycle watchdog fires. Because `MemoryModel` injects randomized per-access latency, this also functions as a lightweight stress test of the FSM's memory-wait logic on every run, rather than validating a single fixed-timing assumption.

---

## TODO

### Correctness / ISA completeness
- [ ] **`TRAP` / `RTI` support** — implement the trap vector table (memory-mapped at `x0000`–`x00FF`), the `TRAP` instruction's `PC → R7`, `PC ← MEM[ZEXT(trapvect8)]` sequence, and `RTI`'s privilege/PC/PSR restore. `OP_HALT` is already reserved in `Decode_pkg` but currently unimplemented — this is the natural place to route it through `TRAP x25`.
- [ ] **Interrupt/exception handling** — privilege mode, priority levels, and the supervisor/user stack switch that real trap handling depends on (currently `psr` only tracks condition codes, not privilege/priority).
- [ ] **`JSR`/`JSRR`** — subroutine call instructions are absent from both the decoder and the assembler; needed for a functionally complete LC-3.

### Performance
- [ ] **Pipelining** — the current multi-cycle FSM serializes fetch/decode/execute/memory/writeback even for register-only ALU ops. A classic 5-stage LC-3 pipeline (with hazard detection for RAW register dependencies and control-flow flushes on taken branches/`JMP`) would substantially cut effective CPI.
- [ ] **Branch prediction** — even a simple static/backward-taken predictor would reduce the `TARGET_PC`/`UPDATE_PC` round-trip cost once pipelined.
- [ ] **Multi-level cache hierarchy** — `MemoryModel`'s randomized latency stands in for real DRAM cost; a small direct-mapped or set-associative L1 (split I/D or unified) in front of it, backed by the existing bus protocol, would be the natural next step, with an L2 justified once the pipeline is deep enough to hide L1 misses.
- [ ] **Bus/memory pipelining** — `BusDriver` currently arbitrates Fetch vs. Memory strictly (one owns the bus at a time); overlapping the next fetch with the current instruction's data access (where no structural hazard exists) would help once instructions aren't fully serialized by the FSM.
- [ ] **Store buffering** — decouple `WRITE_MEMORY` completion from the FSM's ability to move on to the next instruction's fetch, once pipelined.

### Toolchain / verification
- [ ] **Assembler: `JSR`/`JSRR`/`TRAP` mnemonics** (including the standard trap aliases `GETC`/`OUT`/`PUTS`/`IN`/`HALT`) — blocked on the hardware TODOs above.
- [ ] **Directed test suite** — the current testbench runs a single program to completion; a regression suite exercising each addressing mode, each branch condition combination, and edge cases (register `R7`/`PC` interactions, sign-extension boundaries, indirect-through-indirect edge cases) would catch regressions as the pipeline work lands.
