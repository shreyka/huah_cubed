"""

This file will take in a .song file, formatted in the following way:

for each block: X Y TIME COLOR DIRECTION

where X [0, 3599]
where Y [0, 3599]
where time [0, 262143], and each represents 10 milliseconds
where color -> B, R
where direction U, R, D, L, A

The file will output a FPGA friendly .mem file to read, of hex padded to 48 bits each

RAM_DEPTH=MAX_BLOCK_SIZE+1=11
RAM_WIDTH=48 -> there are 48 bits in our data

"""

import sys
import os

VALID_X = (0, 3599)
VALID_Y = (0, 3599)
VALID_TIME = (0, 262143)
VALID_COLORS = ["B", "R"]
VALID_DIRECTIONS = ["U", "R", "D", "L", "A"]

MAX_BLOCK_SIZE = 256

def is_int(val):
    return val.isdigit()

def verify_file(filename):
    valid = True
    last_time = -1
    with open(filename, "r") as file:
        for i, line in enumerate(file.readlines()):
            data = line.strip().split(" ")
            if len(data) != 5:
                print(f"Malformed statement at line {i}: not enough statements")
                valid = False
            else:
                if not is_int(data[0]) or not is_int(data[1]) or not is_int(data[2]):
                    print(f"Malformed statement at line {i}: invalid X, Y, or time")
                    valid = False
                if data[3] not in VALID_COLORS:
                    print(f"Malformed statement at line {i}: invalid color")
                    valid = False
                if data[4] not in VALID_DIRECTIONS:
                    print(f"Malformed statement at line {i}: invalid direction")
                    valid = False

                if valid:
                    x = int(data[0])
                    y = int(data[1])
                    time = int(data[2])

                    if not (x >= VALID_X[0] and x <= VALID_X[1]):
                        print(f"Malformed statement at line {i}: invalid x range")
                        valid = False
                    if not (y >= VALID_Y[0] and x <= VALID_Y[1]):
                        print(f"Malformed statement at line {i}: invalid y range")
                        valid = False
                    if not (time >= VALID_TIME[0] and x <= VALID_TIME[1]):
                        print(f"Malformed statement at line {i}: invalid time range")
                        valid = False
                    
                    if time < last_time:
                        print(f"Malformed statement at line {i}: time must be equal or increasing")
                        valid = False
                    last_time = time
    
    return valid

# convert line from data to HEX
def convert_line(line):
    data = line.strip().split(" ")

    x = int(data[0])
    y = int(data[1])
    time = int(data[2])
    color = VALID_COLORS.index(data[3])
    direction = VALID_DIRECTIONS.index(data[4])

    # pad to 48 bits
    binary = f"{0:02b}{x:012b}{y:012b}{time:018b}{color:01b}{direction:03b}"
    return f"{int(binary, 2):0{12}x}"

def convert_file(filename):
    if not os.path.exists(filename):
        print("File not found")
        return
    
    if verify_file(filename):
        with open("../../data/out.mem", "w") as file_out:
            lines = []
            with open(filename, "r") as file:
                for line in file.readlines():
                    lines.append(convert_line(line))
            # pass in how many lines exist
            lines.insert(0, f"{len(lines):0{12}x}")
            # pad with 0s until we reach MAX_BLOCK_SIZE blocks
            for i in range(MAX_BLOCK_SIZE + 1 - len(lines)):
                lines.append(f"{0:0{12}x}")
            file_out.write("\n".join(lines))
        print("Done. Saved to data/out.mem")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: {0} <song file>.song".format(sys.argv[0]))
    else:
        filename = sys.argv[1]

        convert_file(filename)