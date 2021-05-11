import sys
import getpass
from repl_ import start

# 再帰回数の上限を変更
sys.setrecursionlimit(2000)

name = getpass.getuser()
print(f"Hello {name}! This is the Monkey programming language!")
print("Feel free to type in commands")

start()
