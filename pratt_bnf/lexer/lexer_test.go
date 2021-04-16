package lexer

import (
	"fmt"
	"strings"
	"testing"

	"github.com/kawain/copy_interpreter/pratt_bnf/token"
)

func TestNextToken(t *testing.T) {
	input := `
1 + 2 + 3;
1 + 2 * 3;
1 - 2 / 3;
3 * (2 + 3);
`
	l := New(input)
	for {
		tok := l.NextToken()
		fmt.Printf("%#v\n", tok)
		fmt.Println(strings.Repeat("-", 30))
		if tok.Type == token.EOF {
			break
		}
	}
}
