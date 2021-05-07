import sys
import token_
import lexer_
import parser_
import evaluator_


PROMPT = ">> "


def _print(lex):
    while True:
        tok = lex.next_token()
        if tok.token_type == token_.TokenType.EOF:
            break
        print(f"{{Type:{tok.token_type} Literal:{tok.literal}}}")


def print_parser_errors(errors):
    out = "Woops! We ran into some monkey business here!\n"
    out += " parser errors:\n"
    for v in errors:
        out += f"\t{v}\n"
    return out


def start():

    try:
        while True:
            print(PROMPT, end="")
            line = input()
            lex = lexer_.Lexer(line)
            p = parser_.Parser(lex)
            program = p.parse_program()
            if len(p.Errors()) != 0:
                print(print_parser_errors(p.Errors()))
                continue

            evaluated = evaluator_.Eval(program)
            if evaluated is not None:
                print(evaluated.Inspect())

    except KeyboardInterrupt:
        sys.exit()
