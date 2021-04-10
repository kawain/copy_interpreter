import sys
from token_ import TokenType
from lexer_ import Lexer

PROMPT = ">> "


def _print(lex):
    while True:
        tok = lex.next_token()
        if tok.token_type == TokenType.EOF:
            break
        print(f"{{Type:{tok.token_type} Literal:{tok.literal}}}")


def start():

    try:
        while True:
            print(PROMPT, end="")
            line = input()
            lex = Lexer(input=line)
            _print(lex)
    except KeyboardInterrupt:
        sys.exit()
