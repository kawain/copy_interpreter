import lexer
import parser
import obj
import eval

const PROMPT = ">> "


proc printParserErrors(e: seq[string]) =
  echo "Woops! We ran into some monkey business here!"
  echo " parser errors:"
  for v in e:
    echo v


proc start*() =
  while true:
    stdout.write PROMPT
    let input = readLine(stdin)
    var l = LexerNew(input)
    var p = ParserNew(l)
    let program = p.parseProgram()
    if len(p.Errors()) != 0:
      printParserErrors(p.Errors())
      continue

    let evaluated = eval.Eval(program)
    if evaluated != nil:
      echo evaluated.Inspect()
