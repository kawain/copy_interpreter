import ast_
import object_

NULL = object_.Null()
TRUE = object_.Boolean(True)
FALSE = object_.Boolean(False)


def Eval(node):
    if type(node) is ast_.Program:
        return eval_statement(node.statements)
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
        return evalPrefixExpression(node.operator, right)
    elif type(node) is ast_.InfixExpression:
        left = Eval(node.left)
        right = Eval(node.right)
        return evalInfixExpression(node.operator, left, right)

    return None


def eval_statement(stmts):
    result = None
    for v in stmts:
        result = Eval(v)

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
        return NULL


def evalInfixExpression(operator, left, right):
    if left.Type() == object_.INTEGER_OBJ and right.Type() == object_.INTEGER_OBJ:
        return evalIntegerInfixExpression(operator, left, right)
    elif operator == "==":
        return nativeBoolToBooleanObject(left == right)
    elif operator == "!=":
        return nativeBoolToBooleanObject(left != right)
    else:
        NULL


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
        return NULL
