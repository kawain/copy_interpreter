package parser

import (
	"fmt"
	_ "strconv"

	"github.com/kawain/copy_interpreter/go_m/ast"
	"github.com/kawain/copy_interpreter/go_m/lexer"
	"github.com/kawain/copy_interpreter/go_m/token"
)

const (
	_ int = iota
	LOWEST
	EQUALS      // ==
	LESSGREATER // > or <
	SUM         // +
	PRODUCT     // *
	PREFIX      // -X or !X
	CALL        // myFunction(X)
)

type (
	prefixParseFn func() ast.Expression
	infixParseFn  func(ast.Expression) ast.Expression
)

type Parser struct {
	l      *lexer.Lexer
	errors []string

	curToken  token.Token
	peekToken token.Token

	prefixParseFns map[string]prefixParseFn
	infixParseFns  map[string]infixParseFn
}

func New(l *lexer.Lexer) *Parser {
	p := &Parser{
		l:      l,
		errors: []string{},
	}

	p.prefixParseFns = make(map[string]prefixParseFn)
	p.registerPrefix(token.IDENT, p.parseIdentifier)
	// p.registerPrefix(token.INT, p.parseIntegerLiteral)
	// p.registerPrefix(token.BANG, p.parsePrefixExpression)
	// p.registerPrefix(token.MINUS, p.parsePrefixExpression)
	// p.registerPrefix(token.TRUE, p.parseBoolean)
	// p.registerPrefix(token.FALSE, p.parseBoolean)
	// p.registerPrefix(token.LPAREN, p.parseGroupedExpression)
	// p.registerPrefix(token.IF, p.parseIfExpression)
	// p.registerPrefix(token.FUNCTION, p.parseFunctionLiteral)

	// p.infixParseFns = make(map[string]infixParseFn)
	// p.registerInfix(token.PLUS, p.parseInfixExpression)
	// p.registerInfix(token.MINUS, p.parseInfixExpression)
	// p.registerInfix(token.SLASH, p.parseInfixExpression)
	// p.registerInfix(token.ASTERISK, p.parseInfixExpression)
	// p.registerInfix(token.EQ, p.parseInfixExpression)
	// p.registerInfix(token.NOT_EQ, p.parseInfixExpression)
	// p.registerInfix(token.LT, p.parseInfixExpression)
	// p.registerInfix(token.GT, p.parseInfixExpression)

	// p.registerInfix(token.LPAREN, p.parseCallExpression)

	// Read two tokens, so curToken and peekToken are both set
	p.nextToken()
	p.nextToken()

	return p
}

func (p *Parser) nextToken() {
	p.curToken = p.peekToken
	p.peekToken = p.l.NextToken()
}

func (p *Parser) ParseProgram() *ast.Program {
	program := &ast.Program{}
	program.Statements = []ast.Statement{}

	for !p.curTokenIs(token.EOF) {
		stmt := p.parseStatement()
		if stmt != nil {
			program.Statements = append(program.Statements, stmt)
		}
		p.nextToken()
	}

	return program
}

func (p *Parser) parseStatement() ast.Statement {
	switch p.curToken.Type {
	case token.LET:
		return p.parseLetStatement()
	case token.RETURN:
		return p.parseReturnStatement()
	default:
		return p.parseExpressionStatement()
	}
}

func (p *Parser) parseLetStatement() *ast.LetStatement {
	stmt := &ast.LetStatement{Token: p.curToken}

	if !p.expectPeek(token.IDENT) {
		return nil
	}

	stmt.Name = &ast.Identifier{Token: p.curToken, Value: p.curToken.Literal}

	if !p.expectPeek(token.ASSIGN) {
		return nil
	}

	// p.nextToken()

	// stmt.Value = p.parseExpression(LOWEST)

	if p.peekTokenIs(token.SEMICOLON) {
		p.nextToken()
	}

	return stmt
}

func (p *Parser) curTokenIs(t string) bool {
	return p.curToken.Type == t
}

func (p *Parser) peekTokenIs(t string) bool {
	return p.peekToken.Type == t
}

func (p *Parser) expectPeek(t string) bool {
	if p.peekTokenIs(t) {
		p.nextToken()
		return true
	} else {
		p.peekError(t)
		return false
	}
}

func (p *Parser) Errors() []string {
	return p.errors
}

func (p *Parser) peekError(t string) {
	msg := fmt.Sprintf("次のトークンは %s であるべきですが %s でした", t, p.peekToken.Type)
	p.errors = append(p.errors, msg)
}

func (p *Parser) parseReturnStatement() *ast.ReturnStatement {
	stmt := &ast.ReturnStatement{Token: p.curToken}

	p.nextToken()

	// stmt.ReturnValue = p.parseExpression(LOWEST)

	if p.peekTokenIs(token.SEMICOLON) {
		p.nextToken()
	}

	return stmt
}

func (p *Parser) registerPrefix(tokenType string, fn prefixParseFn) {
	p.prefixParseFns[tokenType] = fn
}

func (p *Parser) registerInfix(tokenType string, fn infixParseFn) {
	p.infixParseFns[tokenType] = fn
}

func (p *Parser) parseExpressionStatement() *ast.ExpressionStatement {
	stmt := &ast.ExpressionStatement{Token: p.curToken}

	stmt.Expression = p.parseExpression(LOWEST)

	if p.peekTokenIs(token.SEMICOLON) {
		p.nextToken()
	}

	return stmt
}

func (p *Parser) parseExpression(precedence int) ast.Expression {
	prefix := p.prefixParseFns[p.curToken.Type]
	if prefix == nil {
		// p.noPrefixParseFnError(p.curToken.Type)
		return nil
	}
	leftExp := prefix()

	// for !p.peekTokenIs(token.SEMICOLON) && precedence < p.peekPrecedence() {
	// 	infix := p.infixParseFns[p.peekToken.Type]
	// 	if infix == nil {
	// 		return leftExp
	// 	}

	// 	p.nextToken()

	// 	leftExp = infix(leftExp)
	// }

	return leftExp
}

func (p *Parser) parseIdentifier() ast.Expression {
	return &ast.Identifier{Token: p.curToken, Value: p.curToken.Literal}
}
