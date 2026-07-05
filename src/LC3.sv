import State_pkg::*;
import Decode_pkg::*;

module LC3(
    input logic clk,
    input logic reset,

    input logic [15:0] eDIN,
    input logic eREADY,

    output tri [15:0] eDOUT,

    output tri [15:0] eADDR,
    output tri eWEA
);

// State Signals
logic pEn;
logic fEn;
logic dEn;
logic rWe;
logic [2:0] mOp;

cCtrl_t cCtrl;

State state(
    .clk(clk),
    .reset(reset),
    .cCtrl(cCtrl),
    .eREADY(eREADY),

    .pEn(pEn),
    .fEn(fEn),
    .dEn(dEn),
    .rWe(rWe),
    .mOp(mOp)
);

// Decode Signals
logic [2:0] psr;
logic pNext;
logic aOp;
drmux_select_t drSrc;
uOp_t uOp;

logic [2:0] sr1ID;
logic [2:0] sr2ID;
logic [2:0] drID;

logic [4:0] imm;
logic [8:0] offset;

Decode decode(
    .clk(clk),
    .reset(reset),
    .en(dEn),
    .eDIN(eDIN),
    .psr(psr),
    .pNext(pNext),
    .drSrc(drSrc),
    .uOp(uOp),
    .cCtrl(cCtrl),
    .sr1ID(sr1ID),
    .sr2ID(sr2ID),
    .drID(drID),
    .imm(imm),
    .offset(offset)
);

// Fetch
logic [15:0] pc;

logic iBR0;
logic [15:0] iADDR0;
logic iWEA0;

Fetch fetch(
    .en(fEn),
    .pc(pc),

    .iBR(iBR0),
    .iADDR(iADDR0),
    .iWEA0(iWEA0)
);

// Update PC

logic [15:0] tPC;
logic [15:0] nPC;

UpdatePC updatePC(
    .clk(clk),
    .reset(reset),
    .en(pEn),
    .sel(pNext),
    .tPC(tPC),
    .nPC(nPC),
    .pc(pc)
);

// Registers

logic [15:0] dr;
logic [15:0] sr1;
logic [15:0] sr2;

Registers registers (
    .clk(clk),
    .reset(reset),
    .en(rWe),
    .sr1ID(sr1ID),
    .sr2ID(sr2ID),
    .drID(drID),
    .dr(dr),
    .psr(psr),
    .sr1(sr1),
    .sr2(sr2)
);

// ALU

logic [15:0] uOut;

ALU alu(
    .sr1(sr1),
    .sr2(sr2),
    .imm(imm),
    .uOp(uOp),
    .uOut(uOut)
);

// Address

logic [15:0] aOut;

Address address(
  .baseReg(sr1),
  .offset(offset),
  .nPC(nPC),
  .aOp(aOp),
  .aOut(aOut)
);

// DrMux

DrMux drmux(
    .uOut(uOut),
    .aOut(aOut),
    .eDIN(eDIN),
    .sel(drSrc),
    .dr(dr)
);

// MemoryIF

logic iBR1;
logic [15:0] iADDR1;
logic iWEA1;

MemoryIF memoryIF(
    .eDIN(eDIN),
    .sr(sr1),
    .addr(aOut),
    .mOp(mOp),
    .eDOUT(eDOUT),
    .iBR(iBR1),
    .iADDR(iADDR1),
    .iWEA(iWEA1)
);

// BusDriver

BusDriver busDriver (
    .iBR0(iBR0),
    .iADDR0(iADDR0),
    .iWEA0(iWEA0),
    .iBR1(iBR1),
    .iADDR1(iADDR1),
    .iWEA1(iWEA1),
    .eADDR(eADDR),
    .eWEA(eWEA)
);

endmodule