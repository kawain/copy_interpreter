from token_ import TokenType, Token


class Lexer:
    """字句解析"""

    def __init__(self, input, position=0, next_position=0, ch=""):
        self.input = input
        self.position = position
        self.next_position = next_position
        self.ch = ch
        self.size = len(self.input)

        self.read_char()

    def read_char(self):
        if self.next_position >= self.size:
            self.ch = ""
        else:
            self.ch = self.input[self.next_position]

        self.position = self.next_position
        self.next_position += 1

    def skip_whitespace(self):
        while self.ch == " " or self.ch == "\t" or self.ch == "\n" or self.ch == "\r":
            self.read_char()

    @staticmethod
    def is_letter(v):
        if v.isalpha():
            return True
        elif v == "_":
            return True
        else:
            return False

    @staticmethod
    def is_digit(v):
        if v.isdigit():
            return True
        elif v == '.':
            return True
        else:
            return False

    def peek_char(self):
        if self.next_position >= self.size:
            return ""
        else:
            return self.input[self.next_position]

    def read_identifier(self):
        position = self.position
        while self.is_letter(self.ch):
            self.read_char()
        return self.input[position:self.position]

    def read_number(self):
        position = self.position
        while self.is_digit(self.ch):
            self.read_char()

        return self.input[position:self.position]

    def read_string(self):
        position = self.position + 1
        while True:
            self.read_char()
            if self.ch == '"' or self.ch == "":
                break
        return self.input[position:self.position]

    def next_token(self):
        tok = Token()

        self.skip_whitespace()

        if self.ch == "=":
            if self.peek_char() == "=":
                self.read_char()
                tok.token_type = TokenType.EQ
                tok.literal = "=="
            else:
                tok.token_type = TokenType.ASSIGN
                tok.literal = "="
        elif self.ch == "+":
            tok.token_type = TokenType.PLUS
            tok.literal = self.ch
        elif self.ch == "-":
            tok.token_type = TokenType.MINUS
            tok.literal = self.ch
        elif self.ch == "!":
            if self.peek_char() == "=":
                self.read_char()
                tok.token_type = TokenType.NOT_EQ
                tok.literal = "!="
            else:
                tok.token_type = TokenType.BANG
                tok.literal = "!"
        elif self.ch == "/":
            tok.token_type = TokenType.SLASH
            tok.literal = self.ch
        elif self.ch == "*":
            tok.token_type = TokenType.ASTERISK
            tok.literal = self.ch
        elif self.ch == "<":
            tok.token_type = TokenType.LT
            tok.literal = self.ch
        elif self.ch == ">":
            tok.token_type = TokenType.GT
            tok.literal = self.ch
        elif self.ch == ";":
            tok.token_type = TokenType.SEMICOLON
            tok.literal = self.ch
        elif self.ch == ",":
            tok.token_type = TokenType.COMMA
            tok.literal = self.ch
        elif self.ch == "{":
            tok.token_type = TokenType.LBRACE
            tok.literal = self.ch
        elif self.ch == "}":
            tok.token_type = TokenType.RBRACE
            tok.literal = self.ch
        elif self.ch == "(":
            tok.token_type = TokenType.LPAREN
            tok.literal = self.ch
        elif self.ch == ")":
            tok.token_type = TokenType.RPAREN
            tok.literal = self.ch
        elif self.ch == '"':
            tok.token_type = TokenType.STRING
            tok.literal = self.read_string()
        elif self.ch == "[":
            tok.token_type = TokenType.LBRACKET
            tok.literal = self.ch
        elif self.ch == "]":
            tok.token_type = TokenType.RBRACKET
            tok.literal = self.ch
        elif self.ch == "":
            tok.token_type = TokenType.EOF
            tok.literal = ""
        else:
            if self.is_letter(self.ch):
                tok.literal = self.read_identifier()
                tok.token_type = tok.lookup_ident(tok.literal)
                return tok
            elif self.is_digit(self.ch):
                literal = self.read_number()
                if literal.count(".") == 0:
                    tok.token_type = TokenType.INT
                    tok.literal = literal
                    return tok
                elif literal.count(".") == 1:
                    tok.token_type = TokenType.FLOAT
                    tok.literal = literal
                    return tok
                else:
                    tok.token_type = TokenType.ILLEGAL
                    tok.literal = literal
            else:
                tok.token_type = TokenType.ILLEGAL
                tok.literal = self.ch

        self.read_char()
        return tok

    def __str__(self):
        return "Lexer()"


if __name__ == "__main__":
    pass
