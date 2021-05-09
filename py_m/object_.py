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


class ReturnValue(Object):
    """return文"""

    def __init__(self, value):
        self.value = value

    def Type(self):
        return RETURN_VALUE_OBJ

    def Inspect(self):
        return self.value.Inspect()

    def __str__(self):
        return "ReturnValue(Object)"


class Error(Object):
    """エラー"""

    def __init__(self, message):
        self.message = message

    def Type(self):
        return ERROR_OBJ

    def Inspect(self):
        return "ERROR: " + self.message

    def __str__(self):
        return "Error(Object)"


if __name__ == "__main__":
    obj = Null()
    print(obj.Type())
    print(obj.Inspect())
    print(obj)
