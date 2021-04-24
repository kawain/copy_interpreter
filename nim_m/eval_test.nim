# nim c -r eval_test.nim "test1"
import unittest
import strutils
import strformat
import lexer
import parser
import ast
import obj
import eval


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

  test "test1":
    let tests = [
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
      let evaluated = testEval(v[0])
      let a = testIntegerObject(evaluated, v[1])
      check(a)


  test "test2":
    let tests = [
      ("true", true),
      ("false", false),
      # ("1 < 2", true),
      # ("1 > 2", false),
      # ("1 < 1", false),
      # ("1 > 1", false),
      # ("1 == 1", true),
      # ("1 != 1", false),
      # ("1 == 2", false),
      # ("1 != 2", true),
      # ("true == true", true),
      # ("false == false", true),
      # ("true == false", false),
      # ("true != false", true),
      # ("false != true", true),
      # ("(1 < 2) == true", true),
      # ("(1 < 2) == false", false),
      # ("(1 > 2) == true", false),
      # ("(1 > 2) == false", true),
    ]

    for v in tests:
      let evaluated = testEval(v[0])
      let a = testBooleanObject(evaluated, v[1])
      check(a)
