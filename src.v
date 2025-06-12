`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: PSU CMPEN 331
// Engineer: John Licata - jbl6429
// 
// Create Date: 03/24/2025 04:41:04 PM
// Design Name: 
// Module Name: src
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


module programCounter(
    
    input [31:0]nextPc,
    input clock,
    output reg [31:0]pc
 );
    
    initial begin
        pc = 32'd100; //pc starting at instr mem 100
    end
    
    always @(posedge clock) begin // update pc on pos clock edge
        pc = nextPc;
    end
 
endmodule


module InstructionMemory(

    input [31:0]pc,
    output reg [31:0]instOut
    
);

    reg[31:0] memory[0:63];
    
    initial begin
        
        memory[25] = 32'h00221820; // add $3, $1, $2 in hex form
        memory[26] = 32'h01232022; // sub $4, $9, $3 in hex form
        memory[27] = 32'h00692825; // or  $5, $3, $9 in hex form
        memory[28] = 32'h00693026; // xor $6, $3, $9 in hex form
        memory[29] = 32'h00693824; // and $7, $3, $9 in hex form
        
      end  
      
      always@(*)begin
        instOut = memory[pc[7:2]]; // set to val of mem array at pc
      end

endmodule

module PcAdder(
    input [31:0]pc,
    output reg [31:0]nextPc

);

reg [31:0]pc_incr; // store pc increment in case changed in future

initial begin
    pc_incr = 32'd4; // set pc_incr to 4 (what we use in this lab)
end

always@(*)begin
    nextPc = pc + pc_incr; // increment pc on each signal change
end

endmodule


module IFIDPipelineRegister(

    input [31:0]instOut,
    input clock,
    output reg [31:0]dinstOut

);
       
    always @(posedge clock) begin // update on positive clock edge
        dinstOut = instOut;
    end
endmodule



module ControlUnit(
    input [5:0]op,
    input [5:0]func,
    input [4:0]rs,
    input[4:0]rt,
    input [4:0] mdestReg,
    //input mm2reg,
    //input mwreg,
    input [4:0] edestReg,
    //input em2reg,
    //input ewreg,
    output reg wreg,
    output reg m2reg,
    output reg wmem,
    output reg [3:0]aluc,
    output reg aluimm,
    output reg regrt,
    output reg [1:0]fwda,
    output reg [1:0]fwdb
    
    );
    
    always@(*) begin
        case(op)  // checking for op values
            6'b000000: // if op is 000000 (r-type)
                begin
                    case(func) // if op is 000000, need to check func (many r-types)
                        6'b100000: //if ADD
                            begin
                                wreg = 1'b1; // writing to gen purp reg
                                m2reg = 1'b0; // not loading anything from mem
                                wmem = 0; // not writing to mem
                                aluc = 4'b0010; // alu control input 2 for add
                                aluimm = 1'b0; // not using val in immediate for ALU
                                regrt = 1'b0; // writing to rd
                            end
                        6'b100010: 
                            begin // if SUB
                                wreg   = 1'b1;
                                m2reg  = 1'b0;
                                wmem   = 1'b0;
                                aluc   = 4'b0110;
                                aluimm = 1'b0;
                                regrt  = 1'b0;
                            end
                        6'b100100: 
                            begin // if AND
                                wreg   = 1'b1;
                                m2reg  = 1'b0;
                                wmem   = 1'b0;
                                aluc   = 4'b0000;
                                aluimm = 1'b0;
                                regrt  = 1'b0;
                            end
                        6'b100101: 
                            begin // if OR
                                wreg   = 1'b1;
                                m2reg  = 1'b0;
                                wmem   = 1'b0;
                                aluc   = 4'b0001;
                                aluimm = 1'b0;
                                regrt  = 1'b0;
                            end
                        6'b100110: 
                            begin // if XOR
                                wreg   = 1'b1;
                                m2reg  = 1'b0;
                                wmem   = 1'b0;
                                aluc   = 4'b0011;
                                aluimm = 1'b0;
                                regrt  = 1'b0;
                            end
                    endcase
                end
            6'b100011: // if op is 100011 (LW)
                begin
                    wreg = 1'b1; // writing to gen purp reg
                    m2reg = 1'b1; // loading val from mem into reg
                    wmem = 1'b0; // not writing to mem
                    aluc =  4'b0010; // already automatically add for LW, but just in case for now
                    aluimm = 1'b1;
                    regrt = 1'b1; // writing to rt, not rd
                end
        endcase
        
        
        //forwarding functionality for rs via fwdA
        case (rs)
            edestReg: begin
                fwda <= 2'b01; //forwarding execute stage
            end
            mdestReg: begin
                fwda <= 2'b10; //forwarding mem stage
            end
            default: begin
                fwda <= 2'b00; // no forwarding
            end
        endcase


        //forwarding functionality for rt via fwdB
        case (rt)
            edestReg: begin
                fwdb <= 2'b01; //forwarding execute stage
            end
            mdestReg: begin
                fwdb <= 2'b10; //forwarding mem stage
            end
            default: begin
                fwdb <= 2'b00; //no forwarding 
            end
        endcase
    end
                  
endmodule


module RegrtMultiplexer(

    input [4:0]rt,
    input [4:0]rd,
    input regrt,
    output reg [4:0]destReg

);
    
    always@(*) begin // on any singal change
        case (regrt)
            1'b0: // if regrt is 0
                begin
                    destReg = rd;
                end
            1'b1: // if regrt is 1
                begin
                    destReg = rt;
                end 
        endcase
    
    end
    
endmodule

module RegisterFile(
    input [4:0]rs,
    input [4:0]rt,
    input [4:0]wdestReg,
    input [31:0]wbData,
    input wwreg,
    input clk,
    output reg [31:0]qa,
    output reg[31:0]qb
);

    reg[31:0] register[31:0]; // setting up registers
    
    initial begin   // setting all registers to 0 (as per lab instructions)               
        
        register[0] = 32'h00000000;
        register[1] = 32'hA00000AA;
        register[2] = 32'h10000011;
        register[3] = 32'h20000022;
        register[4] = 32'h30000033;
        register[5] = 32'h40000044;
        register[6] = 32'h50000055;
        register[7] = 32'h60000066;
        register[8] = 32'h70000077;
        register[9] = 32'h80000088;
        register[10] = 32'h90000099;
        
        
    end
   
   always@(negedge clk) begin // on negedge
        if (wwreg == 1) begin
            register[wdestReg] <= wbData;
        end
    end
    
    always@(*) begin // on any signal change
        qa = register[rs]; //qa is set to value of register at address rs
        qb = register[rt]; // qb is set to value of register at address rt
    end
    
    
endmodule      


module ImmediateExtender(

    input [15:0]imm,
    output reg [31:0]imm32
);

    always@(*) begin
        imm32 <= {{16{imm[15]}} , imm}; // sign extend imm and put into imm32
    end

endmodule


module IdexePipelineRegister(
    input wreg,
    input m2reg,
    input wmem,
    input [3:0]aluc,
    input aluimm,
    input [4:0]destReg,
    input [31:0]dfwdA,
    input [31:0]dfwdB,
    input [31:0]imm32,
    input clock,
    output reg ewreg,
    output reg em2reg,
    output reg ewmem,
    output reg [3:0]ealuc,
    output reg ealuimm,
    output reg [4:0]edestReg,
    output reg [31:0]eqa,
    output reg [31:0]eqb,
    output reg [31:0]eimm32
);

    always@(posedge clock)begin // on positive clock edge, fill values on LHS with values of RHS
        ewreg = wreg;
        em2reg = m2reg;
        ewmem = wmem;
        ealuc = aluc;
        ealuimm = aluimm;
        edestReg = destReg;
        eqa = dfwdA;
        eqb = dfwdB;
        eimm32 = imm32;
        
    end

endmodule


module AluMux(

input [31:0]eqb,
input [31:0]eimm32,
input ealuimm,
output reg [31:0]b

);

always@(*)begin

    // deciding if we are adding 2 registers or adding with the imm value
    case(ealuimm) // selector bit, depending on if 1 or 0, we set b (what we're adding to different value
        1'b0:
            begin
                b <= eqb; //adding with a register
            end
        1'b1:
            begin
                b <= eimm32; // adding with immediate value
            end
    endcase
end

endmodule



module Alu(

input [31:0]eqa,
input [31:0]b,
input [3:0]ealuc,
output reg [31:0]r

);

//just need "add" for lab 4 (for final need to add other operations)

always@(*) begin
    case(ealuc)
        4'b0000: //and
            begin
                r <= eqa & b; // perform and
            end
        4'b0001: //or
            begin
                r <= eqa | b; // perform or
            end
        4'b0010: // add
            begin
                r <= eqa + b; // perform add
            end
        4'b0110: //subtract
            begin
                r <= eqa - b; // perform sub
            end
        4'b1000: //xor
            begin
                r <= eqa ^ b; // perform xor
            end
        default:
            begin
                r <= 0;
            end            
    endcase
end

endmodule


module EXEMEMpiplineRegister(
    input ewreg, 
    input em2reg, 
    input ewmem,
    input [4:0]edestReg,
    input [31:0]r,
    input [31:0]eqb,
    input clock,
    output reg mwreg,
    output reg mm2reg,
    output reg mwmem,
    output reg [4:0]mdestReg,
    output reg [31:0]mr,
    output reg [31:0]mqb

);

    always@(posedge clock) begin // on positive edge, transfer through pipeline
        mwreg <= ewreg;
        mm2reg <= em2reg;
        mwmem <= ewmem;
        mdestReg <= edestReg;
        mr <= r;
        mqb <= eqb;
    end

endmodule

module DataMemory(
    input [31:0]mr,
    input [31:0]mqb,
    input mwmem,
    input clock,
    output reg [31:0]mdo
);
    
    // implementing the memory array
    reg [31:0] dataMemory[0:63];
    
    //initializing first 10 words of data memory
    initial begin
        dataMemory[0] = 32'hA00000AA;
        dataMemory[4] = 32'h10000011;
        dataMemory[8] = 32'h20000022;
        dataMemory[12] = 32'h30000033;
        dataMemory[16] = 32'h40000044;
        dataMemory[20] = 32'h50000055;
        dataMemory[24] = 32'h60000066;
        dataMemory[28] = 32'h70000077;
        dataMemory[32] = 32'h80000088;
        dataMemory[36] = 32'h90000099;
    end
    
    always@(*)begin
        mdo <= dataMemory[mr]; //always place value at mr in datamem into mdo
    end
    
    always@(negedge clock) begin
    if (mwmem == 1) // when write to mem bit is 1, we write mqb to mr in data memory
 
            dataMemory[mr] <= mqb; 

   
    end

endmodule


module MEMWBpipelineRegister(
    input mwreg,
    input mm2reg,
    input [4:0]mdestReg,
    input [31:0]mr,
    input [31:0]mdo,
    input clock,
    output reg wwreg,
    output reg wm2reg,
    output reg [4:0]wdestReg,
    output reg [31:0]wr,
    output reg [31:0]wdo
);
    always@(posedge clock) begin // on positive clock edge transfer through pipeline
        wwreg <= mwreg;
        wm2reg <= mm2reg;
        wdestReg <= mdestReg;
        wr <= mr;
        wdo <= mdo;
    end


endmodule

module WbMux(
    input [31:0]wr,
    input [31:0]wdo,
    input wm2reg,
    output reg [31:0]wbData

);

    always@(*) begin
        case(wm2reg)
            1'b0: begin
                wbData = wr;
            end
            1'b1: begin
                wbData = wdo;
            end
        endcase    
    end

endmodule

module ForwardMuxA(
    input [1:0] fwdA,
    input [31:0] qa,
    input [31:0] r,
    input [31:0] mr,
    input [31:0] mdo,
    output reg [31:0] dfwdA


);

    always @(*) begin
            casez(fwdA)
                2'b00: begin
                    dfwdA <= qa;
                end
                2'b01: begin
                    dfwdA <= r;
                end
                2'b10: begin
                    dfwdA <= mr;
                end
                2'b11: begin
                    dfwdA <= mdo;
                end
            endcase
    end



endmodule

module ForwardMuxB(
    input [1:0] fwdB,
    input [31:0] qb,
    input [31:0] r,
    input [31:0] mr,
    input [31:0] mdo,
    output reg [31:0] dfwdB


);

    always @(*) begin
            
            casez(fwdB)
                2'b00: begin
                    dfwdB <= qb;
                end
                2'b01: begin
                    dfwdB <= r;
                end
                2'b10: begin
                    dfwdB <= mr;
                end
                2'b11: begin
                    dfwdB <= mdo;
                end
            endcase
    end

endmodule




module Datapath(

    input clock, // drives the datapath (by simply updating clock, the pc updates, instruction read, etc.
    output [31:0] pc,
    output [31:0] instOut,
    output [31:0] dinstOut,
    output wreg,
    output m2reg,
    output wmem,
    output [3:0] aluc,
    output aluimm,
    output regrt,
    output [4:0] destReg,
    output [31:0] qa,
    output [31:0] qb,
    output [31:0] imm32,
    output ewreg,
    output em2reg,
    output ewmem,
    output [3:0] ealuc,
    output ealuimm,
    output [4:0] edestReg,
    output [31:0] eqa,
    output [31:0] eqb,
    output [31:0] eimm32,
    output mwreg,
    output mm2reg,
    output mwmem,
    output [4:0]mdestReg,
    output [31:0]mr,
    output [31:0]mqb,
    output wwreg,
    output wm2reg,
    output [4:0]wdestReg,
    output [31:0]wr,
    output [31:0]wdo,
    output wire [31:0] wbData,
    output  wire [1:0] fwda,  
    output wire [1:0] fwdb,  
    output wire [31:0] dfwdA,   
    output wire [31:0] dfwdB, 
    output wire [31:0] r,
    output wire [31:0]mdo,
    output wire [31:0] nextPc,
    output wire [31:0] b,         
    output wire [4:0]rs,
    output wire [4:0]rt  
);

    wire [31:0] nextPc;  
 
    wire [31:0] instOut;  
 
    wire [31:0] dinstOut; 
  
 
    wire wreg; 
 
    wire m2reg; 
 
    wire wmem; 
 
    wire [3:0] aluc; 
 
    wire aluimm; 
 
    wire regrt; 
 
    wire [4:0] destReg;  

    wire [31:0] imm32;  
    
    wire [31:0] b; 

    
    wire [31:0] r; 
  
    wire [31:0] mdo; 

       

   

    
    // below,an instance of each module is created, that are connected vai the wires/outputs created above

    programCounter pccounterINST(
        .nextPc(nextPc),
        .clock(clock),
        .pc(pc)
    );

    PcAdder pcadderINST(
        .pc(pc),
        .nextPc(nextPc)
    );

    InstructionMemory instructionmemoryINST(
        .pc(pc),
        .instOut(instOut)
    );

    IFIDPipelineRegister ifidpipelineregisterINST(
        .instOut(instOut),
        .clock(clock),
        .dinstOut(dinstOut)
    );

    
    ControlUnit controlunitINST(
        .op(dinstOut[31:26]), // as seen here and more below, we extract the nessecary bits for the input (for instance this is op
        .func(dinstOut[5:0]), 
        .rs(dinstOut[25:21]),
        .rt(dinstOut[20:16]),
        .mdestReg(mdestReg),
        .edestReg(edestReg),
        .wreg(wreg),
        .m2reg(m2reg),
        .wmem(wmem),
        .aluc(aluc),
        .aluimm(aluimm),
        .regrt(regrt),
        .fwda(fwda),
        .fwdb(fwdb)
    );

    RegrtMultiplexer regrtmultiplexerINST(
        .rt(dinstOut[20:16]),
        .rd(dinstOut[15:11]),
        .regrt(regrt),
        .destReg(destReg)
    );

    RegisterFile registerfileINST(
        .rs(dinstOut[25:21]),
        .rt(dinstOut[20:16]),
        .wdestReg(wdestReg),
        .wbData(wbData),
        .wwreg(wwreg),
        .clk(clk),
        .qa(qa),
        .qb(qb)
    );
    

    ImmediateExtender immediateextenderINST(
        .imm(dinstOut[15:0]),
        .imm32(imm32)
    );


    IdexePipelineRegister idexepipelineregisterINST(
        .wreg(wreg),
        .m2reg(m2reg),
        .wmem(wmem),
        .aluc(aluc),
        .aluimm(aluimm),
        .destReg(destReg),
        .dfwdA(dfwdA),
        .dfwdB(dfwdB),
        .imm32(imm32),
        .clock(clock),
        .ewreg(ewreg),
        .em2reg(em2reg),
        .ewmem(ewmem),
        .ealuc(ealuc),
        .ealuimm(ealuimm),
        .edestReg(edestReg),
        .eqa(eqa),
        .eqb(eqb),
        .eimm32(eimm32)
    );
    
    AluMux alumuxINST(
        .eqb(eqb),
        .eimm32(eimm32),
        .ealuimm(ealuimm),
        .b(b)
    );
    
    Alu aluINST(

        .eqa(eqa),
        .b(b),
        .ealuc(ealuc),
        .r(r)
    );
    
    EXEMEMpiplineRegister exemempiplineregisterINST(
        .ewreg(ewreg), 
        .em2reg(em2reg), 
        .ewmem(ewmem),
        .edestReg(edestReg),
        .r(r),
        .eqb(eqb),
        .clock(clock),
        .mwreg(mwreg),
        .mm2reg(mm2reg),
        .mwmem(mwmem),
        .mdestReg(mdestReg),
        .mr(mr),
        .mqb(mqb)

    );
    
    DataMemory datamemoryINST(
        .mr(mr),
        .mqb(mqb),
        .mwmem(mwmem),
        .clock(clock),
        .mdo(mdo)
    );
    
    MEMWBpipelineRegister memwbpipelineregisterINST(
        .mwreg(mwreg),
        .mm2reg(mm2reg),
        .mdestReg(mdestReg),
        .mr(mr),
        .mdo(mdo),
        .clock(clock),
        .wwreg(wwreg),
        .wm2reg(wm2reg),
        .wdestReg(wdestReg),
        .wr(wr),
        .wdo(wdo)
    );
    
    WbMux wbmuxINST(
        .wr(wr),
        .wdo(wdo),
        .wm2reg(wm2reg),
        .wbData(wbData)
    );
    
    ForwardMuxA forwardmuxaINST(
        .fwdA(fwdA),
        .qa(qa),
        .r(r),
        .mr(mr),
        .mdo(mdo),
        .dfwdA(dfwdA)
    );
    
    ForwardMuxB forwardmuxbINST(
        .fwdB(fwdB),
        .qb(qb),
        .r(r),
        .mr(mr),
        .mdo(mdo),
        .dfwdB(dfwdB)
    );


    


Endmodule

