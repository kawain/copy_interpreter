import strformat


const
  INTEGER_OBJ* = "INTEGER"
  BOOLEAN_OBJ* = "BOOLEAN"
  NULL_OBJ* = "NULL"
  ERROR_OBJ* = "ERROR"
  RETURN_VALUE_OBJ* = "RETURN_VALUE"



type Obj* = ref object of RootObj

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
