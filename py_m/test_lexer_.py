# python -m unittest test_lexer_.TestLexer.test_next_token1
import unittest
import token_
import lexer_


class TestLexer(unittest.TestCase):

    def test_next_token1(self):
        line = """
let five = 5.2.36;
let ten = 10;

let add = fn(x, y) {
  x + y;
};

let result = add(five, ten);
!-/*5;
5 < 10.236 > 5;

if (5 < 10) {
  return true;
} else {
     return false;
}

10 == 10;
10 != .9;
"foobar"
"foo bar"

    """
        lex = lexer_.Lexer(input=line)
        while True:
            tok = lex.next_token()

            print(tok.token_type)
            print(tok.literal)
            print("-----")

            if tok.token_type == token_.TokenType.EOF:
                break

    def test_next_token2(self):
        input = """let five = 5;
let ten = 10;

let add = fn(x, y) {
  x + y;
};

let result = add(five, ten);
!-/*5;
5 < 10 > 5;

if (5 < 10) {
    return true;
} else {
    return false;
}

10 == 10;
10 != 9;

"foobar"
"foo bar"
"日本語"

        """

        tests = [
            (token_.TokenType.LET, "let"),
            (token_.TokenType.IDENT, "five"),
            (token_.TokenType.ASSIGN, "="),
            (token_.TokenType.INT, "5"),
            (token_.TokenType.SEMICOLON, ";"),
            (token_.TokenType.LET, "let"),
            (token_.TokenType.IDENT, "ten"),
            (token_.TokenType.ASSIGN, "="),
            (token_.TokenType.INT, "10"),
            (token_.TokenType.SEMICOLON, ";"),
            (token_.TokenType.LET, "let"),
            (token_.TokenType.IDENT, "add"),
            (token_.TokenType.ASSIGN, "="),
            (token_.TokenType.FUNCTION, "fn"),
            (token_.TokenType.LPAREN, "("),
            (token_.TokenType.IDENT, "x"),
            (token_.TokenType.COMMA, ","),
            (token_.TokenType.IDENT, "y"),
            (token_.TokenType.RPAREN, ")"),
            (token_.TokenType.LBRACE, "{"),
            (token_.TokenType.IDENT, "x"),
            (token_.TokenType.PLUS, "+"),
            (token_.TokenType.IDENT, "y"),
            (token_.TokenType.SEMICOLON, ";"),
            (token_.TokenType.RBRACE, "}"),
            (token_.TokenType.SEMICOLON, ";"),
            (token_.TokenType.LET, "let"),
            (token_.TokenType.IDENT, "result"),
            (token_.TokenType.ASSIGN, "="),
            (token_.TokenType.IDENT, "add"),
            (token_.TokenType.LPAREN, "("),
            (token_.TokenType.IDENT, "five"),
            (token_.TokenType.COMMA, ","),
            (token_.TokenType.IDENT, "ten"),
            (token_.TokenType.RPAREN, ")"),
            (token_.TokenType.SEMICOLON, ";"),
            (token_.TokenType.BANG, "!"),
            (token_.TokenType.MINUS, "-"),
            (token_.TokenType.SLASH, "/"),
            (token_.TokenType.ASTERISK, "*"),
            (token_.TokenType.INT, "5"),
            (token_.TokenType.SEMICOLON, ";"),
            (token_.TokenType.INT, "5"),
            (token_.TokenType.LT, "<"),
            (token_.TokenType.INT, "10"),
            (token_.TokenType.GT, ">"),
            (token_.TokenType.INT, "5"),
            (token_.TokenType.SEMICOLON, ";"),
            (token_.TokenType.IF, "if"),
            (token_.TokenType.LPAREN, "("),
            (token_.TokenType.INT, "5"),
            (token_.TokenType.LT, "<"),
            (token_.TokenType.INT, "10"),
            (token_.TokenType.RPAREN, ")"),
            (token_.TokenType.LBRACE, "{"),
            (token_.TokenType.RETURN, "return"),
            (token_.TokenType.TRUE, "true"),
            (token_.TokenType.SEMICOLON, ";"),
            (token_.TokenType.RBRACE, "}"),
            (token_.TokenType.ELSE, "else"),
            (token_.TokenType.LBRACE, "{"),
            (token_.TokenType.RETURN, "return"),
            (token_.TokenType.FALSE, "false"),
            (token_.TokenType.SEMICOLON, ";"),
            (token_.TokenType.RBRACE, "}"),
            (token_.TokenType.INT, "10"),
            (token_.TokenType.EQ, "=="),
            (token_.TokenType.INT, "10"),
            (token_.TokenType.SEMICOLON, ";"),
            (token_.TokenType.INT, "10"),
            (token_.TokenType.NOT_EQ, "!="),
            (token_.TokenType.INT, "9"),
            (token_.TokenType.SEMICOLON, ";"),
            (token_.TokenType.STRING, "foobar"),
            (token_.TokenType.STRING, "foo bar"),
            (token_.TokenType.STRING, "日本語"),
            (token_.TokenType.EOF, ""),
        ]

        lex = lexer_.Lexer(input)

        for v in tests:
            tok = lex.next_token()
            assert tok.token_type == v[0],\
                f"tokentype wrong. expected={tok.token_type}, got={v[0]}"
            assert tok.literal == v[1],\
                f"tokentype wrong. expected={tok.literal}, got={v[1]}"


if __name__ == '__main__':
    unittest.main()
