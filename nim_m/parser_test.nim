# テストの仕方
# nim c -r parser_test.nim "TestParsingPrefixExpressions"
import unittest
import strformat
import lexer
import parser
import ast


type
  Interface = object
    kind: string
    iVal: int
    fVal: float
    sVal: string
    bVal: bool


proc checkParserErrors(l: Lexer, p: Parser): bool =
  let e = p.Errors()
  if len(e) == 0:
    return true
  echo fmt"parser has {len(e)} errors"
  for v in e:
    echo fmt"parser error: {v}"
  return false


proc testLetStatement(stm: ast.Statement, name: string): bool =
  let s = ast.LetStatement(stm)
  check(s.tokenLiteral() == "let")
  check(s.name.value == name)
  check(s.name.tokenLiteral() == name)
  return true


proc testIntegerLiteral(il: ast.Expression, value: int): bool =
  let integ = ast.IntegerLiteral(il)
  check(integ.value == value)
  check(integ.tokenLiteral() == $value)
  return true


proc testIdentifier(exp: ast.Expression, value: string): bool =
  let ident = ast.Identifier(exp)
  check(ident.value == value)
  check(ident.tokenLiteral() == value)
  return true


proc testBooleanLiteral(exp: ast.Expression, value: bool): bool =
  let bo = ast.Boolean(exp)
  check(bo.value == value)
  check(bo.tokenLiteral() == $bool(value))
  return true


proc testLiteralExpression(exp: ast.Expression, expected: Interface): bool =
  let kind = expected.kind
  case kind
  of "int":
    return testIntegerLiteral(exp, expected.iVal)
  of "bool":
    return testBooleanLiteral(exp, expected.bVal)
  of "str":
    return testIdentifier(exp, expected.sVal)
  else:
    echo "type of exp not handled"
    return false


proc testInfixExpression(
  exp: ast.Expression, left: Interface, operator: string, right: Interface
): bool =
  let opExp = ast.InfixExpression(exp)
  check(testLiteralExpression(opExp.left, left))
  check(opExp.operator == operator)
  check(testLiteralExpression(opExp.right, right))
  return true


suite "parser_test":

  test "TestLetStatements":
    let tests = [
      ("let x = 5;", "x", Interface(kind: "int", iVal: 5)),
      ("let y = true;", "y", Interface(kind: "bool", bVal: true)),
      ("let foobar = y;", "foobar", Interface(kind: "str", sVal: "y")),
    ]

    for v in tests:
      let l = LexerNew(v[0])
      let p = ParserNew(l)
      let program = p.parseProgram()
      check(checkParserErrors(l, p))
      check(len(program.statements) == 1)
      let stm = program.statements[0]
      check(testLetStatement(stm, v[1]))
      let val = ast.LetStatement(stm).value
      check(testLiteralExpression(val, v[2]))


  test "TestReturnStatements":
    let tests = [
      ("return 5;", Interface(kind: "int", iVal: 5)),
      ("return true;", Interface(kind: "bool", bVal: true)),
      ("return foobar;", Interface(kind: "str", sVal: "foobar")),
    ]

    for v in tests:
      let l = LexerNew(v[0])
      let p = ParserNew(l)
      let program = p.parseProgram()
      check(checkParserErrors(l, p))
      check(len(program.statements) == 1)
      let stm = program.statements[0]
      let returnStmt = ast.ReturnStatement(stm)
      check(returnStmt.tokenLiteral() == "return")
      check(testLiteralExpression(returnStmt.returnValue, v[1]))


  test "TestIdentifierExpression":
    let input = "foobar;"
    let l = LexerNew(input)
    let p = ParserNew(l)
    let program = p.parseProgram()
    check(checkParserErrors(l, p))
    check(len(program.statements) == 1)
    let stm = ast.ExpressionStatement(program.statements[0])
    let ident = ast.Identifier(stm.expression)
    check(ident.value == "foobar")
    check(ident.tokenLiteral() == "foobar")


  test "TestIntegerLiteralExpression":
    let input = "5;"
    let l = LexerNew(input)
    let p = ParserNew(l)
    let program = p.parseProgram()
    check(checkParserErrors(l, p))
    check(len(program.statements) == 1)
    let stm = ast.ExpressionStatement(program.statements[0])
    let literal = ast.IntegerLiteral(stm.expression)
    check(literal.value == 5)
    check(literal.tokenLiteral() == "5")


  test "TestParsingPrefixExpressions":
    let tests = [
      ("!5;", "!", Interface(kind: "int", iVal: 5)),
      ("-15;", "-", Interface(kind: "int", iVal: 15)),
      ("!foobar;", "!", Interface(kind: "str", sVal: "foobar")),
      ("-foobar;", "-", Interface(kind: "str", sVal: "foobar")),
      ("!true;", "!", Interface(kind: "bool", bVal: true)),
      ("!false;", "!", Interface(kind: "bool", bVal: false)),
    ]

    for v in tests:
      let l = LexerNew(v[0])
      let p = ParserNew(l)
      let program = p.parseProgram()
      check(checkParserErrors(l, p))
      check(len(program.statements) == 1)
      let stm = ast.ExpressionStatement(program.statements[0])
      let exp = ast.PrefixExpression(stm.expression)
      check(exp.operator == v[1])
      check(testLiteralExpression(exp.right, v[2]))


  test "TestParsingInfixExpressions":
    let tests = [
      (
        "5 + 5;",
        Interface(kind: "int", iVal: 5),
        "+",
        Interface(kind: "int", iVal: 5)
      ),
      (
        "5 - 5;",
        Interface(kind: "int", iVal: 5),
        "-",
        Interface(kind: "int", iVal: 5)
      ),
      (
        "5 * 5;",
        Interface(kind: "int", iVal: 5),
        "*",
        Interface(kind: "int", iVal: 5)
      ),
      (
        "5 / 5;",
        Interface(kind: "int", iVal: 5),
        "/",
        Interface(kind: "int", iVal: 5)
      ),
      (
        "5 > 5;",
        Interface(kind: "int", iVal: 5),
        ">",
        Interface(kind: "int", iVal: 5)
      ),
      (
        "5 < 5;",
        Interface(kind: "int", iVal: 5),
        "<",
        Interface(kind: "int", iVal: 5)
      ),
      (
        "5 == 5;",
        Interface(kind: "int", iVal: 5),
        "==",
        Interface(kind: "int", iVal: 5)
      ),
      (
        "5 != 5;",
        Interface(kind: "int", iVal: 5),
        "!=",
        Interface(kind: "int", iVal: 5)
      ),
      (
        "foobar + barfoo;",
        Interface(kind: "str", sVal: "foobar"),
        "+",
        Interface(kind: "str", sVal: "barfoo")
      ),
      (
        "foobar - barfoo;",
        Interface(kind: "str", sVal: "foobar"),
        "-",
        Interface(kind: "str", sVal: "barfoo")
      ),
      (
        "foobar * barfoo;",
        Interface(kind: "str", sVal: "foobar"),
        "*",
        Interface(kind: "str", sVal: "barfoo")
      ),
      (
        "foobar / barfoo;",
        Interface(kind: "str", sVal: "foobar"),
        "/",
        Interface(kind: "str", sVal: "barfoo")
      ),
      (
        "foobar > barfoo;",
        Interface(kind: "str", sVal: "foobar"),
        ">",
        Interface(kind: "str", sVal: "barfoo")
      ),
      (
        "foobar < barfoo;",
        Interface(kind: "str", sVal: "foobar"),
        "<",
        Interface(kind: "str", sVal: "barfoo")
      ),
      (
        "foobar == barfoo;",
        Interface(kind: "str", sVal: "foobar"),
        "==",
        Interface(kind: "str", sVal: "barfoo")
      ),
      (
        "foobar != barfoo;",
        Interface(kind: "str", sVal: "foobar"),
        "!=",
        Interface(kind: "str", sVal: "barfoo")
      ),
      (
        "true == true",
        Interface(kind: "bool", bVal: true),
        "==",
        Interface(kind: "bool", bVal: true)
      ),
      (
        "true != false",
        Interface(kind: "bool", bVal: true),
        "!=",
        Interface(kind: "bool", bVal: false)
      ),
      (
        "false == false",
        Interface(kind: "bool", bVal: false),
        "==",
        Interface(kind: "bool", bVal: false)
      ),
    ]

    for v in tests:
      let l = LexerNew(v[0])
      let p = ParserNew(l)
      let program = p.parseProgram()
      check(checkParserErrors(l, p))
      check(len(program.statements) == 1)
      let stm = ast.ExpressionStatement(program.statements[0])
      check(testInfixExpression(stm.expression, v[1], v[2], v[3]))


  test "TestOperatorPrecedenceParsing":
    let tests = [
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
      (
        "a + add(b * c) + d",
        "((a + add((b * c))) + d)",
      ),
      (
        "add(a, b, 1, 2 * 3, 4 + 5, add(6, 7 * 8))",
        "add(a, b, 1, (2 * 3), (4 + 5), add(6, (7 * 8)))",
      ),
      (
        "add(a + b + c * d / f + g)",
        "add((((a + b) + ((c * d) / f)) + g))",
      ),
    ]

    for v in tests:
      let l = LexerNew(v[0])
      let p = ParserNew(l)
      let program = p.parseProgram()
      check(checkParserErrors(l, p))
      let actual = program.toString()
      check(actual == v[1])


  test "TestBooleanExpression":
    let tests = [
      ("true;", true),
      ("false;", false),
    ]

    for v in tests:
      let l = LexerNew(v[0])
      let p = ParserNew(l)
      let program = p.parseProgram()
      check(checkParserErrors(l, p))
      check(len(program.statements) == 1)
      let stm = ast.ExpressionStatement(program.statements[0])
      let b = ast.Boolean(stm.expression)
      check(b.value == v[1])


  test "TestIfExpression":
    let input = "if (x < y) { x }"

    let l = LexerNew(input)
    let p = ParserNew(l)
    let program = p.parseProgram()
    check(checkParserErrors(l, p))
    check(len(program.statements) == 1)
    let stm = ast.ExpressionStatement(program.statements[0])
    let exp = ast.IfExpression(stm.expression)
    check(
      testInfixExpression(
        exp.condition,
        Interface(kind: "str", sVal: "x"),
        "<",
        Interface(kind: "str", sVal: "y")
      )
    )
    check(len(exp.consequence.statements) == 1)
    let consequence = ast.ExpressionStatement(exp.consequence.statements[0])
    check(testIdentifier(consequence.expression, "x"))
    check(exp.alternative == nil)


  test "TestIfElseExpression":
    let input = "if (x < y) { x } else { y }"

    let l = LexerNew(input)
    let p = ParserNew(l)
    let program = p.parseProgram()
    check(checkParserErrors(l, p))
    check(len(program.statements) == 1)
    let stm = ast.ExpressionStatement(program.statements[0])
    let exp = ast.IfExpression(stm.expression)
    check(
      testInfixExpression(
        exp.condition,
        Interface(kind: "str", sVal: "x"),
        "<",
        Interface(kind: "str", sVal: "y")
      )
    )
    check(len(exp.consequence.statements) == 1)
    let consequence = ast.ExpressionStatement(exp.consequence.statements[0])
    check(testIdentifier(consequence.expression, "x"))
    check(len(exp.alternative.statements) == 1)
    let alternative = ast.ExpressionStatement(exp.alternative.statements[0])
    check(testIdentifier(alternative.expression, "y"))


  test "TestFunctionLiteralParsing":
    let input = "fn(x, y) { x + y; }"

    let l = LexerNew(input)
    let p = ParserNew(l)
    let program = p.parseProgram()
    check(checkParserErrors(l, p))
    check(len(program.statements) == 1)
    let stm = ast.ExpressionStatement(program.statements[0])
    let fn = ast.FunctionLiteral(stm.expression)
    check(len(fn.parameters) == 2)
    check(testLiteralExpression(fn.parameters[0], Interface(kind: "str", sVal: "x")))
    check(testLiteralExpression(fn.parameters[1], Interface(kind: "str", sVal: "y")))
    check(len(fn.body.statements) == 1)
    let bodyStmt = ast.ExpressionStatement(fn.body.statements[0])
    check(
      testInfixExpression(
        bodyStmt.expression,
        Interface(kind: "str", sVal: "x"),
        "+",
        Interface(kind: "str", sVal: "y")
      )
    )


  test "TestFunctionParameterParsing":
    let tests = [
        ("fn() {};", @[]),
        ("fn(x) {};", @["x"]),
        ("fn(x, y, z) {};", @["x", "y", "z"]),
    ]

    for v in tests:
      let l = LexerNew(v[0])
      let p = ParserNew(l)
      let program = p.parseProgram()
      check(checkParserErrors(l, p))
      let stm = ast.ExpressionStatement(program.statements[0])
      let fn = ast.FunctionLiteral(stm.expression)
      check(len(fn.parameters) == len(v[1]))

      for i, ident in v[1]:
        check(testLiteralExpression(fn.parameters[i], Interface(kind: "str", sVal: ident)))


  test "TestCallExpressionParsing":
    let input = "add(1, 2 * 3, 4 + 5);"

    let l = LexerNew(input)
    let p = ParserNew(l)
    let program = p.parseProgram()
    check(checkParserErrors(l, p))
    check(len(program.statements) == 1)
    let stm = ast.ExpressionStatement(program.statements[0])
    let exp = ast.CallExpression(stm.expression)
    check(testIdentifier(exp.function, "add"))
    check(len(exp.arguments) == 3)
    check(testLiteralExpression(exp.arguments[0], Interface(kind: "int", iVal: 1)))
    check(testInfixExpression(
      exp.arguments[1],
      Interface(kind: "int", iVal: 2),
      "*",
      Interface(kind: "int", iVal: 3))
    )
    check(testInfixExpression(
      exp.arguments[2],
      Interface(kind: "int", iVal: 4),
      "+",
      Interface(kind: "int", iVal: 5))
    )


  test "TestCallExpressionParameterParsing":
    let tests = [
      ("add();", "add", @[]),
      ("add(1);", "add", @["1"]),
      ("add(1, 2 * 3, 4 + 5);", "add", @["1", "(2 * 3)", "(4 + 5)"]),
    ]

    for v in tests:
      let l = LexerNew(v[0])
      let p = ParserNew(l)
      let program = p.parseProgram()
      check(checkParserErrors(l, p))
      let stm = ast.ExpressionStatement(program.statements[0])
      let exp = ast.CallExpression(stm.expression)
      check(testIdentifier(exp.function, v[1]))
      check(len(exp.arguments) == len(v[2]))
      for i, arg in v[2]:
        let t = exp.arguments[i]
        if t of ast.InfixExpression:
          let t2 = ast.InfixExpression(t)
          check(t2.toString() == arg)
        elif t of ast.IntegerLiteral:
          let t2 = ast.IntegerLiteral(t)
          check(t2.toString() == arg)
        else:
          echo "NG"


  test "TestStringLiteralExpression":
    let input = "\"hello world\";"
    let l = LexerNew(input)
    let p = ParserNew(l)
    let program = p.parseProgram()
    check(checkParserErrors(l, p))
    let stm = ast.ExpressionStatement(program.statements[0])
    let lit = ast.StringLiteral(stm.expression)
    check(lit.value == "hello world")
