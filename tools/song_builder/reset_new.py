with open("reason_new_new.song", "w") as f:
    with open("reason_new.song", "r") as fr:
        for line in fr.readlines():
            line_new_split = line.rstrip().split(" ")
            f.write(f"{line_new_split[0]} {int(line_new_split[1]) + 100} {line_new_split[2]} {line_new_split[3]} {line_new_split[4]}\n")