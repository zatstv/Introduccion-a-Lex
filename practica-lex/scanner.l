%option noyywrap
%{
#include <stdio.h>
void show_token(const char *kind, const char *text);
int lexical_errors = 0;
int current_line = 1;
%}

%%
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
%%
