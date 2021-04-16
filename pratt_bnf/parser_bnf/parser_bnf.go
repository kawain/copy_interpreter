package parser_bnf

import (
	"fmt"
	"strconv"

	"github.com/kawain/copy_interpreter/pratt_bnf/lexer"
	"github.com/kawain/copy_interpreter/pratt_bnf/token"
)

// トークンリスト
var TokenList []token.Token

// トークンリストのインデックス
var TokenListIndex int = 0

// 配列に入れる
func MakeTokenList(input string) {
	l := lexer.New(input)
	for {
		tok := l.NextToken()
		TokenList = append(TokenList, tok)
		if tok.Type == token.EOF {
			break
		}
	}
}

// 連結リスト
type NodeList struct {
	Kind  token.Token
	Left  *NodeList
	Right *NodeList
	Val   int64
}

// 左辺と右辺を受け取る2項演算子
func newNode(kind token.Token, left, right *NodeList) *NodeList {
	node := new(NodeList)
	node.Kind = kind
	node.Left = left
	node.Right = right
	return node
}

// 数値
func newNodeNum(kind token.Token) *NodeList {
	val, err := strconv.ParseInt(kind.Literal, 0, 64)
	if err != nil {
		msg := fmt.Sprintf("%v 数字ではありません", kind.Literal)
		panic(msg)
	}
	node := new(NodeList)
	node.Kind = kind
	node.Val = val
	return node
}

// 期待している記号かどうか
func consume(t token.TokenType) bool {
	if TokenList[TokenListIndex].Type == t {
		TokenListIndex++
		return true
	} else {
		return false
	}
}

// 期待している記号のときには、トークンを1つ読み進める
func expect(t token.TokenType) {
	if TokenList[TokenListIndex].Type != t {
		msg := fmt.Sprintf("%v ではありません", t)
		panic(msg)
	}
	TokenListIndex++
}

// 参考：https://www.sigbus.info/compilerbook
// expr    = mul ("+" mul | "-" mul)*
// mul     = primary ("*" primary | "/" primary)*
// primary = num | "(" expr ")"

func Expr() *NodeList {
	node := Mul()
	for {
		switch {
		case consume("+"):
			t := token.Token{Type: token.PLUS, Literal: token.PLUS}
			nnode := newNode(t, node, Mul())
			node = nnode
		case consume("-"):
			t := token.Token{Type: token.MINUS, Literal: token.MINUS}
			nnode := newNode(t, node, Mul())
			node = nnode
		default:
			return node
		}
	}
}

func Mul() *NodeList {
	node := Primary()
	for {
		switch {
		case consume("*"):
			t := token.Token{Type: token.ASTERISK, Literal: token.ASTERISK}
			nnode := newNode(t, node, Primary())
			node = nnode
		case consume("/"):
			t := token.Token{Type: token.SLASH, Literal: token.SLASH}
			nnode := newNode(t, node, Primary())
			node = nnode
		default:
			return node
		}
	}
}

func Primary() *NodeList {
	// 次のトークンが"("なら、"(" expr ")"のはず
	if consume("(") {
		node := Expr()
		expect(")")
		return node
	}
	// そうでなければ数値のはず
	node := newNodeNum(TokenList[TokenListIndex])
	TokenListIndex++
	return node
}

func (node *NodeList) Gen() {
	if node.Kind.Type == token.INT {
		fmt.Printf("  push %v\n", node.Val)
		return
	}

	node.Left.Gen()
	node.Right.Gen()

	switch node.Kind.Type {
	case token.PLUS:
		fmt.Printf("  +\n")
	case token.MINUS:
		fmt.Printf("  -\n")
	case token.ASTERISK:
		fmt.Printf("  *\n")
	case token.SLASH:
		fmt.Printf("  /\n")
	}

}
