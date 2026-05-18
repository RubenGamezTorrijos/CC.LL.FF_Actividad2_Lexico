# Explicación Detallada del Analizador Léxico (Flex)

Este documento contiene la explicación técnica y de arquitectura del analizador léxico desarrollado en Flex (`src/analizador.l`), describiendo sus componentes y las bases teóricas de su funcionamiento.

---

## 1. Estructura del Archivo de Especificación (`src/analizador.l`)

Un archivo escrito para Flex consta de tres secciones bien delimitadas, separadas por la marca de sección `%%`. En nuestro proyecto, estas partes se desglosan de la siguiente manera:

### Sección 1: Declaraciones y Definiciones (Definiciones Léxicas)
Ubicada en la parte superior, antes de la primera marca `%%`.
*   **Código C Empotrado (`%{` y `%}`):** Este bloque contiene código C directo que se copiará tal cual en el archivo final generado (`lex.yy.c`). Aquí incluimos las librerías necesarias (`stdio.h`, `stdlib.h`) y la variable global `linea` para controlar el número de línea.
*   **Directivas de Flex (`%option`):**
    *   `%option noyywrap`: Indica que no se llamará a la función `yywrap()` al llegar al final del archivo actual. Esto simplifica el código al no requerir enlazar la librería externa de flex (`-lfl`), permitiendo una compilación limpia directa con `gcc`.
    *   `%option noyywarn`: Desactiva advertencias del generador de Flex que no sean críticas, manteniendo una salida más limpia.
*   **Macros Léxicas (Expresiones Regulares):** Definimos abreviaciones que representan expresiones regulares complejas para ser reutilizadas en las reglas.
    *   `IDENT` `[a-zA-Z_][a-zA-Z0-9_]*`: Representa un identificador de variable o función. Debe comenzar por una letra o guión bajo, seguido opcionalmente de letras, dígitos o guiones bajos.
    *   `NUM` `[0-9]+`: Representa secuencias numéricas (dígitos enteros de cualquier tamaño).
    *   `CADENA` `\"[^\"\n]*\"`: Cadenas entre comillas dobles que no pueden contener saltos de línea internos en su versión básica.
    *   `ESPACIOS` `[ \t]+`: Espacios en blanco y tabuladores para ser ignorados.
    *   `COMENTARIO` `#[^\n]*`: Comentarios de una sola línea al estilo Python, que comienzan con `#` y abarcan todo el texto hasta el final de la línea.

### Sección 2: Reglas de Traducción (Acciones)
Ubicada entre las marcas `%%` y `%%`. Contiene pares de la forma `Patrón { Acción }`.
Cuando el analizador léxico lee el archivo de entrada y encuentra un texto (lexema) que coincide con un patrón determinado, ejecuta el bloque de código C asociado entre llaves `{}`.
*   En este analizador, los tokens que coinciden imprimen su información a la salida estándar en formato tabular (`TOKEN\tlexema\tlinea\n`) mediante `printf`.
*   Los elementos a ignorar tienen bloques vacíos o comentarios C en sus acciones (ej. `{ESPACIOS} { /* ignorar */ }`).
*   La regla final de fallo (`.`) captura cualquier carácter no reconocido previamente y detiene el proceso con un código de error explícito.

### Sección 3: Funciones Auxiliares (Código de Usuario C)
Ubicada al final, después de la segunda marca `%%`.
Esta sección se copia directamente al final del archivo `lex.yy.c`. Aquí definimos la función `yywrap()` que simplemente retorna 1 (confirmando que al terminar el archivo fuente no hay más archivos a procesar), lo que da compatibilidad universal al analizador independientemente de la versión de Flex o de las opciones de enlace.

---

## 2. Resolución de Ambigüedades en Flex

Cuando un archivo fuente contiene un fragmento de texto que puede coincidir con múltiples reglas en la sección de especificación, Flex utiliza dos leyes fundamentales de resolución de conflictos basadas en la teoría de autómatas:

### 1. La Ley del "Longest Match" (Coincidencia más larga)
Flex siempre prefiere el patrón que consuma la mayor cantidad de caracteres del flujo de entrada.
*   *Ejemplo:* Si tenemos las reglas para `<=` (operador compuesto) y `<` (operador simple), y la entrada es `<=`, Flex podría hacer coincidir el carácter `<` individualmente o la pareja `<=`. Al aplicar la ley de coincidencia más larga, prefiere `<=` porque consume dos caracteres en lugar de uno.
*   *Ejemplo 2:* Si el lexema es `define`, Flex no reconocerá `def` como palabra reservada seguida de `ine` como identificador. Preferirá reconocer toda la cadena `define` completa como un único `IDENTIFICADOR` porque es más larga.

### 2. La Ley de la "Primera Regla" (Precedencia por orden de declaración)
Si dos patrones diferentes coinciden con **exactamente el mismo número de caracteres**, Flex resolverá el conflicto eligiendo el patrón que aparezca **primero** en el archivo `.l`.
*   *Caso Crítico (Palabras Reservadas vs. Identificadores):* La entrada `if` coincide tanto con la palabra reservada `"if"` como con el patrón de `{IDENT}`. Ambos consumen 2 caracteres. Al colocar la palabra reservada `"if"` **antes** de `{IDENT}` en la sección de reglas, garantizamos que se identifique como el token `PR_IF` y no como `IDENTIFICADOR`.
*   *Caso Crítico (Operadores Compuestos vs. Simples):* Si tuviéramos un operador compuesto como `:=` que coincidiera en longitud con otros caracteres combinados de manera extraña, su colocación previa a los simples evita la fragmentación del análisis léxico.

---

## 3. Conteo de Líneas y Manejo del Salto de Línea Windows vs. Linux

El control del número de línea es fundamental para poder reportar la ubicación exacta de los errores léxicos al desarrollador.

```lex
\n          { linea++; }
\r          { /* Ignorar */ }
```

### El Desafío Cross-Platform: CRLF vs. LF
*   **Linux/WSL:** Utiliza caracteres de salto de línea individuales `\n` (Line Feed, LF).
*   **Windows nativo:** Utiliza la combinación `\r\n` (Carriage Return + Line Feed, CRLF).

Si no manejamos explícitamente el retorno de carro (`\r`), la regla de fallo `.` (el punto coincide con cualquier carácter excepto `\n`) detectará el carácter invisible `\r` al final de cada línea en archivos editados bajo Windows y producirá un **error léxico falso positivo** insalvable.

**Nuestra Solución:**
Creamos una regla específica para `\r` cuyo cuerpo está vacío `{ /* Ignorar */ }`. Esto consume de forma segura y descarta el retorno de carro en Windows, permitiendo que la regla `\n` incremente correctamente la variable global `linea` para ambos sistemas operativos sin alterar el flujo lógico.
