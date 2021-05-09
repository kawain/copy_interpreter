import ast_
import object_

NULL = object_.Null()
TRUE = object_.Boolean(True)
FALSE = object_.Boolean(False)


def Eval(node):
    if type(node) is ast_.Program:
        return evalProgram(node)
    elif type(node) is ast_.ExpressionStatement:
        return Eval(node.expression)
    elif type(node) is ast_.IntegerLiteral:
        return object_.Integer(node.value)
    elif type(node) is ast_.FloatLiteral:
        return object_.Float(node.value)
    elif type(node) is ast_.Boolean:
        return nativeBoolToBooleanObject(node.value)
    elif type(node) is ast_.PrefixExpression:
        right = Eval(node.right)
        if isError(right):
            return right
        return evalPrefixExpression(node.operator, right)
    elif type(node) is ast_.InfixExpression:
        left = Eval(node.left)
        if isError(left):
            return left
        right = Eval(node.right)
        if isError(right):
            return right
        return evalInfixExpression(node.operator, left, right)
    elif type(node) is ast_.BlockStatement:
        return evalBlockStatement(node)
    elif type(node) is ast_.IfExpression:
        return evalIfExpression(node)
    elif type(node) is ast_.ReturnStatement:
        val = Eval(node.return_value)
        if isError(val):
            return val
        return object_.ReturnValue(val)

    return None


def evalProgram(program):
    result = None
    for v in program.statements:
        result = Eval(v)
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
        return newError("unknown operator", "-" + right.Type())


def evalInfixExpression(operator, left, right):
    if left.Type() == object_.INTEGER_OBJ and right.Type() == object_.INTEGER_OBJ:
        return evalIntegerInfixExpression(operator, left, right)
    elif operator == "==":
        return nativeBoolToBooleanObject(left == right)
    elif operator == "!=":
        return nativeBoolToBooleanObject(left != right)
    elif left.Type() != right.Type():
        return newError("type mismatch", left.Type(), operator, right.Type())
    else:
        return newError("unknown operator", left.Type(), operator, right.Type())


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
        return newError("unknown operator", left.Type(), operator, right.Type())


def evalBlockStatement(block):
    result = None
    for v in block.statements:
        result = Eval(v)
        if result is not None:
            rt = result.Type()
            if rt == object_.RETURN_VALUE_OBJ or rt == object_.ERROR_OBJ:
                return result
    return result


def evalIfExpression(ie):
    # ie ast_.IfExpression
    condition = Eval(ie.condition)
    if isError(condition):
        return condition
    if isTruthy(condition):
        return Eval(ie.consequence)
    elif ie.alternative is not None:
        return Eval(ie.alternative)
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
    return object_.Error(f"{format}: {' '.join(a)}")


def isError(obj):
    if obj is not None:
        return obj.Type() == object_.ERROR_OBJ
    return False
