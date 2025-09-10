"""
Converts assembly programs to hex format for InstructionMemory.v
"""

import sys
import re
from typing import Dict, List, Tuple

class ARM64Assembler:
    def __init__(self):
        # Instruction encodings based on Control.v
        self.opcodes = {
            'MOVZ': 0b11010010100,  # 11'b110100101??
            'ADD':  0b10001011000,  # 11'b?0?01011??? (register)
            'ADDI': 0b10010001000,  # 11'b?0?10001??? (immediate) 
            'SUB':  0b11001011000,  # 11'b?1?01011??? (register)
            'SUBI': 0b11010001000,  # 11'b?1?10001??? (immediate)
            'AND':  0b10001010000,  # 11'b?0001010???
            'ORR':  0b10101010000,  # 11'b?0101010???
            'LDUR': 0b11111000010,  # 11'b??111000010
            'STUR': 0b11111000000,  # 11'b??111000000
            'CBZ':  0b10110100000,  # 11'b?011010????
            'B':    0b00010100000,  # 11'b?00101?????
        }
        
        self.registers = {f'X{i}': i for i in range(32)}
        self.labels = {}
        self.instructions = []
        
    def parse_register(self, reg_str: str) -> int:
        reg_str = reg_str.strip().rstrip(',')
        if reg_str in self.registers:
            return self.registers[reg_str]
        raise ValueError(f"Invalid register: {reg_str}")
    
    def parse_immediate(self, imm_str: str) -> int:
        imm_str = imm_str.strip().rstrip(',')
        if imm_str.startswith('#'):
            return int(imm_str[1:])
        return int(imm_str)
    
    def parse_memory_operand(self, mem_str: str) -> Tuple[int, int]:
        mem_str = mem_str.strip()
        if not (mem_str.startswith('[') and mem_str.endswith(']')):
            raise ValueError(f"Invalid memory operand: {mem_str}")
        
        content = mem_str[1:-1]
        parts = content.split(',')
        
        base_reg = self.parse_register(parts[0].strip())
        offset = 0
        if len(parts) > 1:
            offset = self.parse_immediate(parts[1].strip())
        
        return base_reg, offset
    
    def encode_instruction(self, opcode: str, operands: List[str], pc: int) -> int: 
        if opcode == 'MOVZ':
            # MOVZ Xd, #imm16
            if len(operands) < 2:
                raise ValueError(f"MOVZ requires 2 operands, got {len(operands)}: {operands}")
            rd = self.parse_register(operands[0])
            imm16 = self.parse_immediate(operands[1])
            return (self.opcodes['MOVZ'] << 21) | (imm16 << 5) | rd
            
        elif opcode == 'ADD':
            if '#' in operands[2]:
                # ADD Xd, Xn, #imm12 (immediate)
                rd = self.parse_register(operands[0])
                rn = self.parse_register(operands[1])
                imm12 = self.parse_immediate(operands[2])
                return (self.opcodes['ADDI'] << 21) | (imm12 << 10) | (rn << 5) | rd
            else:
                # ADD Xd, Xn, Xm (register)
                rd = self.parse_register(operands[0])
                rn = self.parse_register(operands[1])
                rm = self.parse_register(operands[2])
                return (self.opcodes['ADD'] << 21) | (rm << 16) | (rn << 5) | rd
                
        elif opcode == 'SUB':
            if '#' in operands[2]:
                # SUB Xd, Xn, #imm12
                rd = self.parse_register(operands[0])
                rn = self.parse_register(operands[1])
                imm12 = self.parse_immediate(operands[2])
                return (self.opcodes['SUBI'] << 21) | (imm12 << 10) | (rn << 5) | rd
            else:
                # SUB Xd, Xn, Xm
                rd = self.parse_register(operands[0])
                rn = self.parse_register(operands[1])
                rm = self.parse_register(operands[2])
                return (self.opcodes['SUB'] << 21) | (rm << 16) | (rn << 5) | rd
                
        elif opcode == 'AND':
            rd = self.parse_register(operands[0])
            rn = self.parse_register(operands[1])
            if '#' in operands[2]:
                # Treat as immediate for simplicity
                imm = self.parse_immediate(operands[2])
                return (self.opcodes['AND'] << 21) | (imm << 10) | (rn << 5) | rd
            else:
                rm = self.parse_register(operands[2])
                return (self.opcodes['AND'] << 21) | (rm << 16) | (rn << 5) | rd
                
        elif opcode == 'ORR':
            rd = self.parse_register(operands[0])
            rn = self.parse_register(operands[1])
            rm = self.parse_register(operands[2])
            return (self.opcodes['ORR'] << 21) | (rm << 16) | (rn << 5) | rd
            
        elif opcode == 'LDUR':
            rd = self.parse_register(operands[0])
            rn, offset = self.parse_memory_operand(operands[1])
            return (self.opcodes['LDUR'] << 21) | ((offset & 0x1FF) << 12) | (rn << 5) | rd
            
        elif opcode == 'STUR':
            rt = self.parse_register(operands[0])
            rn, offset = self.parse_memory_operand(operands[1])
            return (self.opcodes['STUR'] << 21) | ((offset & 0x1FF) << 12) | (rn << 5) | rt
            
        elif opcode == 'CBZ':
            rt = self.parse_register(operands[0])
            if operands[1] in self.labels:
                target_addr = self.labels[operands[1]]
                branch_offset = (target_addr - pc) // 4
            else:
                branch_offset = 0  # Forward reference, will be resolved later
            return (self.opcodes['CBZ'] << 21) | ((branch_offset & 0x7FFFF) << 5) | rt
            
        elif opcode == 'B':
            if operands[0] in self.labels:
                target_addr = self.labels[operands[0]]
                branch_offset = (target_addr - pc) // 4
            else:
                branch_offset = 0  # Forward reference
            return (self.opcodes['B'] << 21) | (branch_offset & 0x3FFFFFF)
            
        else:
            raise ValueError(f"Unsupported opcode: {opcode}")
    
    def assemble(self, assembly_file: str) -> List[str]:        
        with open(assembly_file, 'r') as f:
            lines = f.readlines()
        
        # First pass: collect labels
        pc = 0
        for line in lines:
            line = line.strip()
            if not line or line.startswith('#'):
                continue
            
            # Remove comments (but not immediate values starting with #)
            comment_pos = -1
            in_immediate = False
            for i, char in enumerate(line):
                if char == '#':
                    # Check if this # is part of an immediate value
                    if i > 0 and (line[i-1].isspace() or line[i-1] == ','):
                        in_immediate = True
                        continue
                    elif not in_immediate:
                        comment_pos = i
                        break
                elif char.isspace() and in_immediate:
                    in_immediate = False
            
            if comment_pos >= 0:
                line = line[:comment_pos].strip()
                
            if line.endswith(':'):
                label = line[:-1]
                self.labels[label] = pc
            elif line:
                pc += 4
        
        # Second pass: generate instructions
        pc = 0
        hex_instructions = []
        
        for line in lines:
            line = line.strip()
            if not line or line.startswith('#') or line.endswith(':'):
                continue
            
            # Remove comments (but not immediate values starting with #)
            comment_pos = -1
            in_immediate = False
            for i, char in enumerate(line):
                if char == '#':
                    # Check if this # is part of an immediate value
                    if i > 0 and (line[i-1].isspace() or line[i-1] == ','):
                        in_immediate = True
                        continue
                    elif not in_immediate:
                        comment_pos = i
                        break
                elif char.isspace() and in_immediate:
                    in_immediate = False
            
            if comment_pos >= 0:
                line = line[:comment_pos].strip()
            
            # Parse instruction
            parts = line.split()
            if not parts:
                continue
                
            opcode = parts[0].upper()
            operands = []
            
            if len(parts) > 1:
                operand_str = ' '.join(parts[1:])
                # Special handling for memory operands
                if '[' in operand_str and ']' in operand_str:
                    # Find the memory operand and keep it together
                    bracket_start = operand_str.find('[')
                    bracket_end = operand_str.find(']') + 1
                    before_bracket = operand_str[:bracket_start].strip()
                    memory_op = operand_str[bracket_start:bracket_end].strip()
                    after_bracket = operand_str[bracket_end:].strip()
                    
                    operands = []
                    if before_bracket.rstrip(','):
                        operands.append(before_bracket.rstrip(','))
                    operands.append(memory_op)
                    if after_bracket.lstrip(','):
                        operands.append(after_bracket.lstrip(','))
                else:
                    operands = [op.strip() for op in operand_str.split(',') if op.strip()]
            
            try:
                instruction = self.encode_instruction(opcode, operands, pc)
                hex_instructions.append(f"{instruction:08X}")
                pc += 4
            except Exception as e:
                print(f"Error assembling line '{line}': {e}")
                hex_instructions.append("00000000")
                pc += 4
        
        return hex_instructions

def main():
    if len(sys.argv) != 2:
        print("Usage: python3 compile_asm.py <assembly_file>")
        sys.exit(1)
    
    asm_file = sys.argv[1]
    assembler = ARM64Assembler()
    
    try:
        hex_instructions = assembler.assemble(asm_file)
        
        with open('program.hex', 'w') as f:
            for i, hex_instr in enumerate(hex_instructions):
                f.write(f"{hex_instr}\n")
        
        print(f"Successfully assembled {asm_file} to program.hex")
        print(f"Generated {len(hex_instructions)} instructions")
        
        # Also print first few instructions for verification
        print("\nFirst few instructions:")
        for i, hex_instr in enumerate(hex_instructions[:8]):
            print(f"0x{i*4:03X}: {hex_instr}")
            
    except Exception as e:
        print(f"Assembly failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()