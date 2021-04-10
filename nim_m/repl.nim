import lexer
import token

const PROMPT = ">> "

proc start*() =
  while true:
    stdout.write PROMPT
    let input = readLine(stdin)
    var l = LexerNew(input)

    while true:
        var t = l.nextToken()
        echo t[]
        if t.tokenType == EOF:
          break
