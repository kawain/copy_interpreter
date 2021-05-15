import tables

type
  TokenType* = enum
    ILLEGAL   # "ILLEGAL"
    EOF       # "EOF"
    IDENT     # "IDENT" // add, foobar, x, y, ...
    INT       # "INT"   // 1343456
    FLOAT     # "FLOAT" // 3.14
    ASSIGN    # "="
    PLUS      # "+"
    MINUS     # "-"
    BANG      # "!"
    ASTERISK  # "*"
    SLASH     # "/"
    LT        # "<"
    GT        # ">"
    EQ        # "=="
    NOT_EQ    # "!="
    COMMA     # ","
    SEMICOLON # ";"
    LPAREN    # "("
    RPAREN    # ")"
    LBRACE    # "{"
    RBRACE    # "}"
    FUNCTION  # "FUNCTION"
    LET       # "LET"
    TRUE      # "TRUE"
    FALSE     # "FALSE"
    IF        # "IF"
    ELSE      # "ELSE"
    RETURN    # "RETURN"
    STRING    # "foobar"

  Token* = ref object
    tokenType*: TokenType
    literal*: string

let keywords = {
  "fn": FUNCTION,
  "let": LET,
  "true": TRUE,
  "false": FALSE,
  "if": IF,
  "else": ELSE,
  "return": RETURN,
}.toTable

proc lookupIdent*(ident: string): TokenType =
  if keywords.hasKey(ident):
    return keywords[ident]
  IDENT

when isMainModule:
  var a = Token(tokenType: ELSE)
  echo a[]
  echo keywords["fn"]
  echo lookupIdent("else")
  echo lookupIdent("elses")
  var s = "abcd"
  echo s[1]
  echo type s[1]
