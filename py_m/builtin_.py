import object_
import evaluator_ as env


def builtin_len(args):
    if len(args) != 1:
        return env.newError(f"wrong number of arguments. got={len(args)}, want=1")
    if type(args[0]) is object_.String:
        return object_.Integer(len(args[0].value))
    return env.newError(f"argument to `len` not supported, got {args[0].Type()}")


builtins = {}
builtins["len"] = object_.Builtin(builtin_len)
