import sys
import parser_


try:
    while True:
        print(">> ", end="")
        line = input()
        p = parser_.new_parser(line)
        node = p.expr()
        evaluated = parser_.eval(node)
        print(evaluated)

except KeyboardInterrupt:
    sys.exit()
except Exception as e:
    print(e)
