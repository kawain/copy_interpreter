from enum import Enum, auto


class TokenType(Enum):
    """字句の種類"""

    ILLEGAL = auto()
    IDENT = auto()  # add, foobar, x, y, ...
    INT = auto()   # 1343456
    FLOAT = auto()   # 3.14
    ASSIGN = auto()   # "="
    PLUS = auto()     # "+"
    MINUS = auto()    # "-"
    BANG = auto()     # "!"
    ASTERISK = auto()  # "*"
    SLASH = auto()    # "/"
    LT = auto()       # "<"
    GT = auto()       # ">"
    EQ = auto()       # "=="
    NOT_EQ = auto()   # "!="
    COMMA = auto()     # ","
    SEMICOLON = auto()  # ";"
    LPAREN = auto()    # "("
    RPAREN = auto()    # ")"
    LBRACE = auto()    # "{"
    RBRACE = auto()    # "}"
    FUNCTION = auto()  # "FUNCTION"
    LET = auto()      # "LET"
    TRUE = auto()     # "TRUE"
    FALSE = auto()    # "FALSE"
    IF = auto()       # "IF"
    ELSE = auto()     # "ELSE"
    RETURN = auto()   # "RETURN"
    EOF = auto()      # 入力の終わりを表すトークン

    STRING = auto()  # 文字列


class Token:
    """字句"""

    keywords = {
        "fn": TokenType.FUNCTION,
        "let": TokenType.LET,
        "true": TokenType.TRUE,
        "false": TokenType.FALSE,
        "if": TokenType.IF,
        "else": TokenType.ELSE,
        "return": TokenType.RETURN,
    }

    def __init__(self, token_type=None, literal=""):
        self.token_type = token_type
        self.literal = literal

    @staticmethod
    def lookup_ident(ident):
        v = Token.keywords.get(ident)
        if v is None:
            return TokenType.IDENT

        return v

    def __str__(self):
        return "Token()"
