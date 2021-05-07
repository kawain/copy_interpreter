# python -m unittest test_evaluator_.TestEvaluator.test_EvalIntegerExpression
import unittest
import lexer_
import parser_
import object_
import evaluator_


class TestEvaluator(unittest.TestCase):

    def test_Eval(self, input):
        lex = lexer_.Lexer(input)
        p = parser_.Parser(lex)
        program = p.parse_program()
        return evaluator_.Eval(program)

    def test_IntegerObject(self, obj, expected):
        assert type(obj) is object_.Integer
        assert obj.value == expected
        return True

    def test_EvalIntegerExpression(self):
        tests = [
            ("5", 5),
            ("10", 10),
            # ("-5", -5),
            # ("-10", -10),
            # ("5 + 5 + 5 + 5 - 10", 10),
            # ("2 * 2 * 2 * 2 * 2", 32),
            # ("-50 + 100 + -50", 0),
            # ("5 * 2 + 10", 20),
            # ("5 + 2 * 10", 25),
            # ("20 + 2 * -10", 0),
            # ("50 / 2 * 2 + 10", 60),
            # ("2 * (5 + 10)", 30),
            # ("3 * 3 * 3 + 10", 37),
            # ("3 * (3 * 3) + 10", 37),
            # ("(5 + 10 * 2 + 15 / 3) * 2 + -10", 50),
        ]

        for v in tests:
            evaluated = self.test_Eval(v[0])
            assert self.test_IntegerObject(evaluated, v[1])
