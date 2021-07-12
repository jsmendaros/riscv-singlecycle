`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2021 06:49:16 AM
// Design Name: 
// Module Name: processor
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


module processor(clk, nrst, pc, inst, addr, wr_en, wdata, wmask, rdata);
//toplevel ports
input clk, nrst;
input [31:0] inst;

output [31:0] pc, addr;

input [63:0] rdata;

output [63:0] wdata;
output [7:0] wmask;

output wr_en;
//

//inst decode
wire [6:0] opcode, funct7;
wire [2:0] funct3;

wire [4:0]  write_reg, rd_reg1, rd_reg2; //RF

wire [63:0] rd_data1, rd_data2; //RF
assign wdata=rd_data2; //set output to rs2
//

wire RegWrite; //RF

wire  ALUSrc; //alusrc mux
wire [63:0] alu_in2;

wire [2:0] ALUOp; //alu
wire zero;
wire [63:0] ALUresult;

wire PCSrc; //pcsrc mux

wire [31:0] next_pc; //pc+4 for jalr

wire [63:0] write_data; //RF
wire [63:0] rf_write_data;

wire [31:0] next_instruction;

//control signals
wire MemWrite, bne, Branch,  MemRead;
wire [1:0] MemToReg;
wire Jump, sd, ld;
//

//instruction decode
assign rd_reg1=inst[19:15];
assign rd_reg2=inst[24:20];
assign write_reg=inst[11:7];

assign opcode=inst[6:0];
assign funct7=inst[31:25];
assign funct3=inst[14:12];
//

//controller
controller control_unit(inst, wr_en, Branch, MemRead, RegWrite, MemToReg, ALUOp,  ALUSrc, Jump, sd, ld, bne, wmask);


//register file
RF rf1(clk, nrst, rd_reg1, rd_reg2, write_reg, write_data, rd_data1, rd_data2, RegWrite); //rf
//

//immediate generator
wire [31:0] jal_imm, jalr_imm, branch_imm;
wire [63:0] sd_imm, addi_imm;
imm_gen immgen(inst, jal_imm, jalr_imm, branch_imm, sd_imm, addi_imm);
//

//program counter
PC pc1(clk, nrst, Jump, bne, zero,Branch, opcode, jal_imm, jalr_imm, branch_imm, rd_data1, next_pc); //pc and inst adder
//

assign pc=next_pc; //pc+4


//alu input2 select
alusrc_mux alusrc_mux1(.rd_data2(rd_data2), .ALUSrc(ALUSrc), .alu_in2(alu_in2), .sd_imm(sd_imm), .addi_imm(addi_imm), .sd(sd)); //alusrc mux
//

//alu
alu alu1(.ALUOp(ALUOp), .in1(rd_data1), .in2(alu_in2), .zero(zero), .ALUresult(ALUresult)); //alu
//

//write back to regfile mux
wb_mux wbmux(.read_data(rdata), .alu_result(ALUresult), .MemToReg(MemToReg), .write_data(write_data), .pc(next_pc), .funct3(funct3));
//
   

assign addr = ALUresult[31:0]; //output to datamem
endmodule
