import obj
import ast
import strformat

proc Eval*(node: ast.Node): obj.Obj
proc evalProgram(program: ast.Program): obj.Obj
proc nativeBoolToBooleanObject(input: bool): obj.Boolean
proc evalPrefixExpression(operator: string, right: obj.Obj): obj.Obj
proc evalBangOperatorExpression(right: obj.Obj): obj.Obj
proc evalMinusPrefixOperatorExpression(right: obj.Obj): obj.Obj
proc evalInfixExpression(
  operator: string, left: obj.Obj, right: obj.Obj
): obj.Obj
proc evalIntegerInfixExpression(
  operator: string, left: obj.Obj, right: obj.Obj
): obj.Obj
proc evalBlockStatement(b: ast.BlockStatement): obj.Obj
proc evalIfExpression(ie: ast.IfExpression): obj.Obj
proc isError(obj: obj.Obj): bool
proc isTruthy(obj: obj.Obj): bool

proc newError(e: string): obj.Error


let
  NULL* = obj.Null()
  TRUE* = obj.Boolean(value: true)
  FALSE* = obj.Boolean(value: false)


proc Eval*(node: Node): obj.Obj =
  if node of ast.Program:
    let node2 = ast.Program(node)
    return evalProgram(node2)
  elif node of ast.ExpressionStatement:
    let node2 = ast.ExpressionStatement(node)
    return Eval(node2.expression)
  elif node of ast.IntegerLiteral:
    let node2 = ast.IntegerLiteral(node)
    return obj.Integer(value: node2.value)
  elif node of ast.Boolean:
    let node2 = ast.Boolean(node)
    return nativeBoolToBooleanObject(node2.value)
  elif node of ast.PrefixExpression:
    let node2 = ast.PrefixExpression(node)
    let right = Eval(node2.right)
    if isError(right):
      return right
    return evalPrefixExpression(node2.operator, right)
  elif node of ast.InfixExpression:
    let node2 = ast.InfixExpression(node)
    let left = Eval(node2.left)
    if isError(left):
      return left
    let right = Eval(node2.right)
    if isError(right):
      return right
    return evalInfixExpression(node2.operator, left, right)
  elif node of ast.BlockStatement:
    let node2 = ast.BlockStatement(node)
    return evalBlockStatement(node2)
  elif node of ast.IfExpression:
    let node2 = ast.IfExpression(node)
    return evalIfExpression(node2)
  elif node of ast.ReturnStatement:
    let node2 = ast.ReturnStatement(node)
    let val = Eval(node2.returnValue)
    if isError(val):
      return val
    return obj.ReturnValue(value: val)

  return nil


proc evalProgram(program: ast.Program): obj.Obj =
  for v in program.statements:
    result = Eval(v)
    if result of obj.ReturnValue:
      # ReturnValue なら return する
      return obj.ReturnValue(result).value
    elif result of obj.Error:
      return obj.Error(result)


proc nativeBoolToBooleanObject(input: bool): obj.Boolean =
  if input:
    return TRUE
  FALSE


proc evalPrefixExpression(operator: string, right: obj.Obj): obj.Obj =
  case operator
  of "!":
    return evalBangOperatorExpression(right)
  of "-":
    return evalMinusPrefixOperatorExpression(right)
  else:
    return newError(fmt"unknown operator: {operator} {right.Type()}")


proc evalBangOperatorExpression(right: obj.Obj): obj.Obj =
  if right == TRUE:
    return FALSE
  elif right == FALSE:
    return TRUE
  elif right == NULL:
    return TRUE
  else:
    return FALSE


proc evalMinusPrefixOperatorExpression(right: obj.Obj): obj.Obj =
  if right.Type() != obj.INTEGER_OBJ:
    return newError(fmt"unknown operator: -{right.Type()}")
  let value = obj.Integer(right).value
  return obj.Integer(value: -value)


proc evalInfixExpression(
  operator: string,
  left: obj.Obj,
  right: obj.Obj,
): obj.Obj =
  if left.Type() == obj.INTEGER_OBJ and right.Type() == obj.INTEGER_OBJ:
    return evalIntegerInfixExpression(operator, left, right)
  elif operator == "==":
    return nativeBoolToBooleanObject(left == right)
  elif operator == "!=":
    return nativeBoolToBooleanObject(left != right)
  elif left.Type() != right.Type():
    return newError(fmt"type mismatch: {left.Type()} {operator} {right.Type()}")
  else:
    return newError(fmt"unknown operator: {left.Type()} {operator} {right.Type()}")


proc evalIntegerInfixExpression(
  operator: string,
  left: obj.Obj,
  right: obj.Obj,
): obj.Obj =
  let leftVal = Integer(left).value
  let rightVal = Integer(right).value

  case operator
  of "+":
    return Integer(value: leftVal + rightVal)
  of "-":
    return Integer(value: leftVal - rightVal)
  of "*":
    return Integer(value: leftVal * rightVal)
  of "/":
    return Integer(value: toInt(leftVal / rightVal))
  of "<":
    return nativeBoolToBooleanObject(leftVal < rightVal)
  of ">":
    return nativeBoolToBooleanObject(leftVal > rightVal)
  of "==":
    return nativeBoolToBooleanObject(leftVal == rightVal)
  of "!=":
    return nativeBoolToBooleanObject(leftVal != rightVal)
  else:
    return newError(fmt"unknown operator: {left.Type()} {operator} {right.Type()}")


proc evalBlockStatement(b: ast.BlockStatement): obj.Obj =
  for v in b.statements:
    result = Eval(v)
    if result != nil:
      let rt = result.Type()
      if rt == obj.RETURN_VALUE_OBJ or rt == obj.ERROR_OBJ:
        return result

  return result


proc evalIfExpression(ie: ast.IfExpression): obj.Obj =
  let condition = Eval(ie.condition)
  if isError(condition):
    return condition

  if isTruthy(condition):
    return Eval(ie.consequence)
  elif ie.alternative != nil:
    return Eval(ie.alternative)
  else:
    return NULL


proc isTruthy(obj: obj.Obj): bool =
  if obj == NULL:
    return false
  elif obj == TRUE:
    return true
  elif obj == FALSE:
    return false
  else:
    return true


proc isError(obj: obj.Obj): bool =
  if obj != nil:
    return obj.Type() == ERROR_OBJ
  false


proc newError(e: string): Error =
  return Error(message: e)


