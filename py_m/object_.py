from abc import ABCMeta, abstractmethod

NULL_OBJ = "NULL"
ERROR_OBJ = "ERROR"
INTEGER_OBJ = "INTEGER"
FLOAT_OBJ = "FLOAT"
BOOLEAN_OBJ = "BOOLEAN"
RETURN_VALUE_OBJ = "RETURN_VALUE"
FUNCTION_OBJ = "FUNCTION"


class Object(metaclass=ABCMeta):
    @abstractmethod
    def Type(self):
        pass

    @abstractmethod
    def Inspect(self):
        pass


class Integer(Object):
    """整数"""

    def __init__(self, value):
        self.value = value

    def Type(self):
        return INTEGER_OBJ

    def Inspect(self):
        return str(self.value)

    def __str__(self):
        return "Integer(Object)"


class Float(Object):
    """小数"""

    def __init__(self, value):
        self.value = value

    def Type(self):
        return FLOAT_OBJ

    def Inspect(self):
        return str(self.value)

    def __str__(self):
        return "Float(Object)"


class Boolean(Object):
    """真偽値"""

    def __init__(self, value):
        self.value = value

    def Type(self):
        return BOOLEAN_OBJ

    def Inspect(self):
        return str(self.value)

    def __str__(self):
        return "Boolean(Object)"


class Null(Object):
    """null"""

    def Type(self):
        return NULL_OBJ

    def Inspect(self):
        return "null"

    def __str__(self):
        return "Null(Object)"


if __name__ == "__main__":
    obj = Null()
    print(obj.Type())
    print(obj.Inspect())
    print(obj)
