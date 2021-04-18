import sys

try:
    while True:
        print(">> ", end="")
        line = input()
        print(line)
except KeyboardInterrupt:
    sys.exit()
except Exception as e:
    print(e)
