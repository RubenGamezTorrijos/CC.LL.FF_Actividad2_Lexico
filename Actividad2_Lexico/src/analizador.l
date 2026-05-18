%{
#include <stdio.h>
#include <stdlib.h>

/* Variable global para llevar el conteo de la línea actual */
int linea = 1;
%}

%option noyywrap
%option noyywarn

/* Macros y expresiones regulares para definir los componentes léxicos básicos */
IDENT       [a-zA-Z_][a-zA-Z0-9_]*
NUM         [0-9]+
CADENA      \"[^\"\n]*\"
ESPACIOS    [ \t]+
COMENTARIO  #[^\n]*

%%

/* 1. Operadores Compuestos (Precedencia alta para evitar falsos positivos con operadores simples) */
":="        { printf("OP_WALRUS\t%s\t%d\n", yytext, linea); }
"<="        { printf("OP_MENOR_IGUAL\t%s\t%d\n", yytext, linea); }
">="        { printf("OP_MAYOR_IGUAL\t%s\t%d\n", yytext, linea); }
"=="        { printf("OP_IGUALDAD\t%s\t%d\n", yytext, linea); }
"!="        { printf("OP_DIFERENTE\t%s\t%d\n", yytext, linea); }

/* 2. Palabras Reservadas (Deben aparecer antes de la regla general de IDENTIFICADOR) */
"def"       { printf("PR_DEF\t%s\t%d\n", yytext, linea); }
"return"    { printf("PR_RETURN\t%s\t%d\n", yytext, linea); }
"if"        { printf("PR_IF\t%s\t%d\n", yytext, linea); }
"else"      { printf("PR_ELSE\t%s\t%d\n", yytext, linea); }
"while"     { printf("PR_WHILE\t%s\t%d\n", yytext, linea); }
"print"     { printf("PR_PRINT\t%s\t%d\n", yytext, linea); }

/* 3. Operadores Simples y Signos de Puntuación */
"<"         { printf("OP_MENOR\t%s\t%d\n", yytext, linea); }
">"         { printf("OP_MAYOR\t%s\t%d\n", yytext, linea); }
":"         { printf("SIGNO_DOS_PUNTOS\t%s\t%d\n", yytext, linea); }
"="         { printf("OP_ASIGNACION\t%s\t%d\n", yytext, linea); }
"+"         { printf("OP_SUMA\t%s\t%d\n", yytext, linea); }
"-"         { printf("OP_RESTA\t%s\t%d\n", yytext, linea); }
"*"         { printf("OP_MULTIPLICACION\t%s\t%d\n", yytext, linea); }
"/"         { printf("OP_DIVISION\t%s\t%d\n", yytext, linea); }
"%"         { printf("OP_MODULO\t%s\t%d\n", yytext, linea); }
"("         { printf("PARENTESIS_ABRIR\t%s\t%d\n", yytext, linea); }
")"         { printf("PARENTESIS_CERRAR\t%s\t%d\n", yytext, linea); }
","         { printf("SIGNO_COMA\t%s\t%d\n", yytext, linea); }

/* 4. Elementos definidos por Macros */
{IDENT}     { printf("IDENTIFICADOR\t%s\t%d\n", yytext, linea); }
{NUM}       { printf("NUMERO\t%s\t%d\n", yytext, linea); }
{CADENA}    { printf("CADENA\t%s\t%d\n", yytext, linea); }

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
int yywrap(void) {
    return 1;
}
