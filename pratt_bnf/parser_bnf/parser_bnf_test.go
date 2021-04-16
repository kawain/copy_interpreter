package parser_bnf

import (
	"fmt"
	"strings"
	"testing"
)

func TestMakeTokenList(t *testing.T) {
	input := `
1 + 2 + 3;
1 + 2 * 3;
1 - 2 / 3;
3 * (2 + 3);
`
	MakeTokenList(input)
	for i, v := range TokenList {
		fmt.Printf("%#v\n", i)
		fmt.Printf("%#v\n", v)
		fmt.Println(strings.Repeat("-", 30))
	}
}

func TestAST(t *testing.T) {
	input := `1*2+15/3+2`
	MakeTokenList(input)
	node := Expr()
	node.Gen()
}
