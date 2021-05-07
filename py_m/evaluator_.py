import ast_
import object_


def Eval(node):
    if type(node) is ast_.Program:
        return eval_statement(node.statements)
    elif type(node) is ast_.ExpressionStatement:
        return Eval(node.expression)
    elif type(node) is ast_.IntegerLiteral:
        return object_.Integer(node.value)

    return None


def eval_statement(stmts):
    result = None
    for v in stmts:
        result = Eval(v)

    return result
