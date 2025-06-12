`timescale 1ns / 1ps

module testbench();

    reg clock; // create clock reg, which will run the datapath (input)

    // set clock to 0 to start, then create period of 10ns to run
    initial begin
        clock = 0;
        forever #5 clock = ~clock;
    end

    // wires to connect parts of datapath
    wire [31:0] pc;
    wire [31:0] instOut;
    wire [31:0] dinstOut;
    wire wreg;
    wire m2reg;
    wire wmem;
    wire aluimm;
    wire regrt;  
    wire [3:0] aluc;
    wire [4:0] destReg;   
    wire [31:0] qa;
    wire [31:0] qb;
    wire [31:0] imm32;   
    wire ewreg;
    wire em2reg;
    wire ewmem;
    wire ealuimm;   
    wire [3:0] ealuc;
    wire [4:0] edestReg;    
    wire [31:0] eqa;
    wire [31:0] eqb;
    wire [31:0] eimm32;
    wire mwreg;
    wire mm2reg;
    wire mwmem;
    wire [4:0]mdestReg;
    wire [31:0]mr;
    wire [31:0]mqb;
    wire wwreg;
    wire wm2reg;
    wire [4:0]wdestReg;
    wire [31:0]wr;
    wire [31:0]wdo;
    wire [31:0]wbData;
    wire [1:0]fwda;
    wire [1:0]fwdb;
    wire [31:0]dfwdA;
    wire [31:0]dfwdB;
    wire [31:0] r;
    wire [31:0]mdo;
    wire [31:0] nextPc;
    wire [31:0] b;        



    // creating instance of datapath module
    Datapath datapath(
        .clock(clock),
        .pc(pc),
        .instOut(instOut),
        .dinstOut(dinstOut),
        .wreg(wreg),
        .m2reg(m2reg),
        .wmem(wmem),
        .aluc(aluc),
        .aluimm(aluimm),
        .regrt(regrt),
        .destReg(destReg),
        .qa(qa),
        .qb(qb),
        .imm32(imm32),
        .ewreg(ewreg),
        .em2reg(em2reg),
        .ewmem(ewmem),
        .ealuc(ealuc),
        .ealuimm(ealuimm),
        .edestReg(edestReg),
        .eqa(eqa),
        .eqb(eqb),
        .eimm32(eimm32),
        .mwreg(mwreg),
        .mm2reg(mm2reg),
        .mwmem(mwmem),
        .mdestReg(mdestReg),
        .mr(mr),
        .mqb(mqb),
        .wwreg(wwreg),
        .wm2reg(wm2reg),
        .wdestReg(wdestReg),
        .wr(wr),
        .wdo(wdo),
        .wbData(wbData),
        .fwda(fwda),
        .fwdb(fwdb),
        .dfwdA(dfwdA),
        .dfwdB(dfwdB),
        .r(r),
        .mdo(mdo),
        .nextPc(nextPc),
        .b(b)
    );

    
    // set stop time
    initial begin
        #100 $finish;
    End
