%{
#include <stdio.h>
#include <stdlib.h>

/* Variable global para llevar el conteo de la línea actual */
int linea = 1;
%}

%option noyywrap

/* Macros y expresiones regulares para definir los componentes léxicos básicos */
IDENT       [a-zA-Z_][a-zA-Z0-9_]*
NUM         [0-9]+
CADENA      \"[^\"\n]*\"
ESPACIOS    [ \t]+
COMENTARIO  #[^\n]*

%%

    /* 1. Operadores Compuestos (Precedencia alta para evitar falsos positivos con operadores simples) */
":="        { printf("WALRUS %s %d\n", yytext, linea); }
"<="        { printf("MENOR_IGUAL %s %d\n", yytext, linea); }
">="        { printf("MAYOR_IGUAL %s %d\n", yytext, linea); }
"=="        { printf("IGUALDAD %s %d\n", yytext, linea); }
"!="        { printf("DIFERENTE %s %d\n", yytext, linea); }

    /* 2. Palabras Reservadas (Deben aparecer antes de la regla general de IDENTIFICADOR) */
"def"       { printf("DEF %s %d\n", yytext, linea); }
"return"    { printf("RETURN %s %d\n", yytext, linea); }
"if"        { printf("IF %s %d\n", yytext, linea); }
"else"      { printf("ELSE %s %d\n", yytext, linea); }
"while"     { printf("WHILE %s %d\n", yytext, linea); }
"print"     { printf("PRINT %s %d\n", yytext, linea); }

    /* 3. Operadores Simples y Signos de Puntuación */
"<"         { printf("MENOR %s %d\n", yytext, linea); }
">"         { printf("MAYOR %s %d\n", yytext, linea); }
":"         { printf("DOS_PUNTOS %s %d\n", yytext, linea); }
"="         { printf("ASIGNACION %s %d\n", yytext, linea); }
"+"         { printf("SUMA %s %d\n", yytext, linea); }
"-"         { printf("RESTA %s %d\n", yytext, linea); }
"*"         { printf("MULTIPLICACION %s %d\n", yytext, linea); }
"/"         { printf("DIVISION %s %d\n", yytext, linea); }
"%"         { printf("MODULO %s %d\n", yytext, linea); }
"("         { printf("PAR_IZQ %s %d\n", yytext, linea); }
")"         { printf("PAR_DER %s %d\n", yytext, linea); }
","         { printf("COMA %s %d\n", yytext, linea); }

    /* 4. Elementos definidos por Macros */
{IDENT}     { printf("ID %s %d\n", yytext, linea); }
{NUM}       { printf("ENTERO %s %d\n", yytext, linea); }
{CADENA}    { printf("CADENA %s %d\n", yytext, linea); }

    /* 5. Elementos a ignorar o procesar */
{ESPACIOS}  { /* Ignorar espacios y tabuladores */ }
{COMENTARIO} { /* Ignorar comentarios de una línea estilo Python */ }
\r          { /* Ignorar retorno de carro (compatibilidad de saltos de línea Windows CRLF) */ }
\n          { linea++; }

    /* 6. Regla de fallo / Error Léxico (Cualquier otro carácter no reconocido) */
.           {
                printf("ERROR LÉXICO: carácter/símbolo no reconocido '%s' en línea %d\n", yytext, linea);
                exit(1);
            }

%%

/* Sección de funciones auxiliares */
