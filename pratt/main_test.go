// go test -run TestString -v
package main

import (
	"fmt"
	"strings"
	"testing"
)

func checkParserErrors(t *testing.T, p *Parser) {
	errors := p.Errors()
	if len(errors) == 0 {
		return
	}

	t.Errorf("parser has %d errors", len(errors))
	for _, msg := range errors {
		t.Errorf("parser error: %q", msg)
	}
	t.FailNow()
}

func testIntegerLiteral(t *testing.T, il Expression, value int64) bool {
	integ, ok := il.(*IntegerLiteral)
	if !ok {
		t.Errorf("il not *ast.IntegerLiteral. got=%T", il)
		return false
	}

	if integ.Value != value {
		t.Errorf("integ.Value not %d. got=%d", value, integ.Value)
		return false
	}

	if integ.TokenLiteral() != fmt.Sprintf("%d", value) {
		t.Errorf("integ.TokenLiteral not %d. got=%s", value,
			integ.TokenLiteral())
		return false
	}

	return true
}
func TestNextToken(t *testing.T) {
	input := `
1 + 2 + 3;
1 + 2 * 3;
1 - 2 / 3;
`
	l := newLexer(input)
	for {
		tok := l.nextToken()
		fmt.Printf("%#v\n", tok)
		fmt.Println(strings.Repeat("-", 30))
		if tok.Type == EOF {
			break
		}
	}
}

func TestIntegerLiteralExpression(t *testing.T) {
	input := "5;"

	l := newLexer(input)
	p := newParser(l)
	program := p.ParseProgram()
	checkParserErrors(t, p)

	stmt, ok := program.Statements[0].(*ExpressionStatement)
	if !ok {
		t.Fatalf("program.Statements[0] is not ast.ExpressionStatement. got=%T",
			program.Statements[0])
	}

	literal, ok := stmt.Expression.(*IntegerLiteral)
	if !ok {
		t.Fatalf("exp not *ast.IntegerLiteral. got=%T", stmt.Expression)
	}
	if literal.Value != 5 {
		t.Errorf("literal.Value not %d. got=%d", 5, literal.Value)
	}
	if literal.TokenLiteral() != "5" {
		t.Errorf("literal.TokenLiteral not %s. got=%s", "5",
			literal.TokenLiteral())
	}
}

func TestString(t *testing.T) {
	program := &Program{
		Statements: []Statement{
			&ExpressionStatement{
				Token: MyToken{Type: INT, Literal: "5"},
				Expression: &IntegerLiteral{
					Token: MyToken{Type: INT, Literal: "5"},
					Value: 5,
				},
			},
		},
	}

	if program.String() != "5" {
		t.Errorf("program.String() wrong. got=%q", program.String())
	}
}

func TestParsingPrefixExpressions(t *testing.T) {
	prefixTests := []struct {
		input    string
		operator string
		value    int64
	}{
		{"-5;", "-", 5},
		{"-15;", "-", 15},
	}

	for _, tt := range prefixTests {
		l := newLexer(tt.input)
		p := newParser(l)
		program := p.ParseProgram()
		checkParserErrors(t, p)

		if len(program.Statements) != 1 {
			t.Fatalf("program.Statements does not contain %d statements. got=%d\n",
				1, len(program.Statements))
		}

		stmt, ok := program.Statements[0].(*ExpressionStatement)
		if !ok {
			t.Fatalf("program.Statements[0] is not ExpressionStatement. got=%T",
				program.Statements[0])
		}

		exp, ok := stmt.Expression.(*PrefixExpression)
		if !ok {
			t.Fatalf("stmt is not PrefixExpression. got=%T", stmt.Expression)
		}
		if exp.Operator != tt.operator {
			t.Fatalf("exp.Operator is not '%s'. got=%s",
				tt.operator, exp.Operator)
		}
		if !testIntegerLiteral(t, exp.Right, tt.value) {
			return
		}
	}
}

func TestParsingInfixExpressions(t *testing.T) {
	infixTests := []struct {
		input      string
		leftValue  int64
		operator   string
		rightValue int64
	}{
		{"5 + 5;", 5, "+", 5},
		{"5 - 5;", 5, "-", 5},
		{"5 * 5;", 5, "*", 5},
		{"5 / 5;", 5, "/", 5},
	}

	for _, tt := range infixTests {
		l := newLexer(tt.input)
		p := newParser(l)
		program := p.ParseProgram()
		checkParserErrors(t, p)

		if len(program.Statements) != 1 {
			t.Fatalf("program.Statements does not contain %d statements. got=%d\n",
				1, len(program.Statements))
		}

		stmt, ok := program.Statements[0].(*ExpressionStatement)
		if !ok {
			t.Fatalf("program.Statements[0] is not ExpressionStatement. got=%T",
				program.Statements[0])
		}

		exp, ok := stmt.Expression.(*InfixExpression)
		if !ok {
			t.Fatalf("stmt is not InfixExpression. got=%T", stmt.Expression)
		}

		if !testIntegerLiteral(t, exp.Left, tt.leftValue) {
			return
		}

		if exp.Operator != tt.operator {
			t.Fatalf("exp.Operator is not '%s'. got=%s",
				tt.operator, exp.Operator)
		}

		if !testIntegerLiteral(t, exp.Left, tt.rightValue) {
			return
		}
	}
}

func TestOperatorPrecedenceParsing(t *testing.T) {
	tests := []struct {
		input    string
		expected string
	}{
		// {
		// 	"1 + 2 - 3;",
		// 	"((1 + 2) - 3)",
		// },
		// {
		// 	"3 + 4 * 10;",
		// 	"(3 + (4 * 10))",
		// },
		// {
		// 	"3 + 4; -5 * 5",
		// 	"(3 + 4)((-5) * 5)",
		// },
		// {
		// 	"-5 + 5",
		// 	"((-5) + 5)",
		// },
		// {
		// 	"5 + 5 * -2",
		// 	"(5 + (5 * (-2)))",
		// },
		// {
		// 	"1+2+3+4+5+6+7+8+9",
		// 	"((((((((1 + 2) + 3) + 4) + 5) + 6) + 7) + 8) + 9)",
		// },
		// {
		// 	"1 + (2 + 3) + 4",
		// 	"((1 + (2 + 3)) + 4)",
		// },
		{
			"(5 + 5) * 2",
			"((5 + 5) * 2)",
		},
		{
			"2 / (5 + 5)",
			"(2 / (5 + 5))",
		},
		{
			"(5 + 5) * 2 * (5 + 5)",
			"(((5 + 5) * 2) * (5 + 5))",
		},
		{
			"-(5 + 5)",
			"(-(5 + 5))",
		},
		{
			"(-5 + 5)*100",
			"(((-5) + 5) * 100)",
		},
	}

	for _, tt := range tests {
		l := newLexer(tt.input)
		p := newParser(l)
		program := p.ParseProgram()
		checkParserErrors(t, p)

		actual := program.String()
		if actual != tt.expected {
			t.Errorf("expected=%q, got=%q", tt.expected, actual)
		}
	}
}
