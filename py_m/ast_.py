from abc import ABCMeta, abstractmethod


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
            return self.statements[0].tokenLiteral()
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


# class ReturnStatement(Statement):
#     def __init__(self, token=None, return_value=None):
#         self.token = token
#         self.return_value = return_value

#     def token_literal(self):
#         return self.token.literal

#     def statement_node(self):
#         pass

#     def string(self):
#         out = self.token_literal()
#         out += " "
#         if self.return_value is not None:
#             out += self.return_value.string()
#         out += ";"
#         return out

#     def __str__(self):
#         return "ReturnStatement(Statement)"


# class ExpressionStatement(Statement):
#     def __init__(self, token=None, expression=None):
#         self.token = token
#         self.expression = expression

#     def token_literal(self):
#         return self.token.literal

#     def statement_node(self):
#         pass

#     def string(self):
#         if self.expression is not None:
#             return self.expression.string()

#         return ""

#     def __str__(self):
#         return "ExpressionStatement(Statement)"


# class IntegerLiteral(Expression):
#     def __init__(self, token=None, value=None):
#         self.token = token
#         self.value = value

#     def token_literal(self):
#         return self.token.literal

#     def expression_node(self):
#         pass

#     def string(self):
#         return self.token.literal

#     def __str__(self):
#         return "IntegerLiteral(Expression)"


# class PrefixExpression(Expression):
#     def __init__(self, token=None, operator="", right=None):
#         self.token = token
#         self.operator = operator
#         self.right = right

#     def token_literal(self):
#         return self.token.literal

#     def expression_node(self):
#         pass

#     def string(self):
#         out = "("
#         out += self.operator
#         out += self.right.string()
#         out += ")"
#         return out

#     def __str__(self):
#         return "PrefixExpression(Expression)"


# class InfixExpression(Expression):
#     def __init__(self, token=None, left=None, operator="", right=None):
#         self.token = token
#         self.left = left
#         self.operator = operator
#         self.right = right

#     def token_literal(self):
#         return self.token.literal

#     def expression_node(self):
#         pass

#     def string(self):
#         out = "("
#         out += self.left.string()
#         out += " "
#         out += self.operator
#         out += " "
#         out += self.right.string()
#         out += ")"
#         return out

#     def __str__(self):
#         return "InfixExpression(Expression)"


if __name__ == "__main__":
    pass
