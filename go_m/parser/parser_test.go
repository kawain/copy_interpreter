// go test -run TestReturnStatements ./parser -v
package parser

import (
	"fmt"
	"testing"

	"github.com/kawain/copy_interpreter/go_m/lexer"
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

func TestReturnStatements(t *testing.T) {
	input := `
return 5;
return 10;
return 99332;
	`

	l := lexer.New(input)
	p := New(l)

	program := p.ParseProgram()
	checkParserErrors(t, p)

	for i := range program.Statements {
		fmt.Printf("%+v\n", program.Statements[i])
	}
}

func TestLetStatements(t *testing.T) {
	input := `
let x = 5;
let ssss = 10;
let foobar = 838383;
	`

	l := lexer.New(input)
	p := New(l)

	program := p.ParseProgram()
	checkParserErrors(t, p)

	for i := range program.Statements {
		fmt.Printf("%+v\n", program.Statements[i])
	}
}
