# 5-Stage-Pipelined-CPU

For this project, I implemented a five-stage pipelined CPU. Pipelining is important for computers in enhancing throughput by overlapping instruction stages. This was done in Verilog and was based off of MIPS architecture. The 5 stages include Instruction Fetch, Instruction Decode, Execution, Memory Access, and Write Back. Below, I explain how each part works together and what each stage does. I then explain how forwarding logic is used to resolve data hazards. 

## Instruction Fetch (IF):

 <img width="500" alt="Screenshot 2025-06-11 at 10 11 01 PM" src="https://github.com/user-attachments/assets/3094120b-9286-4d94-bcda-b7941028b6a9" />

The first stage of the CPU involves creating the Instruction Fetch. This stage retrieves the instruction from the memory (instOut) and updates the program counter (pc) to read the following instructions (nextPc). It utilizes a program counter module to update the pc on positive edges of the clock (clock). The pc starts at 100. The program counter module is responsible for updating the program counter by adding 4 to it every signal. The instruction memory is a 32x64 block (32-bit values with 64 positions). The instruction is then fed into the IF/ID Pipeline register.

## Instruction Decode (ID):

 <img width="500" alt="Screenshot 2025-06-11 at 10 11 06 PM" src="https://github.com/user-attachments/assets/a63ace96-77c0-4148-a314-6a04a3c292a5" />

The Instruction Decode Stage is where we find out what the instruction that we just fetched is supposed to be doing. Do to our pipeline, as the instruction is being decoded, the next instruction is already being fetched back in the IF stage. When the ID stage receives an instruction, it breaks it into the pieces that will give it its meaning. The control unit is an important module in this stage, as it takes in the op (first 5 bits of the instruction) and the func (last 5 bits of the instruction), and determine what the instruction is going to do. It assigns values to wreg, m2reg, wmem, aluc, aluimm, regrt which give important information such as is the instruction adding, subtracting, etc. or is it writing to a register or not. It also utilizes the Regrt multiplexer, which determines where the result of the instruction will be stored (the destination register either being rt or rd). The register file sets qa and qb to the actual registers being pointed to in rs and rt. It takes these registers from the register memory which is 32x32. In the ID stage, we also have an Immediate Extender module which is important for when values need to be extended (for example in load instructions). This information then gets fed into the IDEXE Pipeline Register where all these building blocks can then be used to execute the instruction.

## Execution (EXE):

<img width="500" alt="Screenshot 2025-06-11 at 10 11 12 PM" src="https://github.com/user-attachments/assets/81df24d9-b840-4253-9e25-ceef7780a7bd" />

In the Execution Stage, we determine the second input for what will be put into our ALU, and then the ALU executes our instruction. The results are then fed into the EXE/MEM pipeline register. We use the ALU Multiplexer to determine the second input into our ALU. We then use the ALU module which performs an indicated operation on any signal change. This is determined from what we decoded in the ID stage, and the operation is performed between the 2 inputs. The output is r is then stored in a register or used to access a register.  

## Memory (MEM):

 <img width="500" alt="Screenshot 2025-06-11 at 10 11 18 PM" src="https://github.com/user-attachments/assets/64a36d8e-9207-4d37-b170-3f80254f0369" />

The memory access allows us to read and write to our data memory. It then feeds into the Mem/Wb pipeline register. In this stage we have the data memory module where we either store the value at position mr in the memory into mdo, or we store the value of mqb at memory position mr. This is dependent on the input of mwmem. 

## Writeback (WB):

 <img width="500" alt="Screenshot 2025-06-11 at 10 11 23 PM" src="https://github.com/user-attachments/assets/95261c5a-5b5e-49c3-81c8-022597f73be3" />

In Writeback (WB), we decide whether we need to write the data memory output or the ALU output to the register file. In this stage, we have the writeback multiplexer which takes in wr and wdo, as well as a selector bit or wm2reg. It then sets the output wbData to either wr or wdo depending on the value of wm2reg (0 or 1). It then input wdestReg, wbData and wwreg to the Register File, which will let the register file know whether or not we are writing to a register, and if we are, what register that is. 

## Forwarding:

 <img width="500" alt="Screenshot 2025-06-11 at 10 11 31 PM" src="https://github.com/user-attachments/assets/e20dc65f-9c79-4769-bd20-919f106c9cd7" />

Lastly, we had to implement forwarding capabilities. This would allow the CPU to overcome hazards and detect/handle them properly. This included implementing 2 extra modules, FowardMuxA and ForwardMuxB. They determine if ALU forwarding , memory forwarding, data memory forwarding, or no forwarding would be taking place. ForwardMuxA handled qa and ForwardMuxB handled qb. We also utilized fwda and fwdb in the control unit which allowed us to determine if this forwarding was needed. Now we have a pipeline that can handle hazards and is efficient. 

### Datapath

All the stages of this CPU were executed by the Datapath module, which was in charge of feeding the different inputs/outputs into the modules so that values would be updated. Overall, the datapath was driven by the clock.

