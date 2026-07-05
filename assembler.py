import sys

print(sys.argv)
# Usage: python3 assembler.py infile.s outfile.hex
if len(sys.argv) < 3:
    raise ("Incorrect number of arguments")
filepath = sys.argv[1]
out = sys.argv[2]

INSTRUCTIONS = ["add", "and", "not", "ld", "ldr",
                 "ldi", "lea", "st", "str", "sti",
                   "brn", "brz", "brp", "brnz", 
                   "brzp", "brnp", "brnzp", "jmp",
                     "halt"]

OPCODES = ["0001", "0101", "1001", "0010", "0110", "1010", 
           "1110", "0011", "0111", "1011", "0000", "1100",
           "1111"]

def isInteger(token):
    try:
        int(token)
        return True
    except ValueError:
        return False
    
def isValidTokens(tokens):
    for i in range(len(tokens)):
        if len(tokens[i]) == 0:
            print("Empty Token.")
            return False

    if len(tokens) > 2:
        for i in range(1, len(tokens)-1):
            token = tokens[i]
            if (token[-1] != ','):
                print("Tokens should be comma separated")
                return False
    return True
    
def isValidRegister(token):
    t = token.lower()
    if (len(t) != 2):
        return False
    if t[0] != 'r':
        return False
    if not t[1].isdigit():
        return False
    reg = int(t[1])
    if reg < 0 or reg > 7:
        return False
    return True
    

def validateInstruction(tokens):
    operation = tokens[0].lower()
    match operation:
        case "add":
            if len(tokens) != 4:
                return False
            if not isValidRegister(tokens[1]):
                return False
            if not isValidRegister(tokens[2]):
                return False
            if isValidRegister(tokens[3]) or isInteger(tokens[3]):
                return True
            return False
        case "and":
            if len(tokens) != 4:
                return False
            if not isValidRegister(tokens[1]):
                return False
            if not isValidRegister(tokens[2]):
                return False
            if isValidRegister(tokens[3]) or isInteger(tokens[3]):
                return True
            return False
        case "not":
            if len(tokens) != 3:
                return False
            if isValidRegister(tokens[1]) and isValidRegister(tokens[2]):
                return True
            return False
        case "ld":
            if len(tokens) != 3:
                return False
            if isValidRegister(tokens[1]):
                return True
            return False
        case "ldr":
            if len(tokens) != 4:
                return False
            if isValidRegister(tokens[1]) and isValidRegister(tokens[2]) and isInteger(tokens[3]):
                return True
            return False
        case "ldi":
            if len(tokens) != 3:
                return False
            if isValidRegister(tokens[1]):
                return True
            return False
        case "lea":
            if len(tokens) != 3:
                return False
            if isValidRegister(tokens[1]):
                return True
            return False
        case "st":
            if len(tokens) != 3:
                return False
            if isValidRegister(tokens[1]):
                return True
            return False
        case "str":
            if len(tokens) != 4:
                return False
            if isValidRegister(tokens[1]) and isValidRegister(tokens[2]) and isInteger(tokens[3]):
                return True
            return False
        case "sti":
            if len(tokens) != 3:
                return False
            if isValidRegister(tokens[1]):
                return True
            return False
        case "brn" | "brz" | "brp" | "brnz" | "brnp" | "brzp" | "brnzp":
            if len(tokens) != 2:
                return False
            return True
        case "jmp":
            if len(tokens) != 2:
                return False
            return True
        case "halt":
            if len(tokens) != 1:
                return False
            return True 
    print(f"Instruction {operation} not Found")


f = open(filepath, "r")
lines = f.readlines()
f.close()

instructions = []
labels = {}

i = 0
# Cleanup
for line_number, line in enumerate(lines):
    # Determine if instruction or label or some bs
    tokens = line.strip().split(" ")
    if tokens[0].lower().strip() in INSTRUCTIONS:
        # This is an instruction
        if not isValidTokens(tokens):
            print(f"Invalid Instruction Format on line {line_number}.\nLine: {line}")
            raise Exception()
        tokens = [token.replace(',', '') for token in tokens]
        if validateInstruction(tokens):
            instructions.append((i, tokens))
        else:
            raise Exception(f"Syntax Error on line {line_number}.\nLine: {line}")
        i += 1
    elif len(tokens) == 1 and len(tokens[0]) > 1 and tokens[0].strip()[-1] == ':':
        # This is a label
        label = tokens[0][:-1]
        labels[label] = i
    else:
        print("OTHER")

def intToBinary(bits, num):
    lowest = -1 * pow(2, bits-1)
    highest = pow(2,bits-1) - 1
    if num < lowest or num > highest:
        print(f"Number {num} out of range for {bits} bits.")
        raise Exception()
    
    bitString = ''
    value = 0
    if num < 0:
        bitString += '1'
        value += -1 * pow(2,bits-1)
    else:
        bitString += '0'

    for i in range(1, bits):
        if value + pow(2,bits-i-1) <= num:
            bitString += '1'
            value += pow(2,bits-i-1)
        else:
            bitString += '0'
    return bitString


def intToUnsignedBinary(bits, num):
    lowest = 0
    highest = pow(2,bits) - 1
    if num < lowest or num > highest:
        print(f"Number {num} out of range for {bits} bits.")
        raise Exception()
    bitString = ''
    value = 0
    for i in range(0, bits):
        if value + pow(2,bits-i) <= num:
            bitString += '1'
            value += pow(2,bits-i)
        else:
            bitString += '0'
    return bitString
f = open(out, "wb")
for instr in instructions:
    mem_location = instr[0]
    tokens = instr[1]
    operation = tokens[0].lower()
    bitString = ''
    match operation:
        case "add":
            bitString += "0001"
            destReg = int(tokens[1][1:])
            bitString += intToUnsignedBinary(3, destReg)
            srcReg = int(tokens[2][1:])
            bitString += intToUnsignedBinary(3, srcReg)

            if isInteger(tokens[3]):
                bitString += "1"
                bitString += intToBinary(5, int(tokens[3]))
            else:
                bitString += "000"
                bitString += intToUnsignedBinary(3, int(tokens[3][1:]))
        case "and":
            bitString += "0101"
            destReg = int(tokens[1][1:])
            bitString += intToUnsignedBinary(3, destReg)
            srcReg = int(tokens[2][1:])
            bitString += intToUnsignedBinary(3, srcReg)

            if isInteger(tokens[3]):
                bitString += "1"
                bitString += intToBinary(5, int(tokens[3]))
            else:
                bitString += "000"
                bitString += intToUnsignedBinary(3, int(tokens[3][1:]))
        case "not":
            bitString += "0101"
            destReg = int(tokens[1][1:])
            bitString += intToUnsignedBinary(3, destReg)
            srcReg = int(tokens[2][1:])
            bitString += intToUnsignedBinary(3, srcReg)
            bitString += "111111"
        case "ld":
            bitString += "0010"
            destReg = int(tokens[1][1:])
            bitString += intToUnsignedBinary(3, destReg)

            target = tokens[2]
            if target not in labels:
                print(f"Label {target} not defined.")
            target_loc = labels[target]
            npc = mem_location + 1

            offset = target_loc - npc
            bitString += intToBinary(9, offset)
        case "ldr":
            bitString += "0110"
            destReg = int(tokens[1][1:])
            bitString += intToUnsignedBinary(3, destReg)
            baseReg = int(tokens[2][1:])
            bitString += intToUnsignedBinary(3, baseReg)
            bitString += intToBinary(6, int(tokens[3]))
        case "ldi":
            bitString += "1010"
            destReg = int(tokens[1][1:])
            bitString += intToUnsignedBinary(3, destReg)

            target = tokens[2]
            if target not in labels:
                print(f"Label {target} not defined.")
            target_loc = labels[target]
            npc = mem_location + 1

            offset = target_loc - npc
            bitString += intToBinary(9, offset)
        case "lea":
            bitString += "1110"
            destReg = int(tokens[1][1:])
            bitString += intToUnsignedBinary(3, destReg)

            target = tokens[2]
            if target not in labels:
                print(f"Label {target} not defined.")
            target_loc = labels[target]
            npc = mem_location + 1

            offset = target_loc - npc
            bitString += intToBinary(9, offset)
        case "st":
            bitString += "0011"
            destReg = int(tokens[1][1:])
            bitString += intToUnsignedBinary(3, destReg)

            target = tokens[2]
            if target not in labels:
                print(f"Label {target} not defined.")
            target_loc = labels[target]
            npc = mem_location + 1

            offset = target_loc - npc
            bitString += intToBinary(9, offset)
        case "str":
            bitString += "0111"
            destReg = int(tokens[1][1:])
            bitString += intToUnsignedBinary(3, destReg)
            baseReg = int(tokens[2][1:])
            bitString += intToUnsignedBinary(3, baseReg)
            bitString += intToBinary(6, int(tokens[3]))
        case "sti":
            bitString += "1011"
            destReg = int(tokens[1][1:])
            bitString += intToUnsignedBinary(3, destReg)

            target = tokens[2]
            if target not in labels:
                print(f"Label {target} not defined.")
            target_loc = labels[target]
            npc = mem_location + 1

            offset = target_loc - npc
            bitString += intToBinary(9, offset)
        case "brn":
            bitString += "0000"
            bitString += "100"
            npc = mem_location + 1
            target = tokens[1]
            if target not in labels:
                print(f"Label {target} not defined.")
            target_loc = labels[target]
            offset = target_loc - npc
            bitString += intToBinary(9, offset)
        case "brz":
            bitString += "0000"
            bitString += "010"
            npc = mem_location + 1
            target = tokens[1]
            if target not in labels:
                print(f"Label {target} not defined.")
            target_loc = labels[target]
            offset = target_loc - npc
            bitString += intToBinary(9, offset)
        case "brp":
            bitString += "0000"
            bitString += "001"
            npc = mem_location + 1
            target = tokens[1]
            if target not in labels:
                print(f"Label {target} not defined.")
            target_loc = labels[target]
            offset = target_loc - npc
            bitString += intToBinary(9, offset)
        case "brnz":
            bitString += "0000"
            bitString += "110"
            npc = mem_location + 1
            target = tokens[1]
            if target not in labels:
                print(f"Label {target} not defined.")
            target_loc = labels[target]
            offset = target_loc - npc
            bitString += intToBinary(9, offset)
        case "brnp":
            bitString += "0000"
            bitString += "101"
            npc = mem_location + 1
            target = tokens[1]
            if target not in labels:
                print(f"Label {target} not defined.")
            target_loc = labels[target]
            offset = target_loc - npc
            bitString += intToBinary(9, offset)
        case "brzp":
            bitString += "0000"
            bitString += "011"
            npc = mem_location + 1
            target = tokens[1]
            if target not in labels:
                print(f"Label {target} not defined.")
            target_loc = labels[target]
            offset = target_loc - npc
            bitString += intToBinary(9, offset)
        case "brnzp":
            bitString += "0000"
            bitString += "111"
            npc = mem_location + 1
            target = tokens[1]
            if target not in labels:
                print(f"Label {target} not defined.")
            target_loc = labels[target]
            offset = target_loc - npc
            bitString += intToBinary(9, offset)
        case "jmp":
            bitString += "1100"
            bitString += "000"
            baseReg = int(tokens[1][1:])
            bitString += intToUnsignedBinary(3, baseReg)
            bitString += "000000"
        case "halt":
            bitString += "1111"
            bitString += "000000"
            bitString += "100101"
    print(f"{mem_location}: {bitString[0:4]} {bitString[4:8]} {bitString[8:12]} {bitString[12:16]}")
    data = int(bitString, 2).to_bytes(2, byteorder="big")
    f.write(data)
    print(data.hex())
f.close()
print("Output program generated successfully")