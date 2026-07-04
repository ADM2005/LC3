import sys

print(sys.argv)
# Usage: python3 assembler.py infile.s outfile.hex
if len(sys.argv) < 3:
    raise ("Incorrect number of arguments")
filepath = sys.argv[1]
out = sys.argv[2]

f = open(filepath, "r")
