# riscv-singlecycle
Single-cycle RISC-V 64-bit implementation in Verilog

Created in Xilinx Vivado for Arty A7-35 board

## Instructions supported
* Register-register: add, sub, and, or, xor
* Register-immediate: addi
* Branches: beq, bne, jal, jalr
* Load/Store: ld, lw, lh, lwu, lhu, sd, sw, sh

## Memory files
* Memory files were provided by my professor at (https://github.com/snapdensing/CoE113/tree/master/memory_model)
* Load and store instructions are intended to interface with these modules
