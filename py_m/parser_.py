from token_ import TokenType
import ast_


priority = {
    "LOWEST": 1,
    "EQUALS": 2,  # ==
    "LESSGREATER": 3,  # > or <
    "SUM": 4,  # +
    "PRODUCT": 5,  # *
    "PREFIX": 6,  # -X or !X
    "CALL": 7,  # myFunction(X)
}


class Parser:
    precedences = {
        TokenType.EQ: priority["EQUALS"],
        TokenType.NOT_EQ: priority["EQUALS"],
        TokenType.LT: priority["LESSGREATER"],
        TokenType.GT: priority["LESSGREATER"],
        TokenType.PLUS: priority["SUM"],
        TokenType.MINUS: priority["SUM"],
        TokenType.SLASH: priority["PRODUCT"],
        TokenType.ASTERISK: priority["PRODUCT"],
        TokenType.LPAREN: priority["CALL"],
    }

    def __init__(self, lex):
        self.lex = lex
        self.errors = []
        self.cur_token = None
        self.peek_token = None
        # 前置構文解析関数
        self.prefix_parse_fns = {}
        # 中置構文解析関数
        self.infix_parse_fns = {}

        # 前置構文解析関数追加
        self.prefix_parse_fns[TokenType.IDENT] = self.parse_identifier
        self.prefix_parse_fns[TokenType.INT] = self.parse_integerLiteral_literal
        self.prefix_parse_fns[TokenType.FLOAT] = self.parse_floatLiteral_literal
        self.prefix_parse_fns[TokenType.BANG] = self.parse_prefix_expression
        self.prefix_parse_fns[TokenType.MINUS] = self.parse_prefix_expression
        self.prefix_parse_fns[TokenType.TRUE] = self.parse_boolean
        self.prefix_parse_fns[TokenType.FALSE] = self.parse_boolean
        self.prefix_parse_fns[TokenType.LPAREN] = self.parse_grouped_expression
        self.prefix_parse_fns[TokenType.IF] = self.parse_if_expression
        self.prefix_parse_fns[TokenType.FUNCTION] = self.parse_function_literal
        self.prefix_parse_fns[TokenType.STRING] = self.parse_string_literal
        self.prefix_parse_fns[TokenType.LBRACKET] = self.parse_array_literal
        # 中置構文解析関数追加
        self.infix_parse_fns[TokenType.PLUS] = self.parse_infix_expression
        self.infix_parse_fns[TokenType.MINUS] = self.parse_infix_expression
        self.infix_parse_fns[TokenType.SLASH] = self.parse_infix_expression
        self.infix_parse_fns[TokenType.ASTERISK] = self.parse_infix_expression
        self.infix_parse_fns[TokenType.EQ] = self.parse_infix_expression
        self.infix_parse_fns[TokenType.NOT_EQ] = self.parse_infix_expression
        self.infix_parse_fns[TokenType.LT] = self.parse_infix_expression
        self.infix_parse_fns[TokenType.GT] = self.parse_infix_expression
        self.infix_parse_fns[TokenType.LPAREN] = self.parse_call_expression

        self.next_token()
        self.next_token()

    def next_token(self):
        self.cur_token = self.peek_token
        self.peek_token = self.lex.next_token()

    def parse_program(self):
        program = ast_.Program()
        while self.cur_token.token_type != TokenType.EOF:
            stmt = self.parse_statement()
            if stmt is not None:
                program.statements.append(stmt)
            self.next_token()
        return program

    def parse_statement(self):
        if self.cur_token.token_type == TokenType.LET:
            return self.parse_let_statement()
        elif self.cur_token.token_type == TokenType.RETURN:
            return self.parse_return_statement()
        else:
            return self.parse_expression_statement()

    def parse_let_statement(self):
        stmt = ast_.LetStatement(token=self.cur_token)

        if not self.expect_peek(TokenType.IDENT):
            return None

        stmt.name = ast_.Identifier(
            token=self.cur_token, value=self.cur_token.literal
        )

        if not self.expect_peek(TokenType.ASSIGN):
            return None

        self.next_token()

        stmt.value = self.parse_expression(priority["LOWEST"])

        if self.peek_token_is(TokenType.SEMICOLON):
            # セミコロンまで読み飛ばし
            self.next_token()

        return stmt

    def parse_return_statement(self):
        stmt = ast_.ReturnStatement(token=self.cur_token)

        self.next_token()

        stmt.return_value = self.parse_expression(priority["LOWEST"])

        if self.peek_token_is(TokenType.SEMICOLON):
            self.next_token()

        return stmt

    def expect_peek(self, t):
        if self.peek_token_is(t):
            self.next_token()
            return True
        else:
            self.peek_error(t)
            return False

    def cur_token_is(self, t):
        return self.cur_token.token_type == t

    def peek_token_is(self, t):
        return self.peek_token.token_type == t

    def peek_error(self, t):
        msg = f"期待 {t}、現実 {self.peek_token.token_type}"
        self.errors.append(msg)

    def parse_expression_statement(self):
        stmt = ast_.ExpressionStatement(token=self.cur_token)

        stmt.expression = self.parse_expression(priority["LOWEST"])

        if self.peek_token_is(TokenType.SEMICOLON):
            self.next_token()

        return stmt

    def parse_expression(self, precedence):
        prefix = self.prefix_parse_fns.get(self.cur_token.token_type)
        if prefix is None:
            self.no_prefix_parse_fn_error(self.cur_token.token_type)
            return None

        left_exp = prefix()

        while not self.peek_token_is(TokenType.SEMICOLON) and (precedence < self.peek_precedence()):
            infix = self.infix_parse_fns.get(self.peek_token.token_type)
            if infix is None:
                return left_exp

            self.next_token()
            left_exp = infix(left_exp)

        return left_exp

    def parse_identifier(self):
        return ast_.Identifier(token=self.cur_token, value=self.cur_token.literal)

    def parse_integerLiteral_literal(self):
        obj = ast_.IntegerLiteral(token=self.cur_token)
        try:
            obj.value = int(self.cur_token.literal)
        except Exception as e:
            self.errors.append(f"{self.cur_token.literal}がintに変換できません {e}")
            return None

        return obj

    def parse_floatLiteral_literal(self):
        obj = ast_.FloatLiteral(token=self.cur_token)
        try:
            obj.value = float(self.cur_token.literal)
        except Exception as e:
            self.errors.append(f"{self.cur_token.literal}がfloatに変換できません {e}")
            return None

        return obj

    def no_prefix_parse_fn_error(self, t):
        msg = f"no prefix parse function for {t} found"
        self.errors.append(msg)

    def parse_prefix_expression(self):
        expression = ast_.PrefixExpression(
            token=self.cur_token,
            operator=self.cur_token.literal
        )
        self.next_token()
        expression.right = self.parse_expression(priority["PREFIX"])
        return expression

    def peek_precedence(self):
        p = Parser.precedences.get(self.peek_token.token_type)
        if p:
            return p
        return priority["LOWEST"]

    def cur_precedence(self):
        p = Parser.precedences.get(self.cur_token.token_type)
        if p:
            return p
        return priority["LOWEST"]

    def parse_infix_expression(self, left):
        expression = ast_.InfixExpression(
            token=self.cur_token,
            operator=self.cur_token.literal,
            left=left
        )
        precedence = self.cur_precedence()
        self.next_token()
        expression.right = self.parse_expression(precedence)
        return expression

    def parse_boolean(self):
        return ast_.Boolean(
            token=self.cur_token,
            value=self.cur_token_is(TokenType.TRUE)
        )

    def parse_grouped_expression(self):
        self.next_token()
        exp = self.parse_expression(priority["LOWEST"])
        if not self.expect_peek(TokenType.RPAREN):
            return None
        return exp

    def parse_if_expression(self):
        expression = ast_.IfExpression(token=self.cur_token)

        if not self.expect_peek(TokenType.LPAREN):
            return None

        self.next_token()
        expression.condition = self.parse_expression(priority["LOWEST"])

        if not self.expect_peek(TokenType.RPAREN):
            return None

        if not self.expect_peek(TokenType.LBRACE):
            return None

        expression.consequence = self.parse_block_statement()

        if self.peek_token_is(TokenType.ELSE):
            self.next_token()

            if not self.expect_peek(TokenType.LBRACE):
                return None

            expression.alternative = self.parse_block_statement()

        return expression

    def parse_block_statement(self):
        block = ast_.BlockStatement(token=self.cur_token)
        self.next_token()
        while not self.cur_token_is(TokenType.RBRACE) and not self.cur_token_is(TokenType.EOF):
            stmt = self.parse_statement()
            if stmt is not None:
                block.statements.append(stmt)
            self.next_token()
        return block

    def Errors(self):
        return self.errors

    def __str__(self):
        return "Parser()"

    def parse_function_literal(self):
        lit = ast_.FunctionLiteral(token=self.cur_token)

        if not self.expect_peek(TokenType.LPAREN):
            return None

        lit.parameters = self.parse_function_parameters()

        if not self.expect_peek(TokenType.LBRACE):
            return None

        lit.body = self.parse_block_statement()

        return lit

    def parse_function_parameters(self):
        identifiers = []

        if self.peek_token_is(TokenType.RPAREN):
            self.next_token()
            return identifiers

        self.next_token()

        ident = ast_.Identifier(token=self.cur_token,
                                value=self.cur_token.literal)
        identifiers.append(ident)

        while self.peek_token_is(TokenType.COMMA):
            self.next_token()
            self.next_token()

            ident = ast_.Identifier(
                token=self.cur_token,
                value=self.cur_token.literal)
            identifiers.append(ident)

        if not self.expect_peek(TokenType.RPAREN):
            return None

        return identifiers

    def parse_call_expression(self, function):
        exp = ast_.CallExpression(token=self.cur_token, function=function)
        exp.arguments = self.parse_expression_list(TokenType.RPAREN)
        return exp

    def parse_call_arguments(self):
        args = []

        if self.peek_token_is(TokenType.RPAREN):
            self.next_token()
            return args

        self.next_token()
        args.append(self.parse_expression(priority["LOWEST"]))

        while self.peek_token_is(TokenType.COMMA):
            self.next_token()
            self.next_token()
            args.append(self.parse_expression(priority["LOWEST"]))

        if not self.expect_peek(TokenType.RPAREN):
            return None

        return args

    def parse_string_literal(self):
        return ast_.StringLiteral(self.cur_token, self.cur_token.literal)

    def parse_array_literal(self) -> ast_.Expression:
        array = ast_.ArrayLiteral(self.cur_token, [])
        array.elements = self.parse_expression_list(TokenType.RBRACKET)
        return array

    def parse_expression_list(self, end: TokenType) -> list[ast_.Expression]:
        args: list[ast_.Expression] = []

        if self.peek_token_is(end):
            self.next_token()
            return args

        self.next_token()
        args.append(self.parse_expression(priority["LOWEST"]))

        while self.peek_token_is(TokenType.COMMA):
            self.next_token()
            self.next_token()
            args.append(self.parse_expression(priority["LOWEST"]))

        if not self.expect_peek(end):
            return None

        return args


if __name__ == "__main__":
    pass
