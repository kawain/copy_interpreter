# python -m unittest test_parser_.TestParser.test_function_literal_parsing
import unittest
import ast_  # noqa
import lexer_
import parser_


class TestParser(unittest.TestCase):

    def check_parser_errors(self, obj):
        errors = obj.errors
        if len(errors) == 0:
            return True
        print(f"parser has {len(errors)} errors")
        for v in errors:
            print(f"parser error: {v}")
        return False

    def test_let_statement(self, s, name):
        assert s.token_literal() == "let",\
            f"s.TokenLiteral not 'let'. got={s.token_literal()}"
        assert type(s) is ast_.LetStatement,\
            f"s not LetStatement. got={type(s)}"
        assert s.name.value == name,\
            f"s.name not {name}. got={s.name.value}"
        assert s.name.token_literal() == name,\
            f"s.name not {name}. got={s.name.token_literal()}"
        return True

    def test_integer_literal(self, il, value):
        assert type(il) is ast_.IntegerLiteral,\
            f"il not IntegerLiteral. got={type(il)}"
        assert il.value == value,\
            f"value not {value}. got={il.value}"
        assert il.token_literal() == str(value),\
            f"TokenLiteral not {value}. got={il.token_literal()}"
        return True

    def test_identifier(self, exp, value):
        assert type(exp) is ast_.Identifier,\
            f"exp not Identifier. got={type(exp)}"
        assert exp.value == value,\
            f"ident.Value not {value}. got={exp.value}"
        assert exp.token_literal() == value,\
            f"ident.TokenLiteral not {value}. got={exp.token_literal()}"
        return True

    def test_boolean_literal(self, exp, value):
        assert type(exp) is ast_.Boolean,\
            f"exp not Boolean. got={type(exp)}"
        assert exp.value == value,\
            f"Value not {value}. got={exp.value}"
        # python の True False を小文字に変換
        assert exp.token_literal() == str(value).lower(),\
            f"TokenLiteral not {value}. got={exp.token_literal()}"
        return True

    def test_literal_expression(self, exp, expected):
        if type(expected) is int:
            return self.test_integer_literal(exp, int(expected))
        elif type(expected) is str:
            return self.test_identifier(exp, expected)
        elif type(expected) is bool:
            return self.test_boolean_literal(exp, bool(expected))
        return False

    def test_let_statements(self):
        tests = [
            ("let x = 5;", "x", 5),
            ("let y = true;", "y", True),
            ("let foobar = y;", "foobar", "y"),
        ]

        for v in tests:
            lex = lexer_.Lexer(input=v[0])
            obj = parser_.Parser(lex)
            program = obj.parse_program()

            assert self.check_parser_errors(obj)
            assert len(program.statements) == 1,\
                f"program.Statements does not contain 1 statements. got={len(program.statements)}"

            stmt = program.statements[0]
            assert self.test_let_statement(stmt, v[1])
            val = stmt.value
            assert self.test_literal_expression(val, v[2])

    def test_return_statements(self):
        tests = [
            ("return 5;", 5),
            ("return true;", True),
            ("return foobar;", "foobar"),
        ]

        for v in tests:
            lex = lexer_.Lexer(input=v[0])
            obj = parser_.Parser(lex)
            program = obj.parse_program()

            assert self.check_parser_errors(obj)
            assert len(program.statements) == 1,\
                f"program.Statements does not contain 1 statements. got={len(program.statements)}"

            stmt = program.statements[0]
            assert type(stmt) is ast_.ReturnStatement
            assert stmt.token_literal() == "return"
            assert self.test_literal_expression(stmt.return_value, v[1])

    def test_identifier_expression(self):
        input = "foobar;"
        lex = lexer_.Lexer(input=input)
        obj = parser_.Parser(lex)
        program = obj.parse_program()
        assert self.check_parser_errors(obj)
        assert len(program.statements) == 1
        stmt = program.statements[0]
        assert type(stmt) is ast_.ExpressionStatement
        ident = stmt.expression
        assert type(ident) is ast_.Identifier
        assert ident.value == "foobar"
        assert ident.token_literal() == "foobar"

    def test_integer_literal_expression(self):
        input = "5;"
        lex = lexer_.Lexer(input=input)
        obj = parser_.Parser(lex)
        program = obj.parse_program()
        assert self.check_parser_errors(obj)
        assert len(program.statements) == 1
        stmt = program.statements[0]
        assert type(stmt) is ast_.ExpressionStatement
        literal = stmt.expression
        assert type(literal) is ast_.IntegerLiteral
        assert literal.value == 5
        assert literal.token_literal() == "5"

    def test_parsing_prefix_expressions(self):
        tests = [
            ("!5;", "!", 5),
            ("-15;", "-", 15),
            ("!foobar;", "!", "foobar"),
            ("-foobar;", "-", "foobar"),
            ("!true;", "!", True),
            ("!false;", "!", False),
        ]

        for v in tests:
            lex = lexer_.Lexer(input=v[0])
            obj = parser_.Parser(lex)
            program = obj.parse_program()
            assert self.check_parser_errors(obj)
            assert len(program.statements) == 1
            stmt = program.statements[0]
            assert type(stmt) is ast_.ExpressionStatement
            exp = stmt.expression
            assert type(exp) is ast_.PrefixExpression
            assert exp.operator == v[1]
            assert self.test_literal_expression(exp.right, v[2])

    def testInfixExpression(self, exp, left, operator, right):
        assert type(exp) is ast_.InfixExpression
        assert self.test_literal_expression(exp.left, left)
        assert exp.operator == operator
        assert self.test_literal_expression(exp.right, right)
        return True

    def test_parsing_infix_expressions(self):
        tests = [
            ("5 + 5;", 5, "+", 5),
            ("5 - 5;", 5, "-", 5),
            ("5 * 5;", 5, "*", 5),
            ("5 / 5;", 5, "/", 5),
            ("5 > 5;", 5, ">", 5),
            ("5 < 5;", 5, "<", 5),
            ("5 == 5;", 5, "==", 5),
            ("5 != 5;", 5, "!=", 5),
            ("foobar + barfoo;", "foobar", "+", "barfoo"),
            ("foobar - barfoo;", "foobar", "-", "barfoo"),
            ("foobar * barfoo;", "foobar", "*", "barfoo"),
            ("foobar / barfoo;", "foobar", "/", "barfoo"),
            ("foobar > barfoo;", "foobar", ">", "barfoo"),
            ("foobar < barfoo;", "foobar", "<", "barfoo"),
            ("foobar == barfoo;", "foobar", "==", "barfoo"),
            ("foobar != barfoo;", "foobar", "!=", "barfoo"),
            ("true == true", True, "==", True),
            ("true != false", True, "!=", False),
            ("false == false", False, "==", False),
        ]

        for v in tests:
            lex = lexer_.Lexer(input=v[0])
            obj = parser_.Parser(lex)
            program = obj.parse_program()
            assert self.check_parser_errors(obj)
            assert len(program.statements) == 1
            stmt = program.statements[0]
            assert type(stmt) is ast_.ExpressionStatement
            exp = stmt.expression
            assert type(exp) is ast_.InfixExpression
            assert self.testInfixExpression(exp, v[1], v[2], v[3])

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
            # (
            #     "a + add(b * c) + d",
            #     "((a + add((b * c))) + d)",
            # ),
            # (
            #     "add(a, b, 1, 2 * 3, 4 + 5, add(6, 7 * 8))",
            #     "add(a, b, 1, (2 * 3), (4 + 5), add(6, (7 * 8)))",
            # ),
            # (
            #     "add(a + b + c * d / f + g)",
            #     "add((((a + b) + ((c * d) / f)) + g))",
            # ),
        ]

        for v in tests:
            lex = lexer_.Lexer(input=v[0])
            obj = parser_.Parser(lex=lex)
            program = obj.parse_program()
            assert self.check_parser_errors(obj)
            actual = program.string()
            assert actual == v[1]

    def test_boolean_expression(self):
        tests = [
            ("true;", True),
            ("false;", False),
        ]

        for v in tests:
            lex = lexer_.Lexer(input=v[0])
            obj = parser_.Parser(lex=lex)
            program = obj.parse_program()
            assert self.check_parser_errors(obj)
            assert len(program.statements) == 1
            stmt = program.statements[0]
            assert type(stmt) is ast_.ExpressionStatement
            boolean = stmt.expression
            assert type(boolean) is ast_.Boolean
            assert boolean.value == v[1]

    def test_if_expression(self):
        input = "if (x < y) { x }"
        lex = lexer_.Lexer(input)
        obj = parser_.Parser(lex=lex)
        program = obj.parse_program()
        assert self.check_parser_errors(obj)
        assert len(program.statements) == 1
        stmt = program.statements[0]
        assert type(stmt) is ast_.ExpressionStatement
        exp = stmt.expression
        assert type(exp) is ast_.IfExpression
        assert self.testInfixExpression(exp.condition, "x", "<", "y")
        assert len(exp.consequence.statements) == 1
        consequence = exp.consequence.statements[0]
        assert type(consequence) is ast_.ExpressionStatement
        assert self.test_identifier(consequence.expression, "x")
        assert exp.alternative is None

    def test_if_else_expression(self):
        input = "if (x < y) { x } else { y }"
        lex = lexer_.Lexer(input)
        obj = parser_.Parser(lex=lex)
        program = obj.parse_program()
        assert self.check_parser_errors(obj)
        assert len(program.statements) == 1
        stmt = program.statements[0]
        assert type(stmt) is ast_.ExpressionStatement
        exp = stmt.expression
        assert type(exp) is ast_.IfExpression
        assert self.testInfixExpression(exp.condition, "x", "<", "y")
        assert len(exp.consequence.statements) == 1
        consequence = exp.consequence.statements[0]
        assert type(consequence) is ast_.ExpressionStatement
        assert self.test_identifier(consequence.expression, "x")
        assert len(exp.alternative.statements) == 1
        alternative = exp.alternative.statements[0]
        assert type(alternative) is ast_.ExpressionStatement
        assert self.test_identifier(alternative.expression, "y")

    def test_function_literal_parsing(self):
        line = "fn(x, y) { x + y; }"

        lex = lexer_.Lexer(input=line)
        obj = parser_.Parser(lex)
        program = obj.parse_program()
        assert self.check_parser_errors(obj)
        assert len(program.statements) == 1
        stmt = program.statements[0]
        assert type(stmt) is ast_.ExpressionStatement
        function = stmt.expression
        assert type(function) is ast_.FunctionLiteral
        assert len(function.parameters) == 2
        assert self.test_literal_expression(function.parameters[0], "x")
        assert self.test_literal_expression(function.parameters[1], "y")
        assert len(function.body.statements) == 1
        body_stmt = function.body.statements[0]
        assert type(body_stmt) is ast_.ExpressionStatement
        assert self.testInfixExpression(body_stmt.expression, "x", "+", "y")

        for v in program.statements:
            print(v.string())
            print(type(v))
            print(type(v.expression))
            print(type(v.expression.token))
            print(type(v.expression.string()))
            print(v.expression.string())

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

    def test_if(self):
        line = """
if (x < y) { x }
if (5 < 10) { (1 + 2) * 3 }
"""

        lex = lexer_.Lexer(input=line)
        obj = parser_.Parser(lex)
        program = obj.parse_program()
        print(program)
        self.check_parser_errors(obj)

        for v in program.statements:
            print(v.string())

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

    def test_function_parameter_parsing(self):
        tests = [
            ["fn() {};", []],
            ["fn(x) {};", ["x"]],
            ["fn(x, y, z) {};", ["x", "y", "z"]],
        ]

        for v in tests:
            lex = lexer_.Lexer(input=v[0])
            obj = parser_.Parser(lex)
            program = obj.parse_program()
            self.check_parser_errors(obj)
            print(program.statements[0].expression)
            assert type(
                program.statements[0].expression) is ast_.FunctionLiteral, "型違い"
            obj = program.statements[0].expression
            # キャスト
            obj.__class__ = ast_.FunctionLiteral
            for v2, v3 in zip(obj.parameters, v[1]):
                assert v2.value == v3, "エラー"


if __name__ == '__main__':
    unittest.main()
