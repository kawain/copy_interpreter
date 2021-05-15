import tables
import obj


type Environment* = ref object
  store*: Table[string, obj.Obj]
  outer*: Environment


proc get*(self: Environment, name: string): (obj.Obj, bool) =
  var t: (obj.Obj, bool)
  if self.store.hasKey(name):
    t = (self.store[name], true)
  else:
    t = (nil, false)
    if self.outer != nil:
      t = self.outer.get(name)
  return t


proc set*(self: Environment, name: string, val: obj.Obj): obj.Obj =
  self.store[name] = val
  return val


proc NewEnvironment*(): Environment =
  return Environment(store: initTable[string, obj.Obj]())


proc NewEnclosedEnvironment*(outer: Environment): Environment =
  result = NewEnvironment()
  result.outer = outer

