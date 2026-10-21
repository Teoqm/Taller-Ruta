
# Analizador sintactico de Ruta

import ./tokens

type
  Parser = object
    tokens: seq[Token]
    pos: int

proc actual(p: Parser): Token =
  p.tokens[p.pos]

proc errorSintactico(p: Parser, mensaje: string) =
  let token = p.actual()
  raise newException(ValueError,
    "Error sintactico en linea " & $token.line &
    ", columna " & $token.column &
    ": " & mensaje &
    " (encontrado: '" & token.lexeme & "')")

proc aceptar(p: var Parser, esperado: TokenKind) =
  if p.actual().kind == esperado:
    p.pos += 1
  else:
    p.errorSintactico(
      "Se esperaba " & $esperado
    )

proc esInicioSentencia(tipo: TokenKind): bool =
  tipo in {
    tkId, tkForward, tkBackward, tkTurn,
    tkRepeat, tkIf, tkStop
  }

# Declaraciones anticipadas
proc parseExpresion(p: var Parser)
proc parseSentencias(
  p: var Parser,
  fin1: TokenKind,
  fin2: TokenKind
)
proc parseSentencia(p: var Parser)
proc parseCondicion(p: var Parser)


# reconoce números, identificadores, front_sensor y 
# expresiones entre paréntesis.
# factor -> NUM | ID | front_sensor | ( expresion )
proc parseFactor(p: var Parser) =
  case p.actual().kind
  of tkNum, tkId, tkFrontSensor:
    p.pos += 1
  of tkLParen:
    p.aceptar(tkLParen)
    p.parseExpresion()
    p.aceptar(tkRParen)
  else:
    p.errorSintactico(
      "Se esperaba un numero, identificador o expresion entre parentesis"
    )
# reconoce multiplicaciones y divisiones.
# termino -> factor { (* | /) factor }
proc parseTermino(p: var Parser) =
  p.parseFactor()

  while p.actual().kind in {tkMultiply, tkDivide}:
    p.pos += 1
    p.parseFactor()

# reconoce sumas y restas respetando la precedencia.
# expresion -> termino { (+ | -) termino }
proc parseExpresion(p: var Parser) =
  p.parseTermino()

  while p.actual().kind in {tkPlus, tkMinus}:
    p.pos += 1
    p.parseTermino()
# comprueba que exista un operador
# relacional entre dos expresiones.
# condicion -> expresion operadorRelacional expresion
proc parseCondicion(p: var Parser) =
  p.parseExpresion()

  if p.actual().kind in {
    tkEqual, tkNotEqual,
    tkLess, tkLessEqual,
    tkGreater, tkGreaterEqual
  }:
    p.pos += 1
  else:
    p.errorSintactico(
      "Se esperaba un operador relacional"
    )

  p.parseExpresion()

# permite bloques vacíos y procesa instrucciones 
# hasta encontrar el cierre correspondiente.
# sentencias -> sentencia sentencias | epsilon
proc parseSentencias(
  p: var Parser,
  fin1: TokenKind,
  fin2: TokenKind
) =
  while p.actual().kind notin {fin1, fin2}:
    if p.actual().kind == tkEOF:
      p.errorSintactico(
        "Fin de archivo inesperado dentro del bloque"
      )

    # Detectar return antes del cierre de un bloque repeat.
    if fin1 == tkRBrace and p.actual().kind == tkReturn:
      p.errorSintactico(
        "Se esperaba '}' antes de return"
      )

    if not esInicioSentencia(p.actual().kind):
      p.errorSintactico(
        "Token inesperado al comenzar una sentencia"
      )

    p.parseSentencia()

# reconoce asignaciones, movimientos, 
# giros, repeticiones, decisiones y stop.

# sentencia -> asignacion | movimiento | giro |
#              repeticion | decision | stop
proc parseSentencia(p: var Parser) =
  case p.actual().kind

  of tkId:
    # asignacion -> ID = expresion
    p.aceptar(tkId)
    p.aceptar(tkAssign)
    p.parseExpresion()

  of tkForward, tkBackward:
    # movimiento -> (forward | backward) expresion
    p.pos += 1
    p.parseExpresion()

  of tkTurn:
    # giro -> turn (right | left)
    p.aceptar(tkTurn)

    if p.actual().kind in {tkRight, tkLeft}:
      p.pos += 1
    else:
      p.errorSintactico(
        "Se esperaba right o left despues de turn"
      )

  of tkRepeat:
    # repeticion -> repeat expresion { sentencias }
    p.aceptar(tkRepeat)
    p.parseExpresion()
    p.aceptar(tkLBrace)

    p.parseSentencias(tkRBrace, tkRBrace)

    if p.actual().kind != tkRBrace:
      p.errorSintactico("Se esperaba '}' para cerrar repeat")

    p.aceptar(tkRBrace)

  of tkIf:
    # decision -> if condicion then sentencias
    #             [else sentencias] end
    p.aceptar(tkIf)
    p.parseCondicion()
    p.aceptar(tkThen)

    p.parseSentencias(tkElse, tkEnd)

    if p.actual().kind == tkElse:
      p.aceptar(tkElse)
      p.parseSentencias(tkEnd, tkEnd)

    p.aceptar(tkEnd)

  of tkStop:
    p.aceptar(tkStop)

  else:
    p.errorSintactico("Sentencia no reconocida")

# verifica la estructura general y exige return base al final.
# programa -> robot ID sentencias return base EOF
proc parsePrograma*(listaTokens: seq[Token]) =
  if listaTokens.len == 0:
    raise newException(ValueError, "La lista de tokens esta vacia")

  var p = Parser(tokens: listaTokens, pos: 0)

  p.aceptar(tkRobot)
  p.aceptar(tkId)

  # El cuerpo principal termina al encontrar return
  p.parseSentencias(tkReturn, tkReturn)

  # El programa debe terminar obligatoriamente con return base
  p.aceptar(tkReturn)
  p.aceptar(tkBase)
  p.aceptar(tkEOF)
