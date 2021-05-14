# nim c -r eval_test.nim "TestReturnStatements"
import unittest
import strutils
import strformat
import lexer
import parser
import ast
import obj
import eval


type
  Interface = object
    kind: string
    iVal: int
    fVal: float
    sVal: string
    bVal: bool
    nVal: ref string


proc testEval(input: string): obj.Obj =
  let l = lexer.LexerNew(input)
  let p = parser.ParserNew(l)
  let program = p.parseProgram()
  return eval.Eval(program)


proc testIntegerObject(o: obj.Obj, expected: int): bool =
  if o of obj.Integer:
    let o2 = obj.Integer(o)
    check(o2.value == expected)
    return true
  echo fmt"object is not Integer"
  return false


proc testBooleanObject(o: obj.Obj, expected: bool): bool =
  if o of obj.Boolean:
    let o2 = obj.Boolean(o)
    check(o2.value == expected)
    return true
  echo fmt"object is not Boolean"
  return false


proc testNullObject(o: obj.Obj): bool =
  if o != eval.NULL:
    echo fmt"object is not NULL"
    return false
  return true



suite "eval_test":

  test "TestEvalIntegerExpression":
    let tests = [
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
      let evaluated = testEval(v[0])
      check(testIntegerObject(evaluated, v[1]))


  test "TestEvalBooleanExpression":
    let tests = [
      ("true", true),
      ("false", false),
      ("1 < 2", true),
      ("1 > 2", false),
      ("1 < 1", false),
      ("1 > 1", false),
      ("1 == 1", true),
      ("1 != 1", false),
      ("1 == 2", false),
      ("1 != 2", true),
      ("true == true", true),
      ("false == false", true),
      ("true == false", false),
      ("true != false", true),
      ("false != true", true),
      ("(1 < 2) == true", true),
      ("(1 < 2) == false", false),
      ("(1 > 2) == true", false),
      ("(1 > 2) == false", true),
    ]

    for v in tests:
      let evaluated = testEval(v[0])
      check(testBooleanObject(evaluated, v[1]))


  test "TestBangOperator":
    let tests = [
      ("!true", false),
      ("!false", true),
      ("!5", false),
      ("!!true", true),
      ("!!false", false),
      ("!!5", true),
    ]

    for v in tests:
      let e = testEval(v[0])
      check(testBooleanObject(e, v[1]))


  test "TestIfElseExpressions":
    let tests = [
      ("if (true) { 10 }", Interface(kind: "int", iVal: 10)),
      ("if (false) { 10 }", Interface(kind: "ref", nVal: nil)),
      ("if (1) { 10 }", Interface(kind: "int", iVal: 10)),
      ("if (1 < 2) { 10 }", Interface(kind: "int", iVal: 10)),
      ("if (1 > 2) { 10 }", Interface(kind: "ref", nVal: nil)),
      ("if (1 > 2) { 10 } else { 20 }", Interface(kind: "int", iVal: 20)),
      ("if (1 < 2) { 10 } else { 20 }", Interface(kind: "int", iVal: 10)),
    ]

    for v in tests:
      let e = testEval(v[0])
      if v[1].kind == "int":
        check(testIntegerObject(e, v[1].iVal))
      else:
        check(testNullObject(e))


  test "TestReturnStatements":
    let tests = [
      ("return 10;", 10),
      ("return 10; 9;", 10),
      ("return 2 * 5; 9;", 10),
      ("9; return 2 * 5; 9;", 10),
      ("if (10 > 1) { return 10; }", 10),
      (
        """
if (10 > 1) {
  if (10 > 1) {
    return 10;
  }

  return 1;
}
""", 10
      )
    ]

    for v in tests:
      let e = testEval(v[0])
      check(testIntegerObject(e, v[1]))


  test "TestErrorHandling":
    let tests = [
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
      (
        "5; true + false; 5",
        "unknown operator: BOOLEAN + BOOLEAN",
      ),
      (
        "if (10 > 1) { true + false; }",
        "unknown operator: BOOLEAN + BOOLEAN",
      ),
      (
        """
if (10 > 1) {
  if (10 > 1) {
    return true + false;
  }

  return 1;
}
""",
        "unknown operator: BOOLEAN + BOOLEAN",
      ),
      # p154で出来る
      (
        "true + false + true + false;",
        "unknown operator: BOOLEAN + BOOLEAN"
      ),
    ]
    for v in tests:
      let e = testEval(v[0])
      let errObj = obj.Error(e)
      check(errObj.message == v[1])
