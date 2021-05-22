import strutils
import token


type
  Node* = ref object of RootObj
  Statement* = ref object of Node
  Expression* = ref object of Node

method tokenLiteral(self: Node): string{.base.} =
  result = "tokenLiteral(self: Node)"

method toString(self: Node): string{.base.} =
  result = "toString(self: Node)"


type Program* = ref object of Node
  # let文、return文、式文
  statements*: seq[Statement]

method tokenLiteral*(self: Program): string =
  if len(self.statements) > 0:
    return self.statements[0].tokenLiteral()
  ""

method toString*(self: Program): string =
  result = ""
  for v in self.statements:
    result.add(v.toString())


type Identifier* = ref object of Expression
  token*: Token
  value*: string

method tokenLiteral*(self: Identifier): string =
  self.token.literal

method toString*(self: Identifier): string =
  self.value


type LetStatement* = ref object of Statement
  token*: Token
  name*: Identifier
  value*: Expression

method tokenLiteral*(self: LetStatement): string =
  self.token.literal

method toString*(self: LetStatement): string =
  result = self.tokenLiteral() & " "
  result.add(self.name.toString())
  result.add(" = ")
  if self.value != nil:
    result.add(self.value.toString())
  result.add(";")


type ReturnStatement* = ref object of Statement
  token*: Token
  returnValue*: Expression

method tokenLiteral*(self: ReturnStatement): string =
  self.token.literal

method toString*(self: ReturnStatement): string =
  result = self.tokenLiteral() & " "
  if self.returnValue != nil:
    result.add(self.returnValue.toString())
  result.add(";")


type ExpressionStatement* = ref object of Statement
  token*: Token
  expression*: Expression

method tokenLiteral*(self: ExpressionStatement): string =
  self.token.literal

method toString*(self: ExpressionStatement): string =
  if self.expression != nil:
    return self.expression.toString()
  ""


type IntegerLiteral* = ref object of Expression
  token*: Token
  value*: int

method tokenLiteral*(self: IntegerLiteral): string =
  self.token.literal

method toString*(self: IntegerLiteral): string =
  self.token.literal


type FloatLiteral* = ref object of Expression
  token*: Token
  value*: float

method tokenLiteral*(self: FloatLiteral): string =
  self.token.literal

method toString*(self: FloatLiteral): string =
  self.token.literal


type PrefixExpression* = ref object of Expression
  token*: Token
  operator*: string
  right*: Expression

method tokenLiteral*(self: PrefixExpression): string =
  self.token.literal

method toString*(self: PrefixExpression): string =
  result = "("
  result.add(self.operator)
  result.add(self.right.toString())
  result.add(")")


type InfixExpression* = ref object of Expression
  token*: Token
  left*: Expression
  operator*: string
  right*: Expression

method tokenLiteral*(self: InfixExpression): string =
  self.token.literal

method toString*(self: InfixExpression): string =
  result = "("
  result.add(self.left.toString())
  result.add(" " & self.operator & " ")
  result.add(self.right.toString())
  result.add(")")


type Boolean* = ref object of Expression
  token*: Token
  value*: bool

method tokenLiteral*(self: Boolean): string =
  self.token.literal

method toString*(self: Boolean): string =
  self.token.literal


type BlockStatement* = ref object of Statement
  token*: Token
  statements*: seq[Statement]

method tokenLiteral*(self: BlockStatement): string =
  self.token.literal

method toString*(self: BlockStatement): string =
  result = ""
  for v in self.statements:
    result.add(v.toString())


type IfExpression* = ref object of Expression
  token*: Token
  condition*: Expression
  consequence*: BlockStatement
  alternative*: BlockStatement

method tokenLiteral*(self: IfExpression): string =
  self.token.literal

method toString*(self: IfExpression): string =
  result = "if"
  result.add(self.condition.toString())
  result.add(" ")
  result.add(self.consequence.toString())
  if self.alternative != nil:
    result.add("else ")
    result.add(self.alternative.toString())


type FunctionLiteral* = ref object of Expression
  token*: Token
  parameters*: seq[Identifier]
  body*: BlockStatement

method tokenLiteral*(self: FunctionLiteral): string =
  self.token.literal

method toString*(self: FunctionLiteral): string =
  var params = newSeq[string]()
  for v in self.parameters:
    params.add(v.toString())

  result = self.tokenLiteral()
  result.add("(")
  result.add(params.join(", "))
  result.add(")")
  result.add(self.body.toString())


type CallExpression* = ref object of Expression
  token*: Token
  function*: Expression
  arguments*: seq[Expression]

method tokenLiteral*(self: CallExpression): string =
  self.token.literal

method toString*(self: CallExpression): string =
  var args = newSeq[string]()
  for v in self.arguments:
    args.add(v.toString())

  result = self.function.toString()
  result.add("(")
  result.add(args.join(", "))
  result.add(")")


type StringLiteral* = ref object of Expression
  token*: Token
  value*: string

method tokenLiteral*(self: StringLiteral): string =
  self.token.literal

method toString*(self: StringLiteral): string =
  self.token.literal


type ArrayLiteral* = ref object of Expression
  # the '[' token
  token*: Token
  elements*: seq[Expression]

method tokenLiteral*(self: ArrayLiteral): string =
  self.token.literal

method toString*(self: ArrayLiteral): string =
  var el = newSeq[string]()
  for v in self.elements:
    el.add(v.toString())

  result = "["
  result.add(el.join(", "))
  result.add("]")





when isMainModule:
  var t = Token(tokenType: LET, literal: "let")
  # echo t[]
  var i = Identifier(token: t, value: "x")
  # echo i[]
  # echo i.tokenLiteral()
  # echo i.toString()

  var l = LetStatement(token: t, name: i, value: i)
  echo l[]
  echo l.token[]
  echo l.name[]
  echo l.value[]
  echo l.toString()
  echo 0
