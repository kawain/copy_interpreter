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
