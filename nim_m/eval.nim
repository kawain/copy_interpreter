import obj
import ast

proc Eval*(node: ast.Node): Obj
proc evalProgram(program: ast.Program): Obj
proc nativeBoolToBooleanObject(input: bool): obj.Boolean

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

  return nil


proc evalProgram(program: ast.Program): obj.Obj =
  for v in program.statements:
    result = Eval(v)


proc nativeBoolToBooleanObject(input: bool): obj.Boolean =
  if input:
    return TRUE
  FALSE
