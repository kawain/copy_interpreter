package token

type TokenType string

const (
	ILLEGAL   = "ILLEGAL"
	EOF       = "EOF"
	INT       = "INT"
	PLUS      = "+"
	MINUS     = "-"
	ASTERISK  = "*"
	SLASH     = "/"
	SEMICOLON = ";"
	LPAREN    = "("
	RPAREN    = ")"
)

type Token struct {
	Type    TokenType
	Literal string
}
