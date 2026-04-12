# Comprehensive Hazard Analysis v2 — 5-Stage Pipelined RV32I

## Terminology

Consider three consecutive instructions in program order:

```
I1: add x1, x2, x3      ← Producer (oldest)
I2: sub x4, x1, x5      ← May be both producer AND consumer
I3: and x6, x1, x4      ← Consumer (youngest)
```

| Term | Meaning | Pipeline Timing | Forwarding Source |
|---|---|---|---|
| **I1-I2 hazard** | Adjacent instructions. No instructions between them. | I1 in **MEM**, I2 in **EX** | Forward from **EX/MEM** register |
| **I1-I3 hazard** | 1 instruction between them (I2 sits between). | I1 in **WB**, I3 in **EX** | Forward from **MEM/WB** register |
| **Priority** | I1 writes `x1`, I2 also writes `x1`, I3 reads `x1` | Both EX/MEM and MEM/WB match | **I2 wins** (most recent value) |

```
Pipeline timing when I3 is in EX:

Cycle:   1    2    3    4    5
I1:     [IF] [ID] [EX] [MEM][WB]  ← I1 in WB
I2:          [IF] [ID] [EX] [MEM] ← I2 in MEM
I3:               [IF] [ID] [EX]  ← I3 in EX (needs forwarded values NOW)
```

---

## Reference Tables

### Producers — Instructions that write to `rd`

| Producer | `resultsrc` | Correct value for `rd` | When available | What `ALUResult` contains |
|---|---|---|---|---|
| R-type (ADD, SUB, AND, OR, XOR, SLT) | `00` | ALUResult | End of EX | ✅ Correct computation |
| ADDI | `00` | ALUResult | End of EX | ✅ Correct computation |
| LW | `01` | MemReadData | End of MEM | ❌ Memory **address** (rs1+imm) |
| LUI | `11` | ImmExt | Available from ID | ❌ **Garbage** (don't-care ALU inputs) |
| JAL | `10` | PCPlus4 | Available from IF | ❌ **Garbage** (don't-care ALU inputs) |
| JALR | `10` | PCPlus4 | Available from IF | ❌ **Jump target** (rs1+imm), NOT the write-back value |

### Consumers — Instructions that read registers

| Consumer | Reads `rs1`? | Reads `rs2`? | What rs1 is used for | What rs2 is used for |
|---|---|---|---|---|
| R-type | ✅ | ✅ | ALU operand A | ALU operand B |
| ADDI | ✅ | ❌ | ALU operand A | — |
| LW | ✅ | ❌ | Base address | — |
| SW | ✅ | ✅ | Base address | **Store data** |
| BEQ | ✅ | ✅ | Comparison operand | Comparison operand |
| JALR | ✅ | ❌ | Jump target base | — |
| JAL | ❌ | ❌ | — | — |
| LUI | ❌ | ❌ | — | — |

> [!NOTE]
> JAL and LUI **cannot be consumers** — they don't read any registers. So they can never be the dependent instruction in a data hazard.

---

## I1-I2 HAZARDS (Adjacent Instructions)

**Timing**: I1 in MEM, I2 in EX. Forward from **EX/MEM pipeline register**.

### What value to forward?

The forwarding unit needs to send the value that I1 will ultimately write to `rd`. This depends on `resultsrc_M`:

```verilog
// "Result-aware" forwarding value from MEM stage
wire [31:0] forward_from_mem;
assign forward_from_mem = (resultsrc_M == 2'b00) ? aluresult_M :   // R-type, ADDI
                          (resultsrc_M == 2'b10) ? pcplus4_M   :   // JAL, JALR
                          (resultsrc_M == 2'b11) ? immext_M    :   // LUI
                                                   32'bx;          // LW → can't forward, STALL
```

### Complete I1-I2 Pair Analysis

#### Group A: R-type / ADDI as Producer (resultsrc = 00)

Forward `ALUResult_M` — the standard case, no complications.

| # | I1 (Producer) | I2 (Consumer) | Dependency | Resolution |
|---|---|---|---|---|
| A1 | R-type → | R-type (rs1 or rs2) | rs1/rs2 == rd_M | Forward `ALUResult_M` ✅ |
| A2 | R-type → | ADDI (rs1) | rs1 == rd_M | Forward `ALUResult_M` ✅ |
| A3 | R-type → | LW (rs1 = base) | rs1 == rd_M | Forward `ALUResult_M` ✅ |
| A4 | R-type → | SW (rs1 = addr) | rs1 == rd_M | Forward `ALUResult_M` ✅ |
| A5 | R-type → | SW (rs2 = data) | rs2 == rd_M | Forward `ALUResult_M` ✅ |
| A6 | R-type → | BEQ (rs1 or rs2) | rs1/rs2 == rd_M | Forward `ALUResult_M` ✅ |
| A7 | R-type → | JALR (rs1) | rs1 == rd_M | Forward `ALUResult_M` ✅ |
| A8 | ADDI → | any consumer | same as above | Forward `ALUResult_M` ✅ |

**Total: 8 cases, all handled by standard forwarding.** ✅

---

#### Group B: LW as Producer (resultsrc = 01) — LOAD-USE HAZARD

**Cannot forward**: Memory read data is not available until the END of MEM stage. By the time the data memory produces ReadData, I2 in EX has already consumed its ALU inputs.

| # | I1 (Producer) | I2 (Consumer) | Dependency | Resolution |
|---|---|---|---|---|
| B1 | LW → | R-type (rs1 or rs2) | rs1/rs2 == rd_M | **STALL 1 cycle** then forward from WB ⚠️ |
| B2 | LW → | ADDI (rs1) | rs1 == rd_M | **STALL 1 cycle** then forward from WB ⚠️ |
| B3 | LW → | LW (rs1 = base) | rs1 == rd_M | **STALL 1 cycle** then forward from WB ⚠️ |
| B4 | LW → | SW (rs1 = addr) | rs1 == rd_M | **STALL 1 cycle** then forward from WB ⚠️ |
| B5 | LW → | SW (rs2 = data) | rs2 == rd_M | **STALL 1 cycle** then forward from WB ⚠️ |
| B6 | LW → | BEQ (rs1 or rs2) | rs1/rs2 == rd_M | **STALL 1 cycle** then forward from WB ⚠️ |
| B7 | LW → | JALR (rs1) | rs1 == rd_M | **STALL 1 cycle** then forward from WB ⚠️ |

> [!WARNING]
> **B5 (LW → SW store data)**: Even though the store data isn't consumed until MEM stage (not EX), in our pipeline the forwarding mux is in EX stage. The store data (rs2) passes through the forwarding mux before being latched into the EX/MEM register as WriteData. So it still needs the correct value in EX. **Stall required.**

> [!NOTE]
> **After the 1-cycle stall**: The pipeline looks like this:
> ```
> Cycle:   1    2    3    4    5    6
> LW:     [IF] [ID] [EX] [MEM][WB]
> I2:          [IF] [ID] [ID] [EX] [MEM]  ← ID repeated (stall), then I1-I3 forward
>                    stall↗
> ```
> After the stall, LW is in WB, I2 is in EX → this becomes an **I1-I3 forward** from MEM/WB. `Result_W` = ReadData (correctly selected by result mux). ✅

**Total: 7 cases, all require load-use stall.** ⚠️

---

#### Group C: LUI as Producer (resultsrc = 11)

`ALUResult_M` is **garbage** for LUI (ALU inputs were don't-care). Must forward `ImmExt_M` instead.

| # | I1 (Producer) | I2 (Consumer) | Dependency | Resolution |
|---|---|---|---|---|
| C1 | LUI → | R-type (rs1 or rs2) | rs1/rs2 == rd_M | Forward `ImmExt_M` ✅ |
| C2 | LUI → | ADDI (rs1) | rs1 == rd_M | Forward `ImmExt_M` ✅ |
| C3 | LUI → | LW (rs1 = base) | rs1 == rd_M | Forward `ImmExt_M` ✅ |
| C4 | LUI → | SW (rs1 = addr) | rs1 == rd_M | Forward `ImmExt_M` ✅ |
| C5 | LUI → | SW (rs2 = data) | rs2 == rd_M | Forward `ImmExt_M` ✅ |
| C6 | LUI → | BEQ (rs1 or rs2) | rs1/rs2 == rd_M | Forward `ImmExt_M` ✅ |
| C7 | LUI → | JALR (rs1) | rs1 == rd_M | Forward `ImmExt_M` ✅ |

> [!IMPORTANT]
> If you forward raw `ALUResult_M` here (like a naive implementation), you get **silently wrong results**. No stall, no crash — just incorrect values propagated. This is a subtle bug.

**Total: 7 cases, all handled by result-aware forwarding.** ✅

---

#### Group D: JAL as Producer (resultsrc = 10)

JAL writes `PC+4` to `rd`. `ALUResult_M` is garbage. Must forward `PCPlus4_M`.

| # | I1 (Producer) | I2 (Consumer) | Dependency | Resolution |
|---|---|---|---|---|
| D1-D7 | JAL → | any consumer | rs1/rs2 == rd_M | Forward `PCPlus4_M` ✅ |

> [!NOTE]
> JAL is an unconditional jump. In practice, the instruction immediately after JAL (at PC+4) would be **flushed** by the control hazard mechanism. So this I1-I2 data hazard is often **moot** — the dependent I2 gets squashed.
>
> However, for correctness, the forwarding logic must still handle it (in case the flush mechanism is delayed or the consumer enters the pipeline before the flush takes effect).

**Total: 7 cases, handled by result-aware forwarding (but usually moot due to flush).** ✅

---

#### Group E: JALR as Producer (resultsrc = 10)

JALR writes `PC+4` to `rd`. `ALUResult_M` = `rs1 + imm` (the **jump target**, NOT the writeback value). Must forward `PCPlus4_M`.

| # | I1 (Producer) | I2 (Consumer) | Dependency | Resolution |
|---|---|---|---|---|
| E1-E7 | JALR → | any consumer | rs1/rs2 == rd_M | Forward `PCPlus4_M` ✅ |

> [!WARNING]
> **The JALR subtlety**: Unlike LUI and JAL (where ALUResult is just garbage), JALR's `ALUResult_M` is a **valid but wrong** value — it's the jump target address. If forwarded naively, the consumer gets a memory address instead of the return address. This is even harder to debug than the LUI case.

Same note as JAL: usually moot due to control hazard flush, but forwarding must be correct.

**Total: 7 cases, handled by result-aware forwarding.** ✅

---

## I1-I3 HAZARDS (1 Instruction Between)

**Timing**: I1 in WB, I3 in EX. Forward from **MEM/WB pipeline register**.

### What value to forward?

The MEM/WB register contains the output of the **result mux** (`Result_W`), which correctly selects:
- `ALUResult_W` for R-type/ADDI (resultsrc=00)
- `ReadData_W` for LW (resultsrc=01)
- `PCPlus4_W` for JAL/JALR (resultsrc=10)
- `ImmExt_W` for LUI (resultsrc=11)

So `Result_W` is **always the correct value** — no special cases!

### Complete I1-I3 Pair Analysis

#### Group F: Any Producer → Any Consumer (2-instruction gap)

| # | I1 (Producer) | Middle I2 | I3 (Consumer) | Resolution |
|---|---|---|---|---|
| F1 | R-type/ADDI | any | any consumer (rs1/rs2 == rd_W) | Forward `Result_W` ✅ |
| F2 | **LW** | any | any consumer (rs1/rs2 == rd_W) | Forward `Result_W` ✅ **No stall needed!** |
| F3 | LUI | any | any consumer (rs1/rs2 == rd_W) | Forward `Result_W` ✅ |
| F4 | JAL | any | any consumer (rs1/rs2 == rd_W) | Forward `Result_W` ✅ |
| F5 | JALR | any | any consumer (rs1/rs2 == rd_W) | Forward `Result_W` ✅ |

> [!TIP]
> **Key difference from I1-I2**: LW with a 1-instruction-between gap does NOT need a stall. By the time I3 is in EX, I1 (LW) is in WB, and the loaded data has already passed through the result mux. `Result_W = ReadData_W`. Forward it directly.

**Total: All cases handled by forwarding `Result_W`. No stalls. No special cases.** ✅

---

## PRIORITY: When BOTH I1-I3 AND I2-I3 Hazards Exist Simultaneously

### The Scenario

```asm
I1: add  x1, x2, x3     ;  writes x1
I2: addi x1, x4, 10     ;  ALSO writes x1
I3: sub  x5, x1, x6     ;  reads x1 — from I1 or I2?
```

When I3 is in EX:
- I1 is in WB → `rd_W = x1`, `Result_W` = I1's result → MEM/WB forwarding match
- I2 is in MEM → `rd_M = x1`, `forward_from_mem` = I2's result → EX/MEM forwarding match

**Both forwarding paths match `rs1_E = x1`.** Which do we use?

### Rule: **EX/MEM (I2) has priority. It is the more recent instruction.**

```verilog
// I2's value (more recent) must override I1's value (older)
ForwardA = (RegWrite_M && Rd_M != 0 && Rd_M == Rs1_E) ? 2'b10 :  // EX/MEM PRIORITY
           (RegWrite_W && Rd_W != 0 && Rd_W == Rs1_E) ? 2'b01 :  // MEM/WB fallback
           2'b00;                                                  // No forward
```

> [!IMPORTANT]
> **The priority check order IS the implementation.** By checking EX/MEM first in the if-else chain, the more recent value automatically wins. This is stated explicitly in **P&H COD Section 4.7, page 319**.

### All Priority Scenarios

| I1 (WB) | I2 (MEM) | I3 reads | Who wins? | Why |
|---|---|---|---|---|
| writes x1 | writes x1 | x1 | **I2** (EX/MEM) | More recent |
| writes x1 | writes x2 | x1 | **I1** (MEM/WB) | Only match |
| writes x1 | writes x2 | x2 | **I2** (EX/MEM) | Only match |
| writes x1 | writes x2 | x1 AND x2 | I1→rs1, I2→rs2 | ForwardA and ForwardB independent |
| writes x1 | doesn't write | x1 | **I1** (MEM/WB) | Only match |
| doesn't write | writes x1 | x1 | **I2** (EX/MEM) | Only match |

### Priority with Load-Use

```asm
I1: add  x1, x2, x3     ;  writes x1 (in WB)
I2: lw   x1, 0(x0)       ;  ALSO writes x1 (in MEM) — but it's a LOAD
I3: sub  x5, x1, x6      ;  reads x1
```

- I2 (LW) is in MEM, I3 reads x1 → **load-use hazard detected**
- I1 is in WB, could forward x1 → but I2's value should win (more recent)
- **Resolution**: Load-use stall takes priority. We stall I3 for 1 cycle, then forward I2's load result from WB.

> [!WARNING]
> **The stall overrides forwarding.** Even though I1 could provide a valid x1 from WB, I2's x1 is the architecturally correct value. We stall, let I2's result reach WB, then forward it.

---

## CONTROL HAZARDS (Refresher with Priority)

### BEQ Misprediction (resolved in EX)
```
Cycle:   1    2    3    4    5
BEQ:    [IF] [ID] [EX]  ← Branch resolved here
I_bad1:      [IF] [ID]  ← Wrong path (flush this)
I_bad2:           [IF]  ← Wrong path (flush this)
```
**Action**: Flush IF/ID (`FlushD`) and flush ID/EX (`FlushE`). 2-cycle penalty.

### JAL (always taken, resolved in EX)
Same as mispredicted branch — 2 wrong instructions fetched. Flush both.

### JALR (resolved in EX)
Same as above. 2 wrong instructions. Flush both.

### Control + Data Hazard Priority

**What happens when a load-use stall and a control flush coincide?**

```asm
lw   x1, 0(x0)         ;  in EX
beq  x1, x2, target    ;  in ID — depends on x1 (load-use!)
```

- Load-use detected: `ResultSrc_E == 01` and `Rs1_D == Rd_E`
- Stall the pipeline (freeze IF, freeze IF/ID, flush ID/EX)
- After stall, BEQ re-enters EX with the correct x1 (forwarded from WB)
- BEQ resolves → if taken, flush the 2 wrong instructions behind it

**Data hazard (stall) takes priority over control hazard resolution** — you can't resolve a branch until its operands are correct.

---

## COMPLETE FORWARDING UNIT SPECIFICATION

### Inputs

```verilog
input [4:0]  rs1_E, rs2_E;          // Consumer's source registers (from ID/EX)
input [4:0]  rd_M, rd_W;            // Producer's destination registers
input        regw_M, regw_W;        // Do they actually write to rd?
input [1:0]  resultsrc_M;           // What value does I_M write? (for result-aware forwarding)
```

### Forwarding Mux Value from MEM (I1-I2 forwarding)

```verilog
// This replaces naive ALUResult_M forwarding
wire [31:0] forward_val_M;
assign forward_val_M = (resultsrc_M == 2'b00) ? aluresult_M :  // R-type, ADDI
                        (resultsrc_M == 2'b10) ? pcplus4_M   :  // JAL, JALR
                        (resultsrc_M == 2'b11) ? immext_M    :  // LUI
                                                 32'bx;          // LW: forward_val invalid, stall handles this
```

### Forwarding Mux Value from WB (I1-I3 forwarding)

```verilog
// Result_W is already the correct value (output of result mux in WB)
wire [31:0] forward_val_W = result_W;
```

### ForwardA/B Select Logic (with Priority)

```verilog
// ForwardA — selects ALU SrcA input
assign ForwardA = (regw_M && rd_M != 5'b0 && rd_M == rs1_E) ? 2'b10 :  // I1-I2 from MEM (PRIORITY)
                  (regw_W && rd_W != 5'b0 && rd_W == rs1_E) ? 2'b01 :  // I1-I3 from WB
                  2'b00;                                                 // No forward (regfile)

// ForwardB — selects ALU SrcB input (before ALUSrc mux)
assign ForwardB = (regw_M && rd_M != 5'b0 && rd_M == rs2_E) ? 2'b10 :  // I1-I2 from MEM (PRIORITY)
                  (regw_W && rd_W != 5'b0 && rd_W == rs2_E) ? 2'b01 :  // I1-I3 from WB
                  2'b00;                                                 // No forward (regfile)
```

### 3-to-1 Forwarding Muxes in EX Stage

```verilog
// SrcA forwarding mux
wire [31:0] srcA_E;
assign srcA_E = (ForwardA == 2'b10) ? forward_val_M :  // From MEM stage
                (ForwardA == 2'b01) ? forward_val_W :  // From WB stage
                                      rdata1_E;        // From register file (no hazard)

// SrcB forwarding mux (BEFORE the ALUSrc mux)
wire [31:0] srcB_fwd_E;
assign srcB_fwd_E = (ForwardB == 2'b10) ? forward_val_M :
                    (ForwardB == 2'b01) ? forward_val_W :
                                          rdata2_E;

// Store data also comes from this forwarded value
wire [31:0] writedata_E = srcB_fwd_E;

// Then ALUSrc mux selects between forwarded rs2 and immediate
wire [31:0] srcB_E;
assign srcB_E = alusrc_E ? immext_E : srcB_fwd_E;
```

---

## COMPLETE HAZARD/STALL UNIT SPECIFICATION

### Load-Use Detection

```verilog
wire load_use_hazard;
assign load_use_hazard = (resultsrc_E == 2'b01) &&           // LW is in EX stage
                         ((rs1_D == rd_E) || (rs2_D == rd_E)) && // Consumer in ID reads LW's rd
                         (rd_E != 5'b0);                     // Not x0
```

### Control Hazard Detection

```verilog
wire pcsrc_E;
assign pcsrc_E = (branch_E & zero_E) | jump_E | jumpreg_E;  // Any taken branch or jump
```

### Output Signals

```verilog
// Stall signals (for load-use)
assign StallF = load_use_hazard;          // Freeze PC
assign StallD = load_use_hazard;          // Freeze IF/ID register

// Flush signals
assign FlushD = pcsrc_E;                  // Flush IF/ID on branch/jump
assign FlushE = load_use_hazard | pcsrc_E; // Flush ID/EX on stall OR branch/jump
```

> [!IMPORTANT]
> **Load-use stall and branch flush simultaneously**: If `load_use_hazard` and `pcsrc_E` are both true, both `StallF/StallD` and `FlushD/FlushE` assert. The stall takes effect first (keeps instruction in ID), and the flush zeros out ID/EX (inserts bubble). This is correct behavior — the branch can't resolve until the stall is complete.
> 
> In practice, this simultaneous case is impossible: if there's a load-use hazard, the dependent instruction is stalled in ID and hasn't reached EX yet, so `pcsrc_E` can't be asserted by that instruction. But the logic correctly handles any edge case.

---

## SUMMARY TABLE

| Hazard | Gap | Condition | Resolution | Module |
|---|---|---|---|---|
| RAW: R-type/ADDI → any (I1-I2) | Adjacent | `rd_M == rs_E` | Forward `ALUResult_M` | Forwarding Unit |
| RAW: LUI → any (I1-I2) | Adjacent | `rd_M == rs_E` | Forward `ImmExt_M` | Forwarding Unit |
| RAW: JAL/JALR → any (I1-I2) | Adjacent | `rd_M == rs_E` | Forward `PCPlus4_M` | Forwarding Unit |
| RAW: LW → any (I1-I2) | Adjacent | `rd_M == rs_E, resultsrc=01` | **STALL 1 cycle** | Hazard Unit |
| RAW: Any → any (I1-I3) | 1 between | `rd_W == rs_E` | Forward `Result_W` | Forwarding Unit |
| Priority: I2 vs I1 | Both match | `rd_M == rd_W == rs_E` | **EX/MEM wins** | Forwarding Unit |
| Control: BEQ mispredict | — | `branch_E & zero_E` | Flush IF/ID + ID/EX | Hazard Unit |
| Control: JAL | — | `jump_E` | Flush IF/ID + ID/EX | Hazard Unit |
| Control: JALR | — | `jumpreg_E` | Flush IF/ID + ID/EX | Hazard Unit |
| Structural | — | — | **None needed** (Harvard arch) | — |
| WAR | — | — | **None needed** (in-order) | — |
| WAW | — | — | **None needed** (in-order) | — |
| RAW 3+ gap | — | — | **None needed** (negedge write) | — |

---

## BOOK REFERENCES

| Topic | Best Reference |
|---|---|
| I1-I2 forwarding conditions | **Harris & Harris RISC-V, Section 7.5.3**, Figure 7.50 |
| I1-I3 forwarding conditions | **Harris & Harris RISC-V, Section 7.5.3** |
| Priority (EX/MEM > MEM/WB) | **P&H COD RISC-V, Section 4.7**, page 319 |
| Load-use hazard + stall | **Harris & Harris RISC-V, Section 7.5.3**, Figure 7.53 |
| Control hazards + flush | **Harris & Harris RISC-V, Section 7.5.4** |
| Full hazard taxonomy | **Quantitative Approach, Appendix C.2** |
