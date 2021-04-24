import sys

# トークンの種類
INT = "INT"
FLOAT = "FLOAT"
ASSIGN = "="
PLUS = "+"
MINUS = "-"
ASTERISK = "*"
SLASH = "/"
SEMICOLON = ";"
LPAREN = "("
RPAREN = ")"
# その他
ILLEGAL = "ILLEGAL"
# 入力の終わりを表すトークン
EOF = "EOF"


class Token:
    """トークン"""

    def __init__(self):
        self.type = ""
        self.literal = ""


class Lexer:
    """字句解析"""

    def __init__(self, input):
        self.input = input
        self.position = 0
        self.next_position = 0
        self.ch = ""
        self.length = len(input)

        self.read_char()

    def read_char(self):
        if self.next_position >= self.length:
            self.ch = ""
        else:
            self.ch = self.input[self.next_position]

        self.position = self.next_position
        self.next_position += 1

    def skip_whitespace(self):
        while self.ch == " " or self.ch == "\t" or self.ch == "\n" or self.ch == "\r":
            self.read_char()

    def is_digit(self):
        if self.ch.isdigit():
            return True
        elif self.ch == '.':
            return True
        else:
            return False

    def peek_char(self):
        if self.next_position >= len(self.input):
            return ""
        else:
            return self.input[self.next_position]

    def read_number(self):
        position = self.position
        while self.is_digit():
            self.read_char()

        return self.input[position:self.position]

    def next_token(self):
        tok = Token()

        self.skip_whitespace()

        if self.ch == "=":
            tok.type = ASSIGN
        elif self.ch == "+":
            tok.type = PLUS
        elif self.ch == "-":
            tok.type = MINUS
        elif self.ch == "*":
            tok.type = ASTERISK
        elif self.ch == "/":
            tok.type = SLASH
        elif self.ch == ";":
            tok.type = SEMICOLON
        elif self.ch == "(":
            tok.type = LPAREN
        elif self.ch == ")":
            tok.type = RPAREN
        elif self.ch == "":
            tok.type = EOF
        else:
            if self.is_digit():
                literal = self.read_number()
                if literal.count(".") == 0:
                    tok.type = INT
                    tok.literal = literal
                    return tok
                elif literal.count(".") == 1:
                    tok.type = FLOAT
                    tok.literal = literal
                    return tok
                else:
                    tok.type = ILLEGAL
                    tok.literal = literal
            else:
                tok.type = ILLEGAL
                tok.literal = self.ch

        self.read_char()
        return tok


class Node:
    """抽象構文木"""

    def __init__(self):
        self.kind = ""
        self.left = None
        self.right = None
        self.val = None


class Parser:
    """トークン配列クラス"""

    def __init__(self, tokens=[]):
        self.tokens = tokens
        self.position = 0
        self.next_position = 0
        self.obj = None
        self.length = len(tokens)

        self.read_pos()

    def read_pos(self):
        if self.next_position >= self.length:
            self.obj = None
        else:
            self.obj = self.tokens[self.next_position]
        self.position = self.next_position
        self.next_position += 1

    @staticmethod
    def new_node(kind, left, right):
        node = Node()
        node.kind = kind
        node.left = left
        node.right = right
        return node

    @staticmethod
    def new_node_num(kind, val):
        node = Node()
        node.kind = kind
        node.val = val
        return node

    # 期待している記号かどうか
    def consume(self, t):
        if self.obj.type == t:
            self.read_pos()
            return True
        else:
            return False

    # 期待している記号のときには、トークンを1つ読み進める
    def expect(self, t):
        if self.obj.type != t:
            sys.exit(f"{t} ではありません")
        self.read_pos()

    # 次のトークンが数値の場合、トークンを1つ読み進めてその数値を返す。
    # それ以外の場合にはエラーを報告する。
    def expect_number(self):
        if self.obj.type == INT:
            kind = INT
            val = int(self.obj.literal)
        elif self.obj.type == FLOAT:
            kind = FLOAT
            val = float(self.obj.literal)
        else:
            sys.exit("数ではありません")
        self.read_pos()
        return kind, val

    # expr    = mul ("+" mul | "-" mul)*
    # mul     = primary ("*" primary | "/" primary)*
    # primary = num | "(" expr ")"

    # 単項演算子
    # expr    = mul ("+" mul | "-" mul)*
    # mul     = unary ("*" unary | "/" unary)*
    # unary   = ("+" | "-")? primary
    # primary = num | "(" expr ")"

    def expr(self):
        node = self.mul()
        while True:
            if self.consume("+"):
                node = self.new_node(PLUS, node, self.mul())
            elif self.consume("-"):
                node = self.new_node(MINUS, node, self.mul())
            else:
                return node

    def mul(self):
        node = self.unary()
        while True:
            if self.consume("*"):
                node = self.new_node(ASTERISK, node, self.unary())
            elif self.consume("/"):
                node = self.new_node(SLASH, node, self.unary())
            else:
                return node

    def unary(self):
        if self.consume("+"):
            return self.primary()
        if self.consume("-"):
            return self.new_node(MINUS, self.new_node_num(INT, 0), self.primary())
        return self.primary()

    def primary(self):
        # 次のトークンが"("なら、"(" expr ")"のはず
        if self.consume("("):
            node = self.expr()
            self.expect(")")
            return node
        # そうでなければ数値のはず
        kind, val = self.expect_number()
        return self.new_node_num(kind, val)


def new_parser(input):
    # トークン配列
    tokens = []
    lex = Lexer(input)
    while True:
        tok = lex.next_token()
        tokens.append(tok)
        if tok.type == EOF:
            break

    return Parser(tokens)


def eval_infix(operator, left, right):
    if operator == "+":
        return left + right
    elif operator == "-":
        return left - right
    elif operator == "*":
        return left * right
    elif operator == "/":
        return left / right
    else:
        return None


def eval(node):
    if node.kind == INT:
        return node.val
    elif node.kind == FLOAT:
        return node.val
    elif node.kind == PLUS or node.kind == MINUS or node.kind == ASTERISK or node.kind == SLASH:
        left = eval(node.left)
        right = eval(node.right)
        return eval_infix(node.kind, left, right)

    return None


if __name__ == "__main__":
    input = """1 * 2 + 3 * 4"""
    input = """3.14 * 2"""

    p = new_parser(input)
    node = p.expr()
    evaluated = eval(node)
    print(evaluated)
