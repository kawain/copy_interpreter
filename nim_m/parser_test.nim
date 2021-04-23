# テストの仕方
# nim c -r parser_test.nim "test9"
import unittest
import strutils
import strformat
import lexer
import parser
import ast

proc checkParserErrors(l: Lexer, p: Parser): bool =
  let e = p.Errors()
  if len(e) == 0:
    return true

  echo fmt"parser has {len(e)} errors"
  for v in e:
    echo fmt"parser error: {v}"
  return false


proc handyInfixExpression(left, right: Expression) =
  if left of IntegerLiteral:
    echo "IntegerLiteral"
    echo IntegerLiteral(left).value
  elif left of FloatLiteral:
    echo "FloatLiteral"
    echo FloatLiteral(left).value

  if right of IntegerLiteral:
    echo "IntegerLiteral"
    echo IntegerLiteral(right).value
  elif right of FloatLiteral:
    echo "FloatLiteral"
    echo FloatLiteral(right).value


suite "parser_test":

  test "test11":
    let input = "add(1, 2 * 3, 4 + 5);"
    let l = LexerNew(input)
    let p = ParserNew(l)
    let program = p.parseProgram()
    let b = checkParserErrors(l, p)
    check(b)

    for v in program.statements:
      echo type(v)
      echo type(ExpressionStatement(v))
      echo type(ExpressionStatement(v).expression)
      var v1 = ExpressionStatement(v).expression
      if v1 of CallExpression:
        let v2 = CallExpression(v1)
        echo v2.toString()
      else:
        echo "NG"
      echo "-".repeat(20)


  test "test10":
    let tests = [
        ("fn() {};", @[]),
        ("fn(x) {};", @["x"]),
        ("fn(x, y, z) {};", @["x", "y", "z"]),
      ]

    for v in tests:
      let l = LexerNew(v[0])
      let p = ParserNew(l)
      let program = p.parseProgram()
      let b = checkParserErrors(l, p)
      check(b)

      let stmt = ExpressionStatement(program.statements[0])
      let fn = FunctionLiteral(stmt.expression)
      check(len(fn.parameters) == len(v[1]))

      for i, v2 in v[1]:
        let obj = fn.parameters[i]
        check(obj.value == v2)


  test "test9":
    let input = "fn(x, y) { x + y; }"
    let l = LexerNew(input)
    let p = ParserNew(l)
    let program = p.parseProgram()
    let b = checkParserErrors(l, p)
    check(b)

    for v in program.statements:
      echo type(v)
      echo type(ExpressionStatement(v))
      echo type(ExpressionStatement(v).expression)
      var v1 = ExpressionStatement(v).expression
      if v1 of FunctionLiteral:
        let v2 = FunctionLiteral(v1)
        echo v2.toString()
      else:
        echo "NG"
      echo "-".repeat(20)


  test "test8":
    let input = """
if (x < y) { x }
if (10 < 100) { (10 - 12) * 3 }
    """
    let l = LexerNew(input)
    let p = ParserNew(l)
    let program = p.parseProgram()
    let b = checkParserErrors(l, p)
    check(b)

    for v in program.statements:
      echo type(v)
      echo type(ExpressionStatement(v))
      echo type(ExpressionStatement(v).expression)
      var v1 = ExpressionStatement(v).expression
      if v1 of IfExpression:
        let v2 = IfExpression(v1)
        echo v2.toString()
      else:
        echo "NG"
      echo "-".repeat(20)


  test "test7":
    let input = [
      ["-a * b", "((-a) * b)"],
      ["!-a", "(!(-a))"],
      ["a + b + c", "((a + b) + c)"],
      ["a + b - c", "((a + b) - c)"],
      ["a * b * c", "((a * b) * c)"],
      ["a * b / c", "((a * b) / c)"],
      ["a + b / c", "(a + (b / c))"],
      ["a + b * c + d / e - f", "(((a + (b * c)) + (d / e)) - f)"],
      ["3 + 4; -5 * 5", "(3 + 4)((-5) * 5)"],
      ["5 > 4 == 3 < 4", "((5 > 4) == (3 < 4))"],
      ["5 < 4 != 3 > 4", "((5 < 4) != (3 > 4))"],
      ["3 + 4 * 5 == 3 * 1 + 4 * 5", "((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))"],
      ["true", "true"],
      ["false", "false"],
      ["3 > 5 == false", "((3 > 5) == false)"],
      ["3 < 5 == true", "((3 < 5) == true)"],
      ["1 + (2 + 3) + 4", "((1 + (2 + 3)) + 4)"],
      ["(5 + 5) * 2", "((5 + 5) * 2)"],
      ["2 / (5 + 5)", "(2 / (5 + 5))"],
      ["(5 + 5) * 2 * (5 + 5)", "(((5 + 5) * 2) * (5 + 5))"],
      ["-(5 + 5)", "(-(5 + 5))"],
      ["!(true == true)", "(!(true == true))"],
      ["a + add(b * c) + d", "((a + add((b * c))) + d)"],
      ["add(a, b, 1, 2 * 3, 4 + 5, add(6, 7 * 8))",
          "add(a, b, 1, (2 * 3), (4 + 5), add(6, (7 * 8)))"],
      ["add(a + b + c * d / f + g)", "add((((a + b) + ((c * d) / f)) + g))"]
    ]

    for v in input:
      let l = LexerNew(v[0])
      let p = ParserNew(l)
      let program = p.parseProgram()
      let b = checkParserErrors(l, p)
      check(b)
      check(program.toString() == v[1])


  test "test6":
    # intとfloatの計算ができるのはここでは無視
    let input = """
  5 + 5.;
  5 - .5;
  5. * 5;
  5. / 5;
  5. > 5;
  .5 < 5;
  .5 == 5;
  .5 != 5;
      """
    let l = LexerNew(input)
    let p = ParserNew(l)
    let program = p.parseProgram()
    let b = checkParserErrors(l, p)
    check(b)

    for v in program.statements:
      echo type(v)
      echo type(ExpressionStatement(v))
      echo type(ExpressionStatement(v).expression)
      var v1 = ExpressionStatement(v).expression
      if v1 of InfixExpression:
        echo InfixExpression(v1).token[]
        let left = InfixExpression(v1).left
        echo InfixExpression(v1).operator
        let right = InfixExpression(v1).right
        handyInfixExpression(left, right)
      else:
        echo "NG"
      echo "-".repeat(20)


  test "test5":
    let input = """
  !525;
  -3.1415;
      """
    let l = LexerNew(input)
    let p = ParserNew(l)
    let program = p.parseProgram()
    let b = checkParserErrors(l, p)
    check(b)

    for v in program.statements:
      echo type(v)
      echo type(ExpressionStatement(v))
      echo type(ExpressionStatement(v).expression)
      var v1 = ExpressionStatement(v).expression
      echo v1[]
      if v1 of PrefixExpression:
        echo PrefixExpression(v1).token[]
        echo PrefixExpression(v1).operator
        let v2 = PrefixExpression(v1).right
        if v2 of IntegerLiteral:
          echo "IntegerLiteral"
          echo IntegerLiteral(v2).value
        elif v2 of FloatLiteral:
          echo "FloatLiteral"
          echo FloatLiteral(v2).value
      else:
        echo "NG"
      echo "-".repeat(20)


  test "test4":
    let input = """
  5;
  3.1415;
      """
    let l = LexerNew(input)
    let p = ParserNew(l)
    let program = p.parseProgram()
    let b = checkParserErrors(l, p)
    check(b)

    for v in program.statements:
      echo type(v)
      echo type(ExpressionStatement(v))
      echo type(ExpressionStatement(v).expression)
      var v = ExpressionStatement(v).expression
      # 継承が有効になっているオブジェクトには、実行時にタイプに関する情報が含まれているため、
      # of演算子を使用してオブジェクトのタイプを判別できます。
      if v of IntegerLiteral:
        echo "IntegerLiteral"
        echo IntegerLiteral(v).value
      elif v of FloatLiteral:
        echo "FloatLiteral"
        echo FloatLiteral(v).value
      else:
        echo "NG"
      echo "-".repeat(20)


  test "test3":
    let input = """
  foobar;
      """
    let l = LexerNew(input)
    let p = ParserNew(l)
    let program = p.parseProgram()
    let b = checkParserErrors(l, p)
    check(b)

    for v in program.statements:
      echo ExpressionStatement(v).tokenLiteral()
      echo Identifier(ExpressionStatement(v).expression).token[]
      echo Identifier(ExpressionStatement(v).expression).value
      echo "-".repeat(20)


  test "test2":
    let input = """
  return 5;
  return 10;
  return add(15);
      """
    let l = LexerNew(input)
    let p = ParserNew(l)
    let program = p.parseProgram()
    let b = checkParserErrors(l, p)
    check(b)

    for v in program.statements:
      echo ReturnStatement(v).tokenLiteral()
      echo ReturnStatement(v).token.tokenType
      echo "-".repeat(20)



  test "test1":
    let input = """
  let x = 5;
  let y = 10;
  let foobar = 838383;
      """
    let l = LexerNew(input)
    let p = ParserNew(l)
    let program = p.parseProgram()
    let b = checkParserErrors(l, p)
    check(b)

    for v in program.statements:
      echo LetStatement(v).token.tokenType
      echo LetStatement(v).token.literal
      echo LetStatement(v).name.value
      echo LetStatement(v).value[]
      echo "-".repeat(20)
