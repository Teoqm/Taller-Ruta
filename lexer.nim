
# Analizador lexico de Ruta

import std/strutils
import ./tokens

proc esInicioId(c: char): bool =
  c in 'a'..'z' or c in 'A'..'Z' or c == '_'

proc esParteId(c: char): bool =
  esInicioId(c) or c in '0'..'9'

proc esDigito(c: char): bool =
  c in '0'..'9'

proc tipoPalabra(palabra: string): TokenKind =
  case palabra.toLowerAscii()
  of "robot": tkRobot
  of "forward": tkForward
  of "backward": tkBackward
  of "turn": tkTurn
  of "right": tkRight
  of "left": tkLeft
  of "repeat": tkRepeat
  of "if": tkIf
  of "then": tkThen
  of "else": tkElse
  of "end": tkEnd
  of "stop": tkStop
  of "return": tkReturn
  of "base": tkBase
  of "front_sensor": tkFrontSensor
  else: tkId

proc analizarLexico*(codigo: string): seq[Token] =
  var i = 0
  var linea = 1
  var columna = 1

  while i < codigo.len:
    let c = codigo[i]

    # Ignorar espacios y tabulaciones
    if c == ' ' or c == '\t' or c == '\r':
      i += 1
      columna += 1
      continue

    # Contar saltos de linea
    if c == '\n':
      i += 1
      linea += 1
      columna = 1
      continue

    let inicio = i
    let columnaInicio = columna
    let lineaInicio = linea

    # Reconocer identificadores y palabras reservadas
    if esInicioId(c):
      while i < codigo.len and esParteId(codigo[i]):
        i += 1
        columna += 1

      let palabra = codigo[inicio ..< i]
      result.add(Token(
        kind: tipoPalabra(palabra),
        lexeme: palabra,
        line: lineaInicio,
        column: columnaInicio
      ))
      continue

    # Reconocer numeros enteros
    if esDigito(c):
      while i < codigo.len and esDigito(codigo[i]):
        i += 1
        columna += 1

      result.add(Token(
        kind: tkNum,
        lexeme: codigo[inicio ..< i],
        line: lineaInicio,
        column: columnaInicio
      ))
      continue
    
    # averguar si hay comentario
    # Ignorar comentarios que comienzan con //
    if c == '/' and i + 1 < codigo.len and codigo[i + 1] == '/':
      while i < codigo.len and codigo[i] != '\n':
        i += 1
        columna += 1

      continue


    # Reconocer operadores de dos caracteres primero
    if i + 1 < codigo.len:
      let dos = codigo[i .. i + 1]
      var tipo: TokenKind
      var reconocido = true

      case dos
      of "==": tipo = tkEqual
      of "!=": tipo = tkNotEqual
      of "<=": tipo = tkLessEqual
      of ">=": tipo = tkGreaterEqual
      else: reconocido = false

      if reconocido:
        result.add(Token(
          kind: tipo,
          lexeme: dos,
          line: lineaInicio,
          column: columnaInicio
        ))
        i += 2
        columna += 2
        continue

    # Reconocer operadores y delimitadores simples
    var tipo: TokenKind

    case c
    of '=': tipo = tkAssign
    of '<': tipo = tkLess
    of '>': tipo = tkGreater
    of '+': tipo = tkPlus
    of '-': tipo = tkMinus
    of '*': tipo = tkMultiply
    of '/': tipo = tkDivide
    of '(': tipo = tkLParen
    of ')': tipo = tkRParen
    of '{': tipo = tkLBrace
    of '}': tipo = tkRBrace
    else:
      raise newException(ValueError,
        "Error lexico en linea " & $linea &
        ", columna " & $columna &
        ": caracter no reconocido '" & $c & "'")

    result.add(Token(
      kind: tipo,
      lexeme: $c,
      line: lineaInicio,
      column: columnaInicio
    ))

    i += 1
    columna += 1

  result.add(Token(
    kind: tkEOF,
    lexeme: "",
    line: linea,
    column: columna
  ))

  


  
    
