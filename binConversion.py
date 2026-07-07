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

bits = int(input("Bits: "))
number = int(input("Number: "))

print(intToBinary(bits, number))