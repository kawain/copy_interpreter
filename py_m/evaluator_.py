import ast_
import object_
import env_

NULL = object_.Null()
TRUE = object_.Boolean(True)
FALSE = object_.Boolean(False)


def Eval(node, env):
    if type(node) is ast_.Program:
        return evalProgram(node, env)
    elif type(node) is ast_.ExpressionStatement:
        return Eval(node.expression, env)
    elif type(node) is ast_.IntegerLiteral:
        return object_.Integer(node.value)
    elif type(node) is ast_.FloatLiteral:
        return object_.Float(node.value)
    elif type(node) is ast_.Boolean:
        return nativeBoolToBooleanObject(node.value)
    elif type(node) is ast_.PrefixExpression:
        right = Eval(node.right, env)
        if isError(right):
            return right
        return evalPrefixExpression(node.operator, right)
    elif type(node) is ast_.InfixExpression:
        left = Eval(node.left, env)
        if isError(left):
            return left
        right = Eval(node.right, env)
        if isError(right):
            return right
        return evalInfixExpression(node.operator, left, right)
    elif type(node) is ast_.BlockStatement:
        return evalBlockStatement(node, env)
    elif type(node) is ast_.IfExpression:
        return evalIfExpression(node, env)
    elif type(node) is ast_.ReturnStatement:
        val = Eval(node.return_value, env)
        if isError(val):
            return val
        return object_.ReturnValue(val)
    elif type(node) is ast_.LetStatement:
        val = Eval(node.value, env)
        if isError(val):
            return val
        env.Set(node.name.value, val)
    elif type(node) is ast_.Identifier:
        return evalIdentifier(node, env)
    elif type(node) is ast_.FunctionLiteral:
        params = node.parameters
        body = node.body
        return object_.Function(parameters=params, body=body, env=env)
    elif type(node) is ast_.CallExpression:
        function = Eval(node.function, env)
        if isError(function):
            return function
        args = evalExpressions(node.arguments, env)
        if len(args) == 1 and isError(args[0]):
            return args[0]

        return applyFunction(function, args)

    return None


def evalProgram(program, env):
    result = None
    for v in program.statements:
        result = Eval(v, env)
        if type(result) is object_.ReturnValue:
            return result.value
        elif type(result) is object_.Error:
            return result

    return result


def nativeBoolToBooleanObject(input):
    if input:
        return TRUE
    return FALSE


def evalPrefixExpression(operator, right):
    if operator == "!":
        return evalBangOperatorExpression(right)
    elif operator == "-":
        return evalMinusPrefixOperatorExpression(right)
    else:
        return NULL


def evalBangOperatorExpression(right):
    if right == TRUE:
        return FALSE
    elif right == FALSE:
        return TRUE
    elif right == NULL:
        return TRUE
    else:
        return FALSE


def evalMinusPrefixOperatorExpression(right):
    if right.Type() == object_.INTEGER_OBJ:
        return object_.Integer(-right.value)
    elif right.Type() == object_.FLOAT_OBJ:
        return object_.Float(-right.value)
    else:
        return newError("unknown operator: ", "-" + right.Type())


def evalInfixExpression(operator, left, right):
    if left.Type() == object_.INTEGER_OBJ and right.Type() == object_.INTEGER_OBJ:
        return evalIntegerInfixExpression(operator, left, right)
    elif operator == "==":
        return nativeBoolToBooleanObject(left == right)
    elif operator == "!=":
        return nativeBoolToBooleanObject(left != right)
    elif left.Type() != right.Type():
        return newError("type mismatch: ", left.Type(), operator, right.Type())
    else:
        return newError("unknown operator: ", left.Type(), operator, right.Type())


def evalIntegerInfixExpression(operator, left, right):
    left_val = left.value
    right_val = right.value

    if operator == "+":
        return object_.Integer(left_val + right_val)
    elif operator == "-":
        return object_.Integer(left_val - right_val)
    elif operator == "*":
        return object_.Integer(left_val * right_val)
    elif operator == "/":
        return object_.Integer(left_val / right_val)
    elif operator == "<":
        return nativeBoolToBooleanObject(left_val < right_val)
    elif operator == ">":
        return nativeBoolToBooleanObject(left_val > right_val)
    elif operator == "==":
        return nativeBoolToBooleanObject(left_val == right_val)
    elif operator == "!=":
        return nativeBoolToBooleanObject(left_val != right_val)
    else:
        return newError("unknown operator: ", left.Type(), operator, right.Type())


def evalBlockStatement(block, env):
    result = None
    for v in block.statements:
        result = Eval(v, env)
        if result is not None:
            rt = result.Type()
            if rt == object_.RETURN_VALUE_OBJ or rt == object_.ERROR_OBJ:
                return result
    return result


def evalIfExpression(ie, env):
    # ie ast_.IfExpression
    condition = Eval(ie.condition, env)
    if isError(condition):
        return condition
    if isTruthy(condition):
        return Eval(ie.consequence, env)
    elif ie.alternative is not None:
        return Eval(ie.alternative, env)
    else:
        return NULL


def isTruthy(obj):
    if obj == NULL:
        return False
    elif obj == TRUE:
        return True
    elif obj == FALSE:
        return False
    else:
        True


def newError(format, *a):
    return object_.Error(f"{format}{' '.join(a)}")


def isError(obj):
    if obj is not None:
        return obj.Type() == object_.ERROR_OBJ
    return False


def evalIdentifier(node, env):
    val = env.Get(node.value)
    if val is None:
        return newError("identifier not found: " + node.value)
    return val


def evalExpressions(exps, env):
    result = []
    for v in exps:
        evaluated = Eval(v, env)
        if isError(evaluated):
            return []
        result.append(evaluated)
    return result


def applyFunction(fn, args):
    if type(fn) is not object_.Function:
        return newError("not a function: ", fn.Type())

    extendedEnv = extendFunctionEnv(fn, args)
    evaluated = Eval(fn.body, extendedEnv)
    return unwrapReturnValue(evaluated)


def extendFunctionEnv(fn, args):
    env = env_.NewEnclosedEnvironment(fn.env)

    for paramIdx, param in enumerate(fn.parameters):
        env.Set(param.value, args[paramIdx])

    return env


def unwrapReturnValue(obj):
    if type(obj) is object_.ReturnValue:
        return obj.value

    return obj
