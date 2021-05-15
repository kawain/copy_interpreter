import strutils
import strformat
import tables
import ast


const
  INTEGER_OBJ* = "INTEGER"
  BOOLEAN_OBJ* = "BOOLEAN"
  NULL_OBJ* = "NULL"
  ERROR_OBJ* = "ERROR"
  RETURN_VALUE_OBJ* = "RETURN_VALUE"
  FUNCTION_OBJ* = "FUNCTION"
  STRING_OBJ* = "STRING"
  BUILTIN_OBJ* = "BUILTIN"


type
  Obj* = ref object of RootObj

  Environment* = ref object
    store*: Table[string, Obj]
    outer*: Environment

  BuiltinFunction = proc(args: seq[Obj]): Obj


proc get*(self: Environment, name: string): (Obj, bool) =
  var t: (Obj, bool)
  if self.store.hasKey(name):
    t = (self.store[name], true)
  else:
    t = (nil, false)
    if self.outer != nil:
      t = self.outer.get(name)
  return t


proc set*(self: Environment, name: string, val: Obj): Obj =
  self.store[name] = val
  return val


proc NewEnvironment*(): Environment =
  return Environment(store: initTable[string, Obj]())


proc NewEnclosedEnvironment*(outer: Environment): Environment =
  result = NewEnvironment()
  result.outer = outer


method Type*(self: Obj): string{.base.} =
  result = ""

method Inspect*(self: Obj): string{.base.} =
  result = ""


type Integer* = ref object of Obj
  value*: int

method Type*(self: Integer): string =
  result = INTEGER_OBJ

method Inspect*(self: Integer): string =
  result = fmt"{self.value}"


type Boolean* = ref object of Obj
  value*: bool

method Type*(self: Boolean): string =
  result = BOOLEAN_OBJ

method Inspect*(self: Boolean): string =
  result = fmt"{self.value}"


type Null* = ref object of Obj

method Type*(self: Null): string =
  result = NULL_OBJ

method Inspect*(self: Null): string =
  result = "null"


type ReturnValue* = ref object of Obj
  value*: Obj

method Type*(self: ReturnValue): string =
  result = RETURN_VALUE_OBJ

method Inspect*(self: ReturnValue): string =
  result = self.value.Inspect()


type Error* = ref object of Obj
  message*: string

method Type*(self: Error): string =
  result = ERROR_OBJ

method Inspect*(self: Error): string =
  result = fmt"ERROR: {self.message}"


type Function* = ref object of Obj
  parameters*: seq[ast.Identifier]
  body*: ast.BlockStatement
  env*: Environment

method Type*(self: Function): string =
  result = FUNCTION_OBJ

method Inspect*(self: Function): string =
  var params = newSeq[string]()

  for v in self.parameters:
    params.add(v.toString())

  result = "fn"
  result.add("(")
  result.add(params.join(", "))
  result.add(") {\n")
  result.add(self.body.toString())
  result.add("\n}")


type String* = ref object of Obj
  value*: string

method Type*(self: String): string =
  result = STRING_OBJ

method Inspect*(self: String): string =
  result = self.value


type Builtin* = ref object of Obj
  fn*: BuiltinFunction

method Type*(self: Builtin): string =
  result = BUILTIN_OBJ

method Inspect*(self: Builtin): string =
  result = "builtin function"
