# Tipos de tokens utilizados por el lenguaje Ruta.
# Cada token representa una palabra reservada, un identificador,
# un numero, un operador o un delimitador.

type
  TokenKind* = enum

    # Palabras reservadas para definir instrucciones de Ruta.
    tkRobot,        # Indica el inicio de la declaracion del robot.
    tkForward,      # Orden para avanzar.
    tkBackward,     # Orden para retroceder.
    tkTurn,         # Introduce una instruccion de giro.
    tkRight,        # Indica un giro hacia la derecha.
    tkLeft,         # Indica un giro hacia la izquierda.
    tkRepeat,       # Inicia una instruccion de repeticion.
    tkIf,           # Inicia una condicion.
    tkThen,         # Separa la condicion de las instrucciones.
    tkElse,         # Introduce el bloque alternativo de una condicion.
    tkEnd,          # Marca el final de una condicion.
    tkStop,         # Orden para detener el robot.
    tkReturn,       # Indica el final del programa.
    tkBase,         # Completa la instruccion return base.
    tkFrontSensor,  # Representa el sensor frontal del robot.

    # Tokens para valores y nombres definidos por el programador.
    tkId,           # Identificador de una variable.
    tkNum,          # Numero entero.

    # Operadores de asignacion y comparacion.
    tkAssign,       # Operador de asignacion (=).
    tkEqual,        # Comparacion de igualdad (==).
    tkNotEqual,     # Comparacion de desigualdad (!=).
    tkLess,         # Menor que (<).
    tkLessEqual,    # Menor o igual que (<=).
    tkGreater,      # Mayor que (>).
    tkGreaterEqual, # Mayor o igual que (>=).

    # Operadores aritmeticos.
    tkPlus,         # Suma (+).
    tkMinus,        # Resta (-).
    tkMultiply,     # Multiplicacion (*).
    tkDivide,       # Division (/).

    # Delimitadores para expresiones y bloques.
    tkLParen,       # Parentesis de apertura: (
    tkRParen,       # Parentesis de cierre: )
    tkLBrace,       # Llave de apertura: {
    tkRBrace,       # Llave de cierre: }

    # Marca el final de la secuencia de tokens.
    tkEOF

  # Estructura que almacena la informacion de un token.
  Token* = object
    kind*: TokenKind  # Tipo de token reconocido.
    lexeme*: string   # Texto original que representa el token.
    line*: int        # Numero de linea donde aparece.
    column*: int      # Columna donde comienza el token.