# python -m unittest test_parser_.TestParser.test_parse_return_statement
import unittest
import lexer_
import parser_


class TestParser(unittest.TestCase):
    def check_parser_errors(self):
        errors = self.obj.errors
        if len(errors) == 0:
            return

        print(f"parser has {len(errors)} errors")
        for v in errors:
            print(f"parser error: {v}")

    def test_parse_return_statement(self):
        line = """
return 5;
return 10;
return 838383;
        """

        lex = lexer_.Lexer(input=line)
        self.obj = parser_.Parser(lex)
        self.program = self.obj.parse_program()

        for v in self.program.statements:
            print(v.token_literal())

    def test_parse_let_statement(self):
        line = """
let x = 5;
let ssss = 10;
let foobar = 838383;
        """

        lex = lexer_.Lexer(input=line)
        self.obj = parser_.Parser(lex)
        self.program = self.obj.parse_program()

        for v in self.program.statements:
            print(v.token_literal())


if __name__ == '__main__':
    unittest.main()
