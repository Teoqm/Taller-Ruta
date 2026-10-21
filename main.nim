
# Programa principal de Ruta

import std/os
import ./lexer
import ./parser


# se buca el archivo
if not fileExists("Ruta.txt"):
  echo "Error: no se encontro Ruta.txt"
  quit(1)

let archivo = readFile("Ruta_1.txt")

try:
  # Primera etapa: analisis lexico
  let listaTokens = analizarLexico(archivo)

  echo "Analisis lexico correcto."
  echo "Tokens encontrados:"

  for token in listaTokens:
    echo token.kind, " | ", token.lexeme,
      " | linea: ", token.line,
      " | columna: ", token.column

  # Segunda etapa: analisis sintactico
  parsePrograma(listaTokens)

  echo "\nPrograma Ruta sintacticamente correcto."

except ValueError as error:
  echo "\n", error.msg
  quit(1)
