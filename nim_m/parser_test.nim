# テストの仕方
# nim c -r parser_test.nim "TestParsingPrefixExpressions"
import unittest
import strutils
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



# proc handyInfixExpression(left, right: Expression) =
#   if left of IntegerLiteral:
#     echo "IntegerLiteral"
#     echo IntegerLiteral(left).value
#   elif left of FloatLiteral:
#     echo "FloatLiteral"
#     echo FloatLiteral(left).value

#   if right of IntegerLiteral:
#     echo "IntegerLiteral"
#     echo IntegerLiteral(right).value
#   elif right of FloatLiteral:
#     echo "FloatLiteral"
#     echo FloatLiteral(right).value



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


# nim c -r parser_test.nim "TestOperatorPrecedenceParsing"

  #   test "test11":
  #     let input = "add(1, 2 * 3, 4 + 5);"
  #     let l = LexerNew(input)
  #     let p = ParserNew(l)
  #     let program = p.parseProgram()
  #     let b = checkParserErrors(l, p)
  #     check(b)

  #     for v in program.statements:
  #       echo type(v)
  #       echo type(ExpressionStatement(v))
  #       echo type(ExpressionStatement(v).expression)
  #       var v1 = ExpressionStatement(v).expression
  #       if v1 of CallExpression:
  #         let v2 = CallExpression(v1)
  #         echo v2.toString()
  #       else:
  #         echo "NG"
  #       echo "-".repeat(20)


  #   test "test10":
  #     let tests = [
  #         ("fn() {};", @[]),
  #         ("fn(x) {};", @["x"]),
  #         ("fn(x, y, z) {};", @["x", "y", "z"]),
  #       ]

  #     for v in tests:
  #       let l = LexerNew(v[0])
  #       let p = ParserNew(l)
  #       let program = p.parseProgram()
  #       let b = checkParserErrors(l, p)
  #       check(b)

  #       let stmt = ExpressionStatement(program.statements[0])
  #       let fn = FunctionLiteral(stmt.expression)
  #       check(len(fn.parameters) == len(v[1]))

  #       for i, v2 in v[1]:
  #         let obj = fn.parameters[i]
  #         check(obj.value == v2)


  #   test "test9":
  #     let input = "fn(x, y) { x + y; }"
  #     let l = LexerNew(input)
  #     let p = ParserNew(l)
  #     let program = p.parseProgram()
  #     let b = checkParserErrors(l, p)
  #     check(b)

  #     for v in program.statements:
  #       echo type(v)
  #       echo type(ExpressionStatement(v))
  #       echo type(ExpressionStatement(v).expression)
  #       var v1 = ExpressionStatement(v).expression
  #       if v1 of FunctionLiteral:
  #         let v2 = FunctionLiteral(v1)
  #         echo v2.toString()
  #       else:
  #         echo "NG"
  #       echo "-".repeat(20)


  #   test "test8":
  #     let input = """
  # if (x < y) { x }
  # if (10 < 100) { (10 - 12) * 3 }
  #     """
  #     let l = LexerNew(input)
  #     let p = ParserNew(l)
  #     let program = p.parseProgram()
  #     let b = checkParserErrors(l, p)
  #     check(b)

  #     for v in program.statements:
  #       echo type(v)
  #       echo type(ExpressionStatement(v))
  #       echo type(ExpressionStatement(v).expression)
  #       var v1 = ExpressionStatement(v).expression
  #       if v1 of IfExpression:
  #         let v2 = IfExpression(v1)
  #         echo v2.toString()
  #       else:
  #         echo "NG"
  #       echo "-".repeat(20)


  #   test "test7":
  #     let input = [
  #       ["-a * b", "((-a) * b)"],
  #       ["!-a", "(!(-a))"],
  #       ["a + b + c", "((a + b) + c)"],
  #       ["a + b - c", "((a + b) - c)"],
  #       ["a * b * c", "((a * b) * c)"],
  #       ["a * b / c", "((a * b) / c)"],
  #       ["a + b / c", "(a + (b / c))"],
  #       ["a + b * c + d / e - f", "(((a + (b * c)) + (d / e)) - f)"],
  #       ["3 + 4; -5 * 5", "(3 + 4)((-5) * 5)"],
  #       ["5 > 4 == 3 < 4", "((5 > 4) == (3 < 4))"],
  #       ["5 < 4 != 3 > 4", "((5 < 4) != (3 > 4))"],
  #       ["3 + 4 * 5 == 3 * 1 + 4 * 5", "((3 + (4 * 5)) == ((3 * 1) + (4 * 5)))"],
  #       ["true", "true"],
  #       ["false", "false"],
  #       ["3 > 5 == false", "((3 > 5) == false)"],
  #       ["3 < 5 == true", "((3 < 5) == true)"],
  #       ["1 + (2 + 3) + 4", "((1 + (2 + 3)) + 4)"],
  #       ["(5 + 5) * 2", "((5 + 5) * 2)"],
  #       ["2 / (5 + 5)", "(2 / (5 + 5))"],
  #       ["(5 + 5) * 2 * (5 + 5)", "(((5 + 5) * 2) * (5 + 5))"],
  #       ["-(5 + 5)", "(-(5 + 5))"],
  #       ["!(true == true)", "(!(true == true))"],
  #       ["a + add(b * c) + d", "((a + add((b * c))) + d)"],
  #       ["add(a, b, 1, 2 * 3, 4 + 5, add(6, 7 * 8))",
  #           "add(a, b, 1, (2 * 3), (4 + 5), add(6, (7 * 8)))"],
  #       ["add(a + b + c * d / f + g)", "add((((a + b) + ((c * d) / f)) + g))"]
  #     ]

  #     for v in input:
  #       let l = LexerNew(v[0])
  #       let p = ParserNew(l)
  #       let program = p.parseProgram()
  #       let b = checkParserErrors(l, p)
  #       check(b)
  #       check(program.toString() == v[1])


  #   test "test6":
  #     # intとfloatの計算ができるのはここでは無視
  #     let input = """
  #   5 + 5.;
  #   5 - .5;
  #   5. * 5;
  #   5. / 5;
  #   5. > 5;
  #   .5 < 5;
  #   .5 == 5;
  #   .5 != 5;
  #       """
  #     let l = LexerNew(input)
  #     let p = ParserNew(l)
  #     let program = p.parseProgram()
  #     let b = checkParserErrors(l, p)
  #     check(b)

  #     for v in program.statements:
  #       echo type(v)
  #       echo type(ExpressionStatement(v))
  #       echo type(ExpressionStatement(v).expression)
  #       var v1 = ExpressionStatement(v).expression
  #       if v1 of InfixExpression:
  #         echo InfixExpression(v1).token[]
  #         let left = InfixExpression(v1).left
  #         echo InfixExpression(v1).operator
  #         let right = InfixExpression(v1).right
  #         handyInfixExpression(left, right)
  #       else:
  #         echo "NG"
  #       echo "-".repeat(20)


  #   test "test5":
  #     let input = """
  #   !525;
  #   -3.1415;
  #       """
  #     let l = LexerNew(input)
  #     let p = ParserNew(l)
  #     let program = p.parseProgram()
  #     let b = checkParserErrors(l, p)
  #     check(b)

  #     for v in program.statements:
  #       echo type(v)
  #       echo type(ExpressionStatement(v))
  #       echo type(ExpressionStatement(v).expression)
  #       var v1 = ExpressionStatement(v).expression
  #       echo v1[]
  #       if v1 of PrefixExpression:
  #         echo PrefixExpression(v1).token[]
  #         echo PrefixExpression(v1).operator
  #         let v2 = PrefixExpression(v1).right
  #         if v2 of IntegerLiteral:
  #           echo "IntegerLiteral"
  #           echo IntegerLiteral(v2).value
  #         elif v2 of FloatLiteral:
  #           echo "FloatLiteral"
  #           echo FloatLiteral(v2).value
  #       else:
  #         echo "NG"
  #       echo "-".repeat(20)


  #   test "test4":
  #     let input = """
  #   5;
  #   3.1415;
  #       """
  #     let l = LexerNew(input)
  #     let p = ParserNew(l)
  #     let program = p.parseProgram()
  #     let b = checkParserErrors(l, p)
  #     check(b)

  #     for v in program.statements:
  #       echo type(v)
  #       echo type(ExpressionStatement(v))
  #       echo type(ExpressionStatement(v).expression)
  #       var v = ExpressionStatement(v).expression
  #       # 継承が有効になっているオブジェクトには、実行時にタイプに関する情報が含まれているため、
  #       # of演算子を使用してオブジェクトのタイプを判別できます。
  #       if v of IntegerLiteral:
  #         echo "IntegerLiteral"
  #         echo IntegerLiteral(v).value
  #       elif v of FloatLiteral:
  #         echo "FloatLiteral"
  #         echo FloatLiteral(v).value
  #       else:
  #         echo "NG"
  #       echo "-".repeat(20)


  #   test "test3":
  #     let input = """
  #   foobar;
  #       """
  #     let l = LexerNew(input)
  #     let p = ParserNew(l)
  #     let program = p.parseProgram()
  #     let b = checkParserErrors(l, p)
  #     check(b)

  #     for v in program.statements:
  #       echo ExpressionStatement(v).tokenLiteral()
  #       echo Identifier(ExpressionStatement(v).expression).token[]
  #       echo Identifier(ExpressionStatement(v).expression).value
  #       echo "-".repeat(20)


  #   test "test2":
  #     let input = """
  #   return 5;
  #   return 10;
  #   return add(15);
  #       """
  #     let l = LexerNew(input)
  #     let p = ParserNew(l)
  #     let program = p.parseProgram()
  #     let b = checkParserErrors(l, p)
  #     check(b)

  #     for v in program.statements:
  #       echo ReturnStatement(v).tokenLiteral()
  #       echo ReturnStatement(v).token.tokenType
  #       echo "-".repeat(20)



  #   test "test1":
  #     let input = """
  #   let x = 5;
  #   let y = 10;
  #   let foobar = 838383;
  #       """
  #     let l = LexerNew(input)
  #     let p = ParserNew(l)
  #     let program = p.parseProgram()
  #     let b = checkParserErrors(l, p)
  #     check(b)

  #     for v in program.statements:
  #       echo LetStatement(v).token.tokenType
  #       echo LetStatement(v).token.literal
  #       echo LetStatement(v).name.value
  #       echo LetStatement(v).value[]
  #       echo "-".repeat(20)
