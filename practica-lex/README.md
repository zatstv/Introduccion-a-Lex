# Práctica: 10 ejercicios de Lex

Curso: IS-581 Compiladores e Intérpretes
Herramienta: Flex sobre Linux, compilado con `cc`

## Cómo ejecutar

```
make run          # compila y analiza input.txt
make clean        # borra scanner y lex.yy.c
./scanner < pruebas/ej04.txt
```

`scanner.l` es el archivo final, con todas las reglas de los diez ejercicios integradas.
Las entradas de prueba están en `pruebas/` y las salidas capturadas en `salidas/`.
Las respuestas a las preguntas van en `RESPUESTAS.md`.

## Reglas finales (`scanner.l`)

```lex
"let"                       { show_token("LET", yytext); }
"print"                     { show_token("PRINT", yytext); }
"if"                        { show_token("IF", yytext); }
[0-9]+"."[0-9]+             { show_token("DECIMAL", yytext); }
[0-9]+                      { show_token("NUMBER", yytext); }
[a-zA-Z_][a-zA-Z0-9_]*      { show_token("IDENTIFIER", yytext); }
\"[^"\\\n]*\"               { show_token("STRING", yytext); }
"=="                        { show_token("EQUAL_EQUAL", yytext); }
">="                        { show_token("GREATER_EQUAL", yytext); }
"="                         { show_token("ASSIGN", yytext); }
">"                         { show_token("GREATER", yytext); }
"+"                         { show_token("PLUS", yytext); }
"-"                         { show_token("MINUS", yytext); }
"*"                         { show_token("STAR", yytext); }
"("                         { show_token("LPAREN", yytext); }
")"                         { show_token("RPAREN", yytext); }
";"                         { show_token("SEMICOLON", yytext); }
"//"[^\n]*                  { /* Ignore line comments. */ }
[ \t\r]+                    { /* Ignore spaces, tabs and carriage returns. */ }
\n                          { current_line++; }
.                           { printf("Linea %d: caracter inesperado %s\n", current_line, yytext); lexical_errors++; }
```

---

## 1. Reconocer texto y mostrar su token

Acción modificada temporalmente en la regla `NUMBER`:

```lex
[0-9]+    { printf("Numero encontrado: %s\n", yytext); }
```

Requiere `#include <stdio.h>` entre `%{` y `%}`.

Entrada (`pruebas/ej01.txt`):

```
7 42 105
```

Salida:

```
Numero encontrado: 7
Numero encontrado: 42
Numero encontrado: 105
```

Coincide con lo pedido. Después restauré `show_token("NUMBER", yytext)` para que el resto de
los ejercicios mantengan el mismo formato.

---

## 2. Reconocer identificadores

Patrón sin cambios:

```lex
[a-zA-Z_][a-zA-Z0-9_]*    { show_token("IDENTIFIER", yytext); }
```

**Predicción antes de ejecutar:** `name`, `total2`, `_count` y `x` salen como IDENTIFIER.
`2total` no cumple el patrón desde el inicio, así que esperaba que se partiera.

Entrada (`pruebas/ej02.txt`):

```
name total2 _count x 2total
```

Salida:

```
IDENTIFIER   name
IDENTIFIER   total2
IDENTIFIER   _count
IDENTIFIER   x
NUMBER       2
IDENTIFIER   total
```

Confirmado: los primeros cuatro son IDENTIFIER y `2total` se parte en NUMBER `2` más
IDENTIFIER `total`.

---

## 3. Palabras reservadas y orden de las reglas

Reglas agregadas, antes de la de identificadores:

```lex
"let"      { show_token("LET", yytext); }
"print"    { show_token("PRINT", yytext); }
"if"       { show_token("IF", yytext); }
```

Entrada (`pruebas/ej03.txt`):

```
print printer if if2 let letter
```

Salida con las reservadas primero:

```
PRINT        print
IDENTIFIER   printer
IF           if
IDENTIFIER   if2
LET          let
IDENTIFIER   letter
```

Tipos esperados: PRINT, IDENTIFIER, IF, IDENTIFIER, LET, IDENTIFIER. Coincide.

### Experimento: identificadores antes de las reservadas

Al mover `[a-zA-Z_][a-zA-Z0-9_]*` arriba de las tres palabras reservadas, Flex advierte:

```
scanner.l:11: warning, la regla no se puede aplicar
scanner.l:12: warning, la regla no se puede aplicar
scanner.l:13: warning, la regla no se puede aplicar
```

Y la salida cambia:

```
IDENTIFIER   print
IDENTIFIER   printer
IDENTIFIER   if
IDENTIFIER   if2
IDENTIFIER   let
IDENTIFIER   letter
```

Las tres palabras reservadas quedaron inalcanzables y todo sale como IDENTIFIER. Nótese que
`printer` sigue siendo un solo token en ambos casos. Después restauré el orden correcto.

---

## 4. Operadores y signos de puntuación

```lex
"-"    { show_token("MINUS", yytext); }
"*"    { show_token("STAR", yytext); }
"("    { show_token("LPAREN", yytext); }
")"    { show_token("RPAREN", yytext); }
```

Van antes de la regla final `.` que atrapa los caracteres no reconocidos.

Entrada (`pruebas/ej04.txt`):

```
let result = (10 - 2) * 3;
```

Salida:

```
LET          let
IDENTIFIER   result
ASSIGN       =
LPAREN       (
NUMBER       10
MINUS        -
NUMBER       2
RPAREN       )
STAR         *
NUMBER       3
SEMICOLON    ;
```

Once tokens, los dos paréntesis incluidos, sin ninguna entrada ERROR.

---

## 5. Coincidencia más larga

```lex
"=="    { show_token("EQUAL_EQUAL", yytext); }
">="    { show_token("GREATER_EQUAL", yytext); }
"="     { show_token("ASSIGN", yytext); }
">"     { show_token("GREATER", yytext); }
```

Entrada (`pruebas/ej05.txt`):

```
= == > >= ===
```

Salida:

```
ASSIGN       =
EQUAL_EQUAL  ==
GREATER      >
GREATER_EQUAL >=
EQUAL_EQUAL  ==
ASSIGN       =
```

Coincide con lo esperado: ASSIGN, EQUAL_EQUAL, GREATER, GREATER_EQUAL, EQUAL_EQUAL, ASSIGN.

---

## 6. Números decimales

```lex
[0-9]+"."[0-9]+    { show_token("DECIMAL", yytext); }
[0-9]+             { show_token("NUMBER", yytext); }
```

Entrada (`pruebas/ej06.txt`):

```
7 3.14 0.5 25.00
```

Salida:

```
NUMBER       7
DECIMAL      3.14
DECIMAL      0.5
DECIMAL      25.00
```

NUMBER, DECIMAL, DECIMAL, DECIMAL, como se pedía.

Casos límite (`pruebas/ej06b.txt`), con `.5` y `5.`:

```
.5 5.
```

Salida:

```
ERROR        .
NUMBER       5
NUMBER       5
ERROR        .
```

Ninguno cumple el formato decimal. Cada entrada da un ERROR por el punto y un NUMBER por el
dígito, en el orden en que aparecen.

---

## 7. Ignorar espacios y comentarios

```lex
"//"[^\n]*      { /* Ignore line comments. */ }
[ \t\r\n]+      { /* Ignore whitespace. */ }
```

Entrada (`pruebas/ej07.txt`):

```
let x = 1; // Primer valor

    let y = 2; // Segundo valor
```

Salida:

```
LET          let
IDENTIFIER   x
ASSIGN       =
NUMBER       1
SEMICOLON    ;
LET          let
IDENTIFIER   y
ASSIGN       =
NUMBER       2
SEMICOLON    ;
```

Diez tokens, los de las dos instrucciones. Los espacios, la línea en blanco y los dos
comentarios no generan ningún token.

---

## 8. Cadenas de texto

```lex
\"[^"\\\n]*\"    { show_token("STRING", yytext); }
```

El contenido no admite comillas dobles, barras invertidas ni saltos de línea. No hay
secuencias de escape.

Entrada (`pruebas/ej08.txt`):

```
print "hola mundo";
print "";
```

Salida:

```
PRINT        print
STRING       "hola mundo"
SEMICOLON    ;
PRINT        print
STRING       ""
SEMICOLON    ;
```

PRINT, STRING, SEMICOLON dos veces. El lexema se muestra completo, con sus comillas, y la
cadena vacía es válida.

---

## 9. Errores con número de línea

Declaración en la sección de C:

```c
int current_line = 1;
```

Reglas modificadas:

```lex
[ \t\r]+    { /* Ignore spaces, tabs and carriage returns. */ }
\n          { current_line++; }
.           { printf("Linea %d: caracter inesperado %s\n", current_line, yytext);
              lexical_errors++; }
```

Entrada (`pruebas/ej09.txt`):

```
let x = 1;
@
let y = 2;
$
```

Salida:

```
LET          let
IDENTIFIER   x
ASSIGN       =
NUMBER       1
SEMICOLON    ;
Linea 2: caracter inesperado @
LET          let
IDENTIFIER   y
ASSIGN       =
NUMBER       2
SEMICOLON    ;
Linea 4: caracter inesperado $
```

Reporta `@` en la línea 2 y `$` en la línea 4, y sigue analizando después de cada error.
El programa termina con código de salida 1, así que `make run` reporta
`make: *** [Makefile:12: run] Error 1`. Eso es lo esperado para esta entrada.

---

## 10. Analizador integrado

Todas las reglas anteriores juntas.

Entrada (`pruebas/ej10.txt`):

```
let total = (12 + 3) * 2;
let price = 3.50;
// Mostrar un mensaje
if total >= 20 print "total grande";
```

**Predicción antes de ejecutar:**

| Línea | Tipos de token esperados |
|---|---|
| 1 | LET, IDENTIFIER, ASSIGN, LPAREN, NUMBER, PLUS, NUMBER, RPAREN, STAR, NUMBER, SEMICOLON |
| 2 | LET, IDENTIFIER, ASSIGN, DECIMAL, SEMICOLON |
| 3 | Ningún token |
| 4 | IF, IDENTIFIER, GREATER_EQUAL, NUMBER, PRINT, STRING, SEMICOLON |

Salida:

```
LET          let
IDENTIFIER   total
ASSIGN       =
LPAREN       (
NUMBER       12
PLUS         +
NUMBER       3
RPAREN       )
STAR         *
NUMBER       2
SEMICOLON    ;
LET          let
IDENTIFIER   price
ASSIGN       =
DECIMAL      3.50
SEMICOLON    ;
IF           if
IDENTIFIER   total
GREATER_EQUAL >=
NUMBER       20
PRINT        print
STRING       "total grande"
SEMICOLON    ;
```

23 tokens, ningún error, código de salida 0. Coincide línea por línea con la predicción.

### Prueba extra (a): `@` en una quinta línea

```
STRING       "total grande"
SEMICOLON    ;
Linea 5: caracter inesperado @
```

El error se reporta en la línea 5, aunque la línea 3 sea un comentario que no produce tokens.
El contador no se pierde porque el patrón del comentario deja el salto de línea sin consumir.

### Prueba extra (b): palabras reservadas dentro de identificadores

Entrada (`pruebas/ej10c.txt`):

```
printer letx ifelse total_if myprint if_
```

Salida:

```
IDENTIFIER   printer
IDENTIFIER   letx
IDENTIFIER   ifelse
IDENTIFIER   total_if
IDENTIFIER   myprint
IDENTIFIER   if_
```

Los seis salen como IDENTIFIER. La palabra reservada está contenida en el texto pero el
patrón de identificadores reconoce más caracteres, así que gana por longitud sin que el
orden de las reglas intervenga.

### Prueba extra (c): `//` dentro de una cadena

Entrada (`pruebas/ej10d.txt`):

```
print "esto // no es un comentario";
let a = 1; // esto si lo es
```

Salida:

```
PRINT        print
STRING       "esto // no es un comentario"
SEMICOLON    ;
LET          let
IDENTIFIER   a
ASSIGN       =
NUMBER       1
SEMICOLON    ;
```

El `//` de adentro de la cadena queda dentro del token STRING y no abre un comentario,
porque cuando el scanner llega a la comilla de apertura la regla de STRING ya se lleva todo
hasta la comilla de cierre. El `//` de la segunda línea sí funciona como comentario.

---

## Alcance

Este analizador reconoce tokens y nada más. No evalúa expresiones ni verifica la estructura
gramatical del programa. Por eso acepta sin protestar una entrada como `let let = ) ) ;`,
que es una secuencia de tokens válida y un programa sin ningún sentido.
