package lexer

import (
	"fmt"
	"testing"

	"github.com/kawain/copy_interpreter/go_m/token"
)

func TestNextToken(t *testing.T) {
	input := `let five = 5.2.36;
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
10 != .9;
`

	// input = `3.14  + 20 *  .0`

	l := New(input)

	for {
		tok := l.NextToken()
		fmt.Printf("%+v\n", tok)
		if tok.Type == token.EOF {
			break
		}
	}

}
