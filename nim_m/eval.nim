import strformat
import tables
import obj
import ast


proc Eval*(node: ast.Node, e: obj.Environment): obj.Obj
proc evalProgram(program: ast.Program, e: obj.Environment): obj.Obj
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
proc evalBlockStatement(b: ast.BlockStatement, e: obj.Environment): obj.Obj
proc evalIfExpression(ie: ast.IfExpression, e: obj.Environment): obj.Obj
proc isError(obj: obj.Obj): bool
proc isTruthy(obj: obj.Obj): bool
proc newError(e: string): obj.Error
proc evalIdentifier(node: ast.Identifier, e: obj.Environment): obj.Obj
proc evalExpressions(exps: seq[ast.Expression], e: obj.Environment): seq[obj.Obj]
proc applyFunction(fn: obj.Obj, args: seq[obj.Obj]): obj.Obj
proc extendFunctionEnv(fn: obj.Function, args: seq[obj.Obj]): obj.Environment
proc unwrapReturnValue(o: obj.Obj): obj.Obj
proc evalStringInfixExpression(
  operator: string,
  left: obj.Obj,
  right: obj.Obj
): obj.Obj


let
  NULL* = obj.Null()
  TRUE* = obj.Boolean(value: true)
  FALSE* = obj.Boolean(value: false)


# 組み込み関数
var builtins = initTable[string, obj.Builtin]()

proc builtin_len(args: seq[obj.Obj]): obj.Obj =
  if len(args) != 1:
    return newError(fmt"wrong number of arguments. got={len(args)}, want=1")
  if args[0] of obj.String:
    let arg = obj.String(args[0])
    return obj.Integer(value: len(arg.value))

  return newError(fmt"argument to `len` not supported, got {args[0].Type()}")

builtins["len"] = obj.Builtin(fn: builtin_len)




proc Eval*(node: Node, e: obj.Environment): obj.Obj =
  if node of ast.Program:
    let node2 = ast.Program(node)
    return evalProgram(node2, e)
  elif node of ast.ExpressionStatement:
    let node2 = ast.ExpressionStatement(node)
    return Eval(node2.expression, e)
  elif node of ast.IntegerLiteral:
    let node2 = ast.IntegerLiteral(node)
    return obj.Integer(value: node2.value)
  elif node of ast.Boolean:
    let node2 = ast.Boolean(node)
    return nativeBoolToBooleanObject(node2.value)
  elif node of ast.PrefixExpression:
    let node2 = ast.PrefixExpression(node)
    let right = Eval(node2.right, e)
    if isError(right):
      return right
    return evalPrefixExpression(node2.operator, right)
  elif node of ast.InfixExpression:
    let node2 = ast.InfixExpression(node)
    let left = Eval(node2.left, e)
    if isError(left):
      return left
    let right = Eval(node2.right, e)
    if isError(right):
      return right
    return evalInfixExpression(node2.operator, left, right)
  elif node of ast.BlockStatement:
    let node2 = ast.BlockStatement(node)
    return evalBlockStatement(node2, e)
  elif node of ast.IfExpression:
    let node2 = ast.IfExpression(node)
    return evalIfExpression(node2, e)
  elif node of ast.ReturnStatement:
    let node2 = ast.ReturnStatement(node)
    let val = Eval(node2.returnValue, e)
    if isError(val):
      return val
    return obj.ReturnValue(value: val)
  elif node of ast.LetStatement:
    let node2 = ast.LetStatement(node)
    let val = Eval(node2.value, e)
    if isError(val):
      return val
    discard e.set(node2.name.value, val)
  elif node of ast.Identifier:
    let node2 = ast.Identifier(node)
    return evalIdentifier(node2, e)
  elif node of ast.FunctionLiteral:
    let node2 = ast.FunctionLiteral(node)
    let params = node2.parameters
    let body = node2.body
    return obj.Function(parameters: params, env: e, body: body)
  elif node of ast.CallExpression:
    let node2 = ast.CallExpression(node)
    let fn = Eval(node2.function, e)
    if isError(fn):
      return fn
    let args = evalExpressions(node2.arguments, e)
    if len(args) == 1 and isError(args[0]):
      return args[0]
    return applyFunction(fn, args)
  elif node of ast.StringLiteral:
    let node2 = ast.StringLiteral(node)
    return obj.String(value: node2.value)

  return nil


proc evalProgram(program: ast.Program, e: obj.Environment): obj.Obj =
  for v in program.statements:
    result = Eval(v, e)
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
  elif left.Type() == obj.STRING_OBJ and right.Type() == obj.STRING_OBJ:
    return evalStringInfixExpression(operator, left, right)

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


proc evalBlockStatement(b: ast.BlockStatement, e: obj.Environment): obj.Obj =
  for v in b.statements:
    result = Eval(v, e)
    if result != nil:
      let rt = result.Type()
      if rt == obj.RETURN_VALUE_OBJ or rt == obj.ERROR_OBJ:
        return result

  return result


proc evalIfExpression(ie: ast.IfExpression, e: obj.Environment): obj.Obj =
  let condition = Eval(ie.condition, e)
  if isError(condition):
    return condition

  if isTruthy(condition):
    return Eval(ie.consequence, e)
  elif ie.alternative != nil:
    return Eval(ie.alternative, e)
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


proc evalIdentifier(node: ast.Identifier, e: obj.Environment): obj.Obj =
  let tup = e.get(node.value)
  if tup[1]:
    return tup[0]
  if builtins.hasKey(node.value):
    return builtins[node.value]
  return newError(fmt"identifier not found: {node.value}")


proc evalExpressions(exps: seq[ast.Expression], e: obj.Environment): seq[obj.Obj] =
  result = newSeq[obj.Obj]()
  for v in exps:
    let evaluated = Eval(v, e)
    if isError(evaluated):
      result.add(evaluated)
      return result
    result.add(evaluated)


proc applyFunction(fn: obj.Obj, args: seq[obj.Obj]): obj.Obj =
  if fn of obj.Function:
    let fn2 = obj.Function(fn)
    let extendedEnv = extendFunctionEnv(fn2, args)
    let evaluated = Eval(fn2.body, extendedEnv)
    return unwrapReturnValue(evaluated)
  elif fn of obj.Builtin:
    let fn2 = obj.Builtin(fn)
    return fn2.fn(args)
  else:
    return newError(fmt"not a function: {fn.Type()}")


proc extendFunctionEnv(fn: obj.Function, args: seq[obj.Obj]): obj.Environment =
  let env = obj.NewEnclosedEnvironment(fn.env)
  for paramIdx, param in fn.parameters:
    discard env.set(param.value, args[paramIdx])
  return env


proc unwrapReturnValue(o: obj.Obj): obj.Obj =
  if o of obj.ReturnValue:
    let rv = obj.ReturnValue(o)
    return rv.value
  return o


proc evalStringInfixExpression(
  operator: string,
  left: obj.Obj,
  right: obj.Obj
): obj.Obj =

  if operator != "+":
    return newError(fmt"unknown operator: {left.Type()} {operator} {right.Type()}")

  let leftVal = obj.String(left).value
  let rightVal = obj.String(right).value
  return obj.String(value: leftVal & rightVal)

