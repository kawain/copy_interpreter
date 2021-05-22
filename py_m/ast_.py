from abc import ABCMeta, abstractmethod
import token_


class Node(metaclass=ABCMeta):
    @abstractmethod
    def token_literal(self):
        pass

    @abstractmethod
    def string(self):
        pass


class Statement(Node):
    @abstractmethod
    def statement_node(self):
        pass


class Expression(Node):
    @abstractmethod
    def expression_node(self):
        pass


class Program(Node):
    def __init__(self):
        self.statements = []

    def token_literal(self):
        if len(self.statements) > 0:
            return self.statements[0].token_literal()
        else:
            return ""

    def string(self):
        s = ""
        for v in self.statements:
            s += v.string()
        return s

    def __str__(self):
        return "Program(Node)"


class LetStatement(Statement):
    """let文"""

    def __init__(self, token=None, name=None, value=None):
        self.token = token
        self.name = name
        self.value = value

    def token_literal(self):
        return self.token.literal

    def statement_node(self):
        pass

    def string(self):
        out = self.token_literal()
        out += " "
        out += self.name.string()
        out += " = "
        if self.value is not None:
            out += self.value.string()
        out += ";"
        return out

    def __str__(self):
        return "LetStatement(Statement)"


class Identifier(Expression):
    """識別子"""

    def __init__(self, token=None, value=None):
        self.token = token
        self.value = value

    def token_literal(self):
        return self.token.literal

    def expression_node(self):
        pass

    def string(self):
        return self.value

    def __str__(self):
        return "Identifier(Expression)"


class ReturnStatement(Statement):
    """return文"""

    def __init__(self, token=None, return_value=None):
        self.token = token
        self.return_value = return_value

    def token_literal(self):
        return self.token.literal

    def statement_node(self):
        pass

    def string(self):
        out = self.token_literal()
        out += " "
        if self.return_value is not None:
            out += self.return_value.string()
        out += ";"
        return out

    def __str__(self):
        return "ReturnStatement(Statement)"


class ExpressionStatement(Statement):
    """式文"""

    def __init__(self, token=None, expression=None):
        self.token = token
        self.expression = expression

    def token_literal(self):
        return self.token.literal

    def statement_node(self):
        pass

    def string(self):
        if self.expression is not None:
            return self.expression.string()

        return ""

    def __str__(self):
        return "ExpressionStatement(Statement)"


class IntegerLiteral(Expression):
    """整数"""

    def __init__(self, token=None, value=None):
        self.token = token
        self.value = value

    def token_literal(self):
        return self.token.literal

    def expression_node(self):
        pass

    def string(self):
        return self.token.literal

    def __str__(self):
        return "IntegerLiteral(Expression)"


class FloatLiteral(Expression):
    """実数"""

    def __init__(self, token=None, value=None):
        self.token = token
        self.value = value

    def token_literal(self):
        return self.token.literal

    def expression_node(self):
        pass

    def string(self):
        return self.token.literal

    def __str__(self):
        return "FloatLiteral(Expression)"


class PrefixExpression(Expression):
    """前置演算子"""

    def __init__(self, token=None, operator="", right=None):
        self.token = token
        # "-", "!" が来る
        self.operator = operator
        self.right = right

    def token_literal(self):
        return self.token.literal

    def expression_node(self):
        pass

    def string(self):
        out = "("
        out += self.operator
        out += self.right.string()
        out += ")"
        return out

    def __str__(self):
        return "PrefixExpression(Expression)"


class InfixExpression(Expression):
    """中置演算子"""

    def __init__(self, token=None, left=None, operator="", right=None):
        self.token = token
        self.left = left
        self.operator = operator
        self.right = right

    def token_literal(self):
        return self.token.literal

    def expression_node(self):
        pass

    def string(self):
        out = "("
        out += self.left.string()
        out += " "
        out += self.operator
        out += " "
        out += self.right.string()
        out += ")"
        return out

    def __str__(self):
        return "InfixExpression(Expression)"


class Boolean(Expression):
    """真偽値"""

    def __init__(self, token=None, value=False):
        self.token = token
        self.value = value

    def token_literal(self):
        return self.token.literal

    def expression_node(self):
        pass

    def string(self):
        return self.token.literal

    def __str__(self):
        return "Boolean(Expression)"


class IfExpression(Expression):
    """if式"""

    def __init__(self, token=None, condition=None, consequence=None, alternative=None):
        self.token = token
        self.condition = condition
        self.consequence = consequence
        self.alternative = alternative

    def token_literal(self):
        return self.token.literal

    def expression_node(self):
        pass

    def string(self):
        out = "if"
        out += self.condition.string()
        out += " "
        out += self.consequence.string()
        if self.alternative is not None:
            out += "else "
            out += self.alternative.string()
        return out

    def __str__(self):
        return "IfExpression(Expression)"


class BlockStatement(Statement):
    """ブロック文"""

    def __init__(self, token=None):
        self.token = token
        self.statements = []

    def token_literal(self):
        return self.token.literal

    def statement_node(self):
        pass

    def string(self):
        s = ""
        for v in self.statements:
            s += v.string()
        return s

    def __str__(self):
        return "BlockStatement(Statement)"


class FunctionLiteral(Expression):
    """関数リテラル"""

    def __init__(self, token=None, parameters=[], body=None):
        self.token = token
        # Identifier のリスト
        self.parameters = []
        # BlockStatement
        self.body = body

    def token_literal(self):
        return self.token.literal

    def expression_node(self):
        pass

    def string(self):
        params = []
        for v in self.parameters:
            params.append(v.string())

        out = self.token_literal()
        out += "("
        out += ", ".join(params)
        out += ")"
        out += self.body.string()
        return out

    def __str__(self):
        return "FunctionLiteral(Expression)"


class CallExpression(Expression):
    """呼び出し式"""

    def __init__(self, token=None, function=None, arguments=[]):
        self.token = token
        # Identifier or FunctionLiteral
        self.function = function
        # []Expression
        self.arguments = arguments

    def token_literal(self):
        return self.token.literal

    def expression_node(self):
        pass

    def string(self):
        args = []
        for v in self.arguments:
            args.append(v.string())

        out = self.function.string()
        out += "("
        out += ", ".join(args)
        out += ")"

        return out

    def __str__(self):
        return "CallExpression(Expression)"


class StringLiteral(Expression):
    """文字列"""

    def __init__(self, token=None, value=None):
        self.token = token
        self.value = value

    def token_literal(self):
        return self.token.literal

    def expression_node(self):
        pass

    def string(self):
        return self.token.literal

    def __str__(self):
        return "StringLiteral(Expression)"


class ArrayLiteral(Expression):
    """配列リテラル"""

    def __init__(self, token=None, elements=[]):
        # the '[' token
        self.token: token_.TokenType = token
        # []Expression
        self.elements: list[Expression] = elements

    def token_literal(self):
        return self.token.literal

    def expression_node(self):
        pass

    def string(self):
        el = []
        for v in self.elements:
            el.append(v.string())

        out = "["
        out += ", ".join(el)
        out += "]"

        return out

    def __str__(self):
        return "ArrayLiteral(Expression)"


if __name__ == "__main__":
    from token_ import Token, TokenType
    ls = LetStatement(
        token=Token(TokenType.LET, "let"),
        name=Identifier(Token(TokenType.IDENT, "myVar"), "myVar"),
        value=Identifier(Token(TokenType.IDENT, "anothorVal"), "anothorVal")
    )
    p = Program()
    p.statements.append(ls)
    print(p.string())
