#include <stdio.h>
#include <stdlib.h>

/* Declaraciones de variables y funciones de Flex */
extern FILE *yyin;
extern int yylex(void);

int main(int argc, char *argv[]) {
    // Validar el número de argumentos recibidos por línea de comandos
    if (argc != 2) {
        fprintf(stderr, "Uso: %s <archivo_fuente.pys>\n", argv[0]);
        return 1;
    }

    // Abrir el archivo de código fuente en modo lectura
    FILE *archivo = fopen(argv[1], "r");
    if (!archivo) {
        perror("Error al abrir el archivo de entrada");
        return 1;
    }

    // Redirigir la entrada estándar de Flex (yyin) al archivo abierto
    yyin = archivo;

    // Iniciar el análisis léxico
    yylex();

    // Cerrar el archivo abierto y finalizar correctamente
    fclose(archivo);
    return 0;
}
