class Environment:
    def __init__(self, store={}):
        self.store = store

    def Get(self, name):
        obj = self.store.get(name)
        return obj

    def Set(self, name, val):
        self.store[name] = val
        return val

    def __str__(self):
        return "Environment"
