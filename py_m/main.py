import getpass
from repl_ import start


name = getpass.getuser()
print(f"Hello {name}! This is the Monkey programming language!")
print("Feel free to type in commands")

start()
