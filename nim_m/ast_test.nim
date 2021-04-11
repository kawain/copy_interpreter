import unittest
import token
import ast


suite "ast_test":

  test "test1":
    let ls = new LetStatement
    ls.token = Token(tokenType: LET, literal: "let")
    ls.name = Identifier(
      token: Token(tokenType: IDENT, literal: "muVar"), value: "muVar"
    )
    ls.value = Identifier(
      token: Token(tokenType: IDENT, literal: "anotherVar"), value: "anotherVar"
    )

    let p = new Program
    p.statements.add(ls)

    echo p.toString()

    check(p.toString() == "let muVar = anotherVar;")

