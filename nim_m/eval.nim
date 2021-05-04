import obj
import ast

proc Eval*(node: ast.Node): Obj
proc evalProgram(program: ast.Program): Obj
proc nativeBoolToBooleanObject(input: bool): obj.Boolean
proc evalPrefixExpression(operator: string, right: Obj): Obj
proc evalBangOperatorExpression(right: Obj): Obj
proc evalMinusPrefixOperatorExpression(right: Obj): Obj

let
  NULL* = obj.Null()
  TRUE* = obj.Boolean(value: true)
  FALSE* = obj.Boolean(value: false)


proc Eval*(node: Node): obj.Obj =
  if node of ast.Program:
    return evalProgram(ast.Program(node))
  elif node of ast.ExpressionStatement:
    return Eval(ast.ExpressionStatement(node).expression)
  elif node of ast.IntegerLiteral:
    return obj.Integer(value: ast.IntegerLiteral(node).value)
  elif node of ast.Boolean:
    return nativeBoolToBooleanObject(ast.Boolean(node).value)
  elif node of PrefixExpression:
    let right = Eval(PrefixExpression(node).right)
    return evalPrefixExpression(PrefixExpression(node).operator, right)

  return nil


proc evalProgram(program: ast.Program): obj.Obj =
  for v in program.statements:
    result = Eval(v)


proc nativeBoolToBooleanObject(input: bool): obj.Boolean =
  if input:
    return TRUE
  FALSE


proc evalPrefixExpression(operator: string, right: Obj): Obj =
  case operator
  of "!":
    return evalBangOperatorExpression(right)
  of "-":
    return evalMinusPrefixOperatorExpression(right)
  else:
    return NULL


proc evalBangOperatorExpression(right: Obj): Obj =
  if right == TRUE:
    return FALSE
  elif right == FALSE:
    return TRUE
  elif right == NULL:
    return TRUE
  else:
    return FALSE


proc evalMinusPrefixOperatorExpression(right: Obj): Obj =
  if right.Type() != INTEGER_OBJ:
    return NULL
  let value = Integer(right).value
  return Integer(value: -value)

