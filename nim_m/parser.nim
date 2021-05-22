import strutils
import tables
import strformat
import token
import lexer
import ast


type
  Priority = enum
    LOWEST
    EQUALS      # ==
    LESSGREATER # > or <
    SUM         # +
    PRODUCT     # *
    PREFIX      # -X or !X
    CALL        # myFunction(X)


  prefixParseFn = proc(self: Parser): Expression
  infixParseFn = proc(self: Parser, e: Expression): Expression


  Parser* = ref object
    lex: Lexer
    errors: seq[string]
    curToken: Token
    peekToken: Token
    prefixParseFns: Table[TokenType, prefixParseFn]
    infixParseFns: Table[TokenType, infixParseFn]


var precedences = {
  EQ: EQUALS,
  NOT_EQ: EQUALS,
  LT: LESSGREATER,
  GT: LESSGREATER,
  PLUS: SUM,
  MINUS: SUM,
  SLASH: PRODUCT,
  ASTERISK: PRODUCT,
  LPAREN: CALL,
}.toTable


# 関数のプロトタイプ宣言
proc ParserNew*(lex: Lexer): Parser
proc nextToken(self: Parser)
proc parseProgram*(self: Parser): Program
proc parseStatement(self: Parser): Statement
proc parseLetStatement(self: Parser): Statement
proc curTokenIs(self: Parser, t: TokenType): bool
proc peekTokenIs(self: Parser, t: TokenType): bool
proc expectPeek(self: Parser, t: TokenType): bool
proc Errors*(self: Parser): seq[string]
proc peekError(self: Parser, t: TokenType)
proc parseReturnStatement(self: Parser): Statement
proc parseExpressionStatement(self: Parser): Statement
proc parseExpression(self: Parser, precedence: Priority): Expression
proc parseIdentifier(self: Parser): Expression
proc parseIntegerLiteral(self: Parser): Expression
proc parseFloatLiteral(self: Parser): Expression
proc noPrefixParseFnError(self: Parser, t: TokenType)
proc parsePrefixExpression(self: Parser): Expression
proc peekPrecedence(self: Parser): Priority
proc curPrecedence(self: Parser): Priority
proc parseInfixExpression(self: Parser, left: Expression): Expression
proc parseBoolean(self: Parser): Expression
proc parseGroupedExpression(self: Parser): Expression
proc parseIfExpression(self: Parser): Expression
proc parseBlockStatement(self: Parser): BlockStatement
proc parseFunctionLiteral(self: Parser): Expression
proc parseFunctionParameters(self: Parser): seq[Identifier]
proc parseCallExpression(self: Parser, f: Expression): Expression
# proc parseCallArguments(self: Parser): seq[Expression]
proc parseStringLiteral(self: Parser): Expression
proc parseArrayLiteral(self: Parser): Expression
proc parseExpressionList(self: Parser, ends: token.TokenType): seq[ast.Expression]


proc ParserNew*(lex: Lexer): Parser =
  result = new Parser
  result.lex = lex
  result.errors = newSeq[string]()

  result.prefixParseFns[IDENT] = parseIdentifier
  result.prefixParseFns[INT] = parseIntegerLiteral
  result.prefixParseFns[FLOAT] = parseFloatLiteral
  result.prefixParseFns[BANG] = parsePrefixExpression
  result.prefixParseFns[MINUS] = parsePrefixExpression
  result.prefixParseFns[TRUE] = parseBoolean
  result.prefixParseFns[FALSE] = parseBoolean
  result.prefixParseFns[LPAREN] = parseGroupedExpression
  result.prefixParseFns[IF] = parseIfExpression
  result.prefixParseFns[FUNCTION] = parseFunctionLiteral
  result.prefixParseFns[STRING] = parseStringLiteral
  result.prefixParseFns[LBRACKET] = parseArrayLiteral

  result.infixParseFns[PLUS] = parseInfixExpression
  result.infixParseFns[MINUS] = parseInfixExpression
  result.infixParseFns[SLASH] = parseInfixExpression
  result.infixParseFns[ASTERISK] = parseInfixExpression
  result.infixParseFns[EQ] = parseInfixExpression
  result.infixParseFns[NOT_EQ] = parseInfixExpression
  result.infixParseFns[LT] = parseInfixExpression
  result.infixParseFns[GT] = parseInfixExpression
  result.infixParseFns[LPAREN] = parseCallExpression

  result.nextToken()
  result.nextToken()


proc nextToken(self: Parser) =
  self.curToken = self.peekToken
  self.peekToken = self.lex.nextToken()


proc parseProgram(self: Parser): Program =
  result = new Program
  while not self.curTokenIs(EOF):
    let stmt = self.parseStatement()
    if stmt != nil:
      result.statements.add(stmt)
    self.nextToken()


proc parseStatement(self: Parser): Statement =
  case self.curToken.tokenType
  of LET:
    return self.parseLetStatement()
  of RETURN:
    return self.parseReturnStatement()
  else:
    return self.parseExpressionStatement()


proc parseLetStatement(self: Parser): Statement =
  let stmt = new LetStatement
  stmt.token = self.curToken

  if not self.expectPeek(IDENT):
    return nil

  stmt.name = Identifier(token: self.curToken, value: self.curToken.literal)

  if not self.expectPeek(ASSIGN):
    return nil

  self.nextToken()

  stmt.value = self.parseExpression(LOWEST)

  if self.peekTokenIs(SEMICOLON):
    self.nextToken()

  return stmt


proc curTokenIs(self: Parser, t: TokenType): bool =
  self.curToken.tokenType == t


proc peekTokenIs(self: Parser, t: TokenType): bool =
  self.peekToken.tokenType == t


proc expectPeek(self: Parser, t: TokenType): bool =
  if self.peekTokenIs(t):
    self.nextToken()
    return true
  self.peekError(t)
  false


proc Errors(self: Parser): seq[string] =
  self.errors


proc peekError(self: Parser, t: TokenType) =
  let msg = fmt"expected next token to be {t}, got {self.peekToken.tokenType} instead"
  self.errors.add(msg)


proc parseReturnStatement(self: Parser): Statement =
  let stmt = new ReturnStatement
  stmt.token = self.curToken

  self.nextToken()

  stmt.returnValue = self.parseExpression(LOWEST)

  if self.peekTokenIs(SEMICOLON):
    self.nextToken()

  return stmt


proc parseExpressionStatement(self: Parser): Statement =
  let stmt = new ExpressionStatement
  stmt.token = self.curToken

  stmt.expression = self.parseExpression(LOWEST)

  if self.peekTokenIs(SEMICOLON):
    self.nextToken()

  return stmt


proc parseExpression(self: Parser, precedence: Priority): Expression =
  if not self.prefixParseFns.hasKey(self.curToken.tokenType):
    self.noPrefixParseFnError(self.curToken.tokenType)
    return nil

  let prifix = self.prefixParseFns[self.curToken.tokenType]
  var leftExp = self.prifix()

  while not self.peekTokenIs(SEMICOLON) and precedence < self.peekPrecedence():
    let infix = self.infixParseFns[self.peekToken.tokenType]
    if infix == nil:
      return leftExp
    self.nextToken()
    leftExp = self.infix(leftExp)

  leftExp


proc parseIdentifier(self: Parser): Expression =
  Identifier(token: self.curToken, value: self.curToken.literal)


proc parseIntegerLiteral(self: Parser): Expression =
  let lit = IntegerLiteral(token: self.curToken)
  try:
    lit.value = self.curToken.literal.parseInt
  except:
    self.errors.add(fmt"could not parse {self.curToken.literal} as integer.")
    return nil
  lit

proc parseFloatLiteral(self: Parser): Expression =
  let lit = FloatLiteral(token: self.curToken)
  try:
    lit.value = self.curToken.literal.parseFloat
  except:
    self.errors.add(fmt"could not parse {self.curToken.literal} as float.")
    return nil
  lit


proc noPrefixParseFnError(self: Parser, t: TokenType) =
  let msg = fmt"no prefix parse function for {t} found"
  self.errors.add(msg)


proc parsePrefixExpression(self: Parser): Expression =
  let expression = PrefixExpression(
    token: self.curToken,
    operator: self.curToken.literal,
  )
  self.nextToken()
  expression.right = self.parseExpression(PREFIX)
  expression


proc peekPrecedence(self: Parser): Priority =
  if precedences.hasKey(self.peekToken.tokenType):
    return precedences[self.peekToken.tokenType]
  LOWEST


proc curPrecedence(self: Parser): Priority =
  if precedences.hasKey(self.curToken.tokenType):
    return precedences[self.curToken.tokenType]
  LOWEST


proc parseInfixExpression(self: Parser, left: Expression): Expression =
  let expression = InfixExpression(
    token: self.curToken,
    operator: self.curToken.literal,
    left: left,
  )
  let precedence = self.curPrecedence()
  self.nextToken()
  expression.right = self.parseExpression(precedence)
  expression


proc parseBoolean(self: Parser): Expression =
  Boolean(token: self.curToken, value: self.curTokenIs(TRUE))


proc parseGroupedExpression(self: Parser): Expression =
  self.nextToken()
  let exp = self.parseExpression(LOWEST)
  if not self.expectPeek(RPAREN):
    return nil
  exp


proc parseIfExpression(self: Parser): Expression =
  let expression = IfExpression(token: self.curToken)

  if not self.expectPeek(LPAREN):
    return nil

  self.nextToken()
  expression.condition = self.parseExpression(LOWEST)

  if not self.expectPeek(RPAREN):
    return nil

  if not self.expectPeek(LBRACE):
    return nil

  expression.consequence = self.parseBlockStatement()

  if self.peekTokenIs(ELSE):
    self.nextToken()

    if not self.expectPeek(LBRACE):
      return nil

    expression.alternative = self.parseBlockStatement()
  expression


proc parseBlockStatement(self: Parser): BlockStatement =
  result = BlockStatement(token: self.curToken)
  result.statements = newSeq[Statement]()

  self.nextToken()

  while not self.curTokenIs(RBRACE) and not self.curTokenIs(EOF):
    let stmt = self.parseStatement()
    if stmt != nil:
      result.statements.add(stmt)
    self.nextToken()


proc parseFunctionLiteral(self: Parser): Expression =
  let lit = FunctionLiteral(token: self.curToken)

  if not self.expectPeek(LPAREN):
    return nil

  lit.parameters = self.parseFunctionParameters()

  if not self.expectPeek(LBRACE):
    return nil

  lit.body = self.parseBlockStatement()
  lit


proc parseFunctionParameters(self: Parser): seq[Identifier] =
  result = newSeq[Identifier]()

  if self.peekTokenIs(RPAREN):
    self.nextToken()
    return result

  self.nextToken()

  var ident = Identifier(token: self.curToken, value: self.curToken.literal)
  result.add(ident)

  while self.peekTokenIs(COMMA):
    self.nextToken()
    self.nextToken()
    ident = Identifier(token: self.curToken, value: self.curToken.literal)
    result.add(ident)

  if not self.expectPeek(RPAREN):
    return @[]

  return result


proc parseCallExpression(self: Parser, f: Expression): Expression =
  let exp = CallExpression(token: self.curToken, function: f)
  exp.arguments = self.parseExpressionList(token.RPAREN)
  exp


# proc parseCallArguments(self: Parser): seq[Expression] =
#   result = newSeq[Expression]()

#   if self.peekTokenIs(RPAREN):
#     self.nextToken()
#     return result

#   self.nextToken()
#   result.add(self.parseExpression(LOWEST))

#   while self.peekTokenIs(COMMA):
#     self.nextToken()
#     self.nextToken()
#     result.add(self.parseExpression(LOWEST))

#   if not self.expectPeek(RPAREN):
#     return @[]

#   return result


proc parseStringLiteral(self: Parser): Expression =
  return ast.StringLiteral(token: self.curToken, value: self.curToken.literal)


proc parseArrayLiteral(self: Parser): Expression =
  let arr = ast.ArrayLiteral(token: self.curToken)
  arr.elements = self.parseExpressionList(token.RBRACKET)
  return arr


proc parseExpressionList(
  self: Parser,
  ends: token.TokenType
): seq[ast.Expression] =
  result = newSeq[ast.Expression]()

  if self.peekTokenIs(ends):
    self.nextToken()
    return result

  self.nextToken()
  result.add(self.parseExpression(LOWEST))

  while self.peekTokenIs(token.COMMA):
    self.nextToken()
    self.nextToken()
    result.add(self.parseExpression(LOWEST))

  if not self.expectPeek(ends):
    return @[]




when isMainModule:
  # let input = "let x = 5;"
  let input = "return 5;"
  var l = LexerNew(input)
  var p = ParserNew(l)
  echo p.lex[]
  echo p.curToken[]
  echo p.peekToken[]
  var program = p.parseProgram()
  var stmt = program.statements[0]
  echo stmt[]
