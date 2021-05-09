class Environment:
    def __init__(self):
        self.store = {}
        self.outer = None

    # 辞書のデフォルト引数は、違うオブジェクトを作ったとき
    # 引数を省略して関数を呼び出すと、前の値が使われるので注意
    #                           ↓ アウト
    # def __init__(self, store={}, outer=None):
    #     self.store = store
    #     self.outer = outer

    def Get(self, name):
        obj = self.store.get(name)
        if obj is None and self.outer is not None:
            obj = self.outer.Get(name)

        return obj

    def Set(self, name, val):
        self.store[name] = val
        return val

    def __str__(self):
        return "Environment"


def NewEnvironment():
    return Environment()


def NewEnclosedEnvironment(outer):
    e = NewEnvironment()
    e.outer = outer
    return e
