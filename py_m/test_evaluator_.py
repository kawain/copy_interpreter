# python -m unittest test_evaluator_.TestEvaluator.test_FunctionObject
import unittest
import lexer_
import parser_
import object_
import evaluator_
import env_


class TestEvaluator(unittest.TestCase):

    def test_Eval(self, input):
        lex = lexer_.Lexer(input)
        p = parser_.Parser(lex)
        program = p.parse_program()
        env = env_.Environment()

        return evaluator_.Eval(program, env)

    def test_IntegerObject(self, obj, expected):
        assert type(obj) is object_.Integer
        assert obj.value == expected
        return True

    def test_FloatObject(self, obj, expected):
        assert type(obj) is object_.Float
        assert obj.value == expected
        return True

    def test_BooleanObject(self, obj, expected):
        assert type(obj) is object_.Boolean
        assert obj.value == expected
        return True

    def test_EvalIntegerExpression(self):
        tests = [
            ("5", 5),
            ("10", 10),
            ("-5", -5),
            ("-10", -10),
            ("5 + 5 + 5 + 5 - 10", 10),
            ("2 * 2 * 2 * 2 * 2", 32),
            ("-50 + 100 + -50", 0),
            ("5 * 2 + 10", 20),
            ("5 + 2 * 10", 25),
            ("20 + 2 * -10", 0),
            ("50 / 2 * 2 + 10", 60),
            ("2 * (5 + 10)", 30),
            ("3 * 3 * 3 + 10", 37),
            ("3 * (3 * 3) + 10", 37),
            ("(5 + 10 * 2 + 15 / 3) * 2 + -10", 50),
        ]

        for v in tests:
            evaluated = self.test_Eval(v[0])
            assert self.test_IntegerObject(evaluated, v[1])

    def test_EvalFloatExpression(self):
        tests = [
            ("5.", 5.0),
            ("3.14", 3.14),
            ("-3.14", -3.14),
            ("-.14", -0.14),
        ]

        for v in tests:
            evaluated = self.test_Eval(v[0])
            assert self.test_FloatObject(evaluated, v[1])

    def test_EvalBooleanExpression(self):
        tests = [
            ("true", True),
            ("false", False),
            ("1 < 2", True),
            ("1 > 2", False),
            ("1 < 1", False),
            ("1 > 1", False),
            ("1 == 1", True),
            ("1 != 1", False),
            ("1 == 2", False),
            ("1 != 2", True),
            ("true == true", True),
            ("false == false", True),
            ("true == false", False),
            ("true != false", True),
            ("false != true", True),
            ("(1 < 2) == true", True),
            ("(1 < 2) == false", False),
            ("(1 > 2) == true", False),
            ("(1 > 2) == false", True),
        ]

        for v in tests:
            evaluated = self.test_Eval(v[0])
            assert self.test_BooleanObject(evaluated, v[1])

    def test_BangOperator(self):
        tests = [
            ("!true", False),
            ("!false", True),
            ("!5", False),
            ("!!true", True),
            ("!!false", False),
            ("!!5", True),
        ]
        for v in tests:
            evaluated = self.test_Eval(v[0])
            assert self.test_BooleanObject(evaluated, v[1])

    def test_NullObject(self, obj):
        assert obj == evaluator_.NULL
        return True

    def test_IfElseExpressions(self):
        tests = [
            ("if (true) { 10 }", 10),
            ("if (false) { 10 }", None),
            ("if (1) { 10 }", 10),
            ("if (1 < 2) { 10 }", 10),
            ("if (1 > 2) { 10 }", None),
            ("if (1 > 2) { 10 } else { 20 }", 20),
            ("if (1 < 2) { 10 } else { 20 }", 10),
        ]

        for v in tests:
            evaluated = self.test_Eval(v[0])
            try:
                integer = int(v[1])
                assert self.test_IntegerObject(evaluated, integer)
            except Exception as e:
                _ = e
                assert self.test_NullObject(evaluated)

    def test_ReturnStatements(self):
        tests = [
            ("return 10;", 10),
            ("return 10; 9;", 10),
            ("return 2 * 5; 9;", 10),
            ("9; return 2 * 5; 9;", 10),
            ("""
if (10 > 1) {
  if (10 > 1) {
    return 10;
  }

  return 1;
}""",
             10
             ),
        ]

        for v in tests:
            evaluated = self.test_Eval(v[0])
            assert self.test_IntegerObject(evaluated, v[1])

    def test_ErrorHandling(self):
        tests = [
            (
                "5 + true;",
                "type mismatch: INTEGER + BOOLEAN",
            ),
            (
                "5 + true; 5;",
                "type mismatch: INTEGER + BOOLEAN",
            ),
            (
                "-true",
                "unknown operator: -BOOLEAN",
            ),
            (
                "true + false;",
                "unknown operator: BOOLEAN + BOOLEAN",
            ),
            # (
            # "true + false + true + false;",
            # "unknown operator: BOOLEAN + BOOLEAN",
            # ),
            (
                "5; true + false; 5",
                "unknown operator: BOOLEAN + BOOLEAN",
            ),
            (
                "if (10 > 1) { true + false; }",
                "unknown operator: BOOLEAN + BOOLEAN",
            ),
            ("""
if (10 > 1) {
  if (10 > 1) {
    return true + false;
  }

  return 1;
}
""",
             "unknown operator: BOOLEAN + BOOLEAN",
             ),
            (
                "foobar",
                "identifier not found: foobar",
            ),
        ]

        for v in tests:
            evaluated = self.test_Eval(v[0])
            assert type(evaluated) is object_.Error
            assert evaluated.message == v[1]

    def test_LetStatements(self):
        tests = [
            ("let a = 5; a;", 5),
            ("let a = 5 * 5; a;", 25),
            ("let a = 5; let b = a; b;", 5),
            ("let a = 5; let b = a; let c = a + b + 5; c;", 15),
        ]

        for v in tests:
            evaluated = self.test_Eval(v[0])
            assert self.test_IntegerObject(evaluated, v[1])

    def test_FunctionObject(self):
        input = "fn(x) { x + 2; };"
        evaluated = self.test_Eval(input)
        assert type(evaluated) is object_.Function
        assert len(evaluated.parameters) == 1
        assert evaluated.parameters[0].string() == "x"
        expectedBody = "(x + 2)"
        assert evaluated.body.string() == expectedBody
