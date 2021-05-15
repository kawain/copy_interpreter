import strutils
import token

type
  Lexer* = ref object
    input: string
    position: int     # current position in input (points to current char)
    nextPosition: int # current reading position in input (after current char)
    ch: char          # current char under examination
    size: int         # 変更箇所

proc isLetter(ch: char): bool =
  ('a' <= ch and ch <= 'z') or ('A' <= ch and ch <= 'Z') or (ch == '_')

proc isDigit(ch: char): bool =
  ('0' <= ch and ch <= '9') or (ch == '.')

proc readChar(lex: Lexer) =
  if lex.nextPosition >= lex.size:
    lex.ch = '\0'
  else:
    lex.ch = lex.input[lex.nextPosition]
  lex.position = lex.nextPosition
  lex.nextPosition += 1

proc peekChar(lex: Lexer): char =
  if lex.nextPosition >= lex.size:
    return '\0'
  lex.input[lex.nextPosition]

proc skipWhitespace(lex: Lexer) =
  while lex.ch == ' ' or lex.ch == '\t' or lex.ch == '\n' or lex.ch == '\r':
    lex.readChar()

proc readIdentifier(lex: Lexer): string =
  let position = lex.position
  while isLetter(lex.ch):
    lex.readChar()
  lex.input[position..<lex.position]

proc readNumber(lex: Lexer): string =
  let position = lex.position
  while isDigit(lex.ch):
    lex.readChar()
  lex.input[position..<lex.position]

proc readString(lex: Lexer): string =
  let position = lex.position + 1
  while true:
    lex.readChar()
    if lex.ch == '"' or lex.ch == '\0':
      break
  return lex.input[position..<lex.position]

proc LexerNew*(input: string): Lexer =
  result = new Lexer
  result.input = input
  result.size = len(input)
  result.readChar()

proc nextToken*(lex: Lexer): Token =
  result = new Token

  lex.skipWhitespace()

  case lex.ch
  of '=':
    if lex.peekChar() == '=':
      lex.readChar()
      result.tokenType = EQ
      result.literal = "=="
    else:
      result.tokenType = ASSIGN
      # '$'を使用して、文字を単一の文字列に変換できます
      result.literal = $lex.ch
  of '+':
    result.tokenType = PLUS
    result.literal = $lex.ch
  of '-':
    result.tokenType = MINUS
    result.literal = $lex.ch
  of '!':
    if lex.peekChar() == '=':
      lex.readChar()
      result.tokenType = NOT_EQ
      result.literal = "!="
    else:
      result.tokenType = BANG
      result.literal = $lex.ch
  of '/':
    result.tokenType = SLASH
    result.literal = $lex.ch
  of '*':
    result.tokenType = ASTERISK
    result.literal = $lex.ch
  of '<':
    result.tokenType = LT
    result.literal = $lex.ch
  of '>':
    result.tokenType = GT
    result.literal = $lex.ch
  of ';':
    result.tokenType = SEMICOLON
    result.literal = $lex.ch
  of ',':
    result.tokenType = COMMA
    result.literal = $lex.ch
  of '{':
    result.tokenType = LBRACE
    result.literal = $lex.ch
  of '}':
    result.tokenType = RBRACE
    result.literal = $lex.ch
  of '(':
    result.tokenType = LPAREN
    result.literal = $lex.ch
  of ')':
    result.tokenType = RPAREN
    result.literal = $lex.ch
  of '"':
    result.tokenType = STRING
    result.literal = lex.readString()
  of '\0':
    result.tokenType = EOF
    result.literal = ""
  else:
    if isLetter(lex.ch):
      result.literal = lex.readIdentifier()
      result.tokenType = lookupIdent(result.literal)
      return result
    elif isDigit(lex.ch):
      let literal = lex.readNumber()
      if literal.count(".") == 0:
        result.tokenType = INT
        result.literal = literal
        return result
      elif literal.count(".") == 1:
        result.tokenType = FLOAT
        result.literal = literal
        return result
      else:
        result.tokenType = ILLEGAL
        result.literal = literal
    else:
      result.tokenType = ILLEGAL
      result.literal = $lex.ch

  lex.readChar()
