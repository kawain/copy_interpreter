# テストの仕方
# nim c -r parser_test.nim "test1などの名前指定"
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

suite "parser_test":

  test "test2":
    discard


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
