# python -m unittest test_parser_.TestParser.test_OperatorPrecedenceParsing
import unittest
import ast_  # noqa
import lexer_
import parser_


class TestParser(unittest.TestCase):
    def check_parser_errors(self, obj):
        errors = obj.errors
        if len(errors) == 0:
            return
        print(f"parser has {len(errors)} errors")
        for v in errors:
            print(f"parser error: {v}")

    def test_OperatorPrecedenceParsing(self):
        tests = [
            (
                "1 + 2 + 3",
                "((1 + 2) + 3)",
            ),
            (
                "-a * b",
                "((-a) * b)",
            ),
            (
                "!-a",
                "(!(-a))",
            ),
            (
                "a + b + c",
                "((a + b) + c)",
            ),
            (
                "a + b - c",
                "((a + b) - c)",
            ),
            (
                "a * b * c",
                "((a * b) * c)",
            ),
            (
                "a * b / c",
                "((a * b) / c)",
            ),
            (
                "a + b / c",
                "(a + (b / c))",
            ),
            (
                "a + b * c + d / e - f",
                "(((a + (b * c)) + (d / e)) - f)",
            ),
            (
                "3 + 4; -5 * 5",
                "(3 + 4)((-5) * 5)",
            ),
            (
                "5 > 4 == 3 < 4",
                "((5 > 4) == (3 < 4))",
            ),
            (
                "5 < 4 != 3 > 4",
                "((5 < 4) != (3 > 4))",
            ),
            (
                "3 + 4 * 5 == 3 * 1 + 4 * 5",
                "((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))",
            ),
            (
                "true",
                "true",
            ),
            (
                "false",
                "false",
            ),
            (
                "3 > 5 == false",
                "((3 > 5) == false)",
            ),
            (
                "3 < 5 == true",
                "((3 < 5) == true)",
            ),

            (
                "1 + (2 + 3) + 4",
                "((1 + (2 + 3)) + 4)",
            ),
            (
                "(5 + 5) * 2",
                "((5 + 5) * 2)",
            ),
            (
                "2 / (5 + 5)",
                "(2 / (5 + 5))",
            ),
            (
                "(5 + 5) * 2 * (5 + 5)",
                "(((5 + 5) * 2) * (5 + 5))",
            ),
            (
                "-(5 + 5)",
                "(-(5 + 5))",
            ),
            (
                "!(true == true)",
                "(!(true == true))",
            ),
        ]

        for v in tests:
            lex = lexer_.Lexer(input=v[0])
            obj = parser_.Parser(lex=lex)
            program = obj.parse_program()
            self.check_parser_errors(obj)
            actual = program.string()
            self.assertEqual(v[1], actual)
            print("\n---> ", program.string())

    def test_infix(self):
        line = """
5 + 5.;
5 - 5.;
5 * 5.;
5 / 5.;
5 > 5.;
5 < 5.;
5 == 5.;
5 != 5.;
        """

        lex = lexer_.Lexer(input=line)
        obj = parser_.Parser(lex)
        program = obj.parse_program()
        print(program)
        print(len(program.statements))
        self.check_parser_errors(obj)

        for v in program.statements:
            print(v.string())
            print(v.expression.operator)
            print(v.expression.left.value)
            print(v.expression.right.value)
            print("-" * 30)

    def test_prefix(self):
        line = """
!525;
-3.1415;
        """

        lex = lexer_.Lexer(input=line)
        obj = parser_.Parser(lex)
        program = obj.parse_program()
        print(program)
        self.check_parser_errors(obj)

        for v in program.statements:
            print(v.string())
            print(v.expression.operator)
            print(v.expression.right.value)

    def test_parse_return_statement(self):
        line = """
return 5;
return 10;
return 838383;
        """

        lex = lexer_.Lexer(input=line)
        obj = parser_.Parser(lex)
        program = obj.parse_program()
        self.check_parser_errors(obj)

        for v in program.statements:
            print(v.token_literal())

    def test_parse_let_statement(self):
        line = """
let x = 5;
let ssss = 10;
let foobar = 838383;
        """

        lex = lexer_.Lexer(input=line)
        obj = parser_.Parser(lex)
        program = obj.parse_program()
        self.check_parser_errors(obj)

        for v in program.statements:
            print(v.token_literal())

    def test_parse_identifier(self):
        line = """foobar;"""

        lex = lexer_.Lexer(input=line)
        obj = parser_.Parser(lex)
        program = obj.parse_program()
        self.check_parser_errors(obj)

        for v in program.statements:
            print(v.string())

    def test_parse_int_float(self):
        line = """
5;
3.14;
"""

        lex = lexer_.Lexer(input=line)
        obj = parser_.Parser(lex)
        program = obj.parse_program()
        self.check_parser_errors(obj)

        for v in program.statements:
            print(v.string())
            print(type(v))
            print(type(v.expression))

    def test_parse_prefix_expression(self):
        line = """
!5;
-3.14;
"""

        lex = lexer_.Lexer(input=line)
        obj = parser_.Parser(lex)
        program = obj.parse_program()
        self.check_parser_errors(obj)

        for v in program.statements:
            print(v.string())
            print(type(v))
            print(type(v.expression))
            print(type(v.expression.operator))
            print(type(v.expression.right))


if __name__ == '__main__':
    unittest.main()
