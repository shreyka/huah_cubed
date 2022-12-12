import time
import random
import getch

def diff(now):
    return time.time() - now

name = input("Type in the song name: ")
print("POSSIBLE COMMANDS:")
print("F: red")
print("J: blue")
input("Press enter to begin (type q to finish).")
now = time.time()
colors = []
timestamps = []
while True:
    val = getch.getch()
    if val == "q":
        break
    timestamps.append(int((diff(now)) * 100))
    if val == "f":
        colors.append("R")
    else:
        colors.append("B")
    print(f"{timestamps[-1]}: {len(timestamps)} block(s)")

print(timestamps)

with open(f"{name}.song", "w") as f:
    for i in range(len(timestamps)):
        x = 1800 + (random.randint(0, 200) - 100)
        y = 1800 + (random.randint(0, 150) - 75)
        t = timestamps[i]
        color = colors[i]
        dir_index = random.randint(0, 3)
        if dir_index == 0:
            dir = "U"
        elif dir_index == 1:
            dir = "R"
        elif dir_index == 2:
            dir = "D"
        else:
            dir = "L"
        
        # write line!
        f.write(f"{x} {y} {t} {color} {dir}")
        f.write("\n")

print(f"Done! Saved to {name}.song")