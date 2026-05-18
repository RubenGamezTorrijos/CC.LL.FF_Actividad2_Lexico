# Mini-Python Lexer v.1.0.0
## Analizador Léxico en Flex para Mini-Python - Compiladores y Lenguajes Formales

[![Status](https://img.shields.io/badge/Status-Academic--Ready-success.svg)](#)
[![Language](https://img.shields.io/badge/Language-Flex%20%2F%20C-blue.svg)](#)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%2F%20WSL2%20%2F%20Linux-orange.svg)](#)

Este proyecto implementa un analizador léxico completo y profesional desarrollado en **Flex (Lex) y C**. Procesa ficheros con código de un mini-lenguaje inspirado en la sintaxis de Python, reconociendo de manera precisa componentes léxicos (palabras reservadas, identificadores, números, operadores compuestos y simples), omitiendo espacios y comentarios, gestionando de forma robusta la compatibilidad multiplataforma de saltos de línea (Windows CRLF y Linux LF) y controlando errores léxicos con parada inmediata ante caracteres ilegales.

---

## 🚀 Características (Novedades v.1.0.0)

*   **Especificación Léxica de Flex Profesional:** Reglas gramaticales ordenadas estratégicamente para respetar la precedencia correcta (operadores compuestos antes que simples, y palabras reservadas antes que identificadores).
*   **Mapeado de Tokens en Tabulaciones:** Salida estricta por consola formateada mediante tabulaciones en la estructura: `TOKEN\tlexema\tnº_de_línea`.
*   **Soporte Multiplataforma y Conteo CRLF Inteligente:** Regla de filtrado explícito para retornos de carro (`\r`) que previene falsos positivos de caracteres no reconocidos en archivos Windows, sumando líneas exclusivamente con `\n`.
*   **Punto de Entrada en C Robusto (`main.c`):** Validación segura de argumentos de línea de comandos, gestión de errores de apertura de ficheros con `perror` y redireccionamiento directo del puntero a `yyin`.
*   **Gestión de Errores Léxicos Críticos:** Detención inmediata de la ejecución (`exit(1)`) ante el primer símbolo ilegal (ej. `@`), imprimiendo con precisión: `ERROR LÉXICO: carácter/símbolo no reconocido '<lexema>' en línea <N>`.
*   **Batería de Pruebas Automatizada (Calidad Local):** Casos de prueba correctos (`testA_correcto`) y de error (`testB_error`) con verificación automática en base a sus salidas esperadas `.out` mediante comandos de diferencia (`diff` y `fc`).
*   **Automatización de Compilación Multiplataforma:** Scripts inteligentes `.bat` para Windows y `.sh` para Linux/WSL2. Los scripts de Windows detectan herramientas nativas y, en su ausencia, realizan fallback automático llamando transparentemente a WSL2.

---

## 📂 Estructura del Proyecto

El repositorio está organizado directamente en el directorio raíz con la siguiente estructura modular:

```text
.
├── src/                          # Código fuente del compilador
│   ├── analizador.l              # Especificación del analizador léxico en Flex
│   └── main.c                    # Punto de entrada en C (función main)
├── pruebas/                      # Casos de prueba (.pys) y salidas esperadas (.out)
│   ├── testA_correcto.pys        # Código fuente de prueba de mini-Python válido
│   ├── testA_correcto.out        # Tokenización de referencia esperada
│   ├── testB_error.pys           # Código fuente con carácter inválido (@)
│   └── testB_error.out           # Tokenización parcial y mensaje de error esperado
├── scripts/                      # Scripts de automatización y control de versiones
│   ├── build_wsl.sh              # Compilación directa en Linux/WSL2
│   ├── run_tests_wsl.sh          # Comprobación de pruebas automatizada en Linux/WSL2
│   ├── build_windows.bat         # Compilación híbrida para Windows (con fallback a WSL)
│   ├── run_tests_windows.bat     # Comprobación híbrida para Windows (con fallback a WSL)
│   ├── init_git.sh               # Inicializador de repositorio Git para Linux/WSL
│   └── init_git.bat              # Inicializador de repositorio Git para Windows
├── .gitignore                    # Archivo de exclusiones de archivos generados y temporales
├── DOC_EXPLICACION_PARTES.md    # Explicación técnica y teórica detallada sobre Flex
├── MANUAL_USUARIO.md             # Guía paso a paso de uso, instalación y comandos
├── COMENTARIOS_CONCLUSIONES.md   # Conclusiones académicas, retos técnicos y áreas de mejora
└── README.md                     # Documentación principal del proyecto (este archivo)
```

---

## 🛠️ Requisitos e Instalación

### Requisitos Previos

*   **Linux / WSL2 (Recomendado):** Distribución basada en Ubuntu/Debian con herramientas de compilación.
    *Instalación rápida de dependencias:*
    ```bash
    sudo apt update && sudo apt install -y flex gcc build-essential
    ```
*   **Windows Nativo:** Compilador `gcc` (de MinGW/MSYS2) y generador `flex` (de WinFlexBison).
    *Nota: Si ejecutas los scripts de Windows sin tener estas herramientas nativas instaladas, el sistema redirigirá de manera transparente la compilación a tu distribución de WSL2.*

### Implementación y Testeo Rápido

*   **En Windows (CMD o PowerShell):**
    Abre tu consola en la carpeta `scripts/` y ejecuta:
    ```cmd
    build_windows.bat
    run_tests_windows.bat
    ```
*   **En Linux o terminal WSL2 (Bash):**
    Otorga permisos de ejecución a los scripts y ejecútalos desde la raíz:
    ```bash
    chmod +x scripts/*.sh
    ./scripts/build_wsl.sh
    ./scripts/run_tests_wsl.sh
    ```

---

## 🖥️ Guía de Uso del Analizador

Si deseas compilar o procesar un archivo fuente de manera manual, puedes invocar directamente el binario generado pasándole como argumento la ruta del archivo de entrada:

### Compilación Manual:
*   **Linux / WSL:** `flex src/analizador.l && gcc lex.yy.c src/main.c -o src/analizador`
*   **Windows (nativo):** `flex src/analizador.l && gcc lex.yy.c src/main.c -o src/analizador.exe`

### Ejecución Manual:
*   **En Windows CMD:**
    ```cmd
    src\analizador.exe pruebas\testA_correcto.pys
    ```
*   **En WSL2 / Linux:**
    ```bash
    ./src/analizador pruebas/testA_correcto.pys
    ```

### Formato de Salida:
El analizador devolverá por consola las líneas de correspondencia de tokens siguiendo la especificación formal:
```text
IDENTIFICADOR	x	8
OP_ASIGNACION	=	8
NUMERO	10	8
IDENTIFICADOR	y	9
OP_ASIGNACION	=	9
NUMERO	20	9
```

---

## 📖 Análisis de la Actividad 2 (Compiladores y Lenguajes Formales)

El objetivo central de la práctica es el diseño e implementación del **Front-End de un traductor de lenguajes**, concretamente el **Analizador Léxico**. Durante este desarrollo, se resuelven y demuestran los siguientes principios de la teoría de lenguajes formales y compiladores:

1.  **Regla de Coincidencia Más Larga (Longest Match):** Flex prioriza el patrón que consuma la mayor cantidad de caracteres. Por ello, operadores compuestos como el operador de asignación compuesto `:=` se tokenizan como `OP_ASIGNACION_COMP` de forma unificada, en lugar de dividirse en `:` y `=`.
2.  **Prioridad de Primera Regla (First Rule):** Ante coincidencias de igual longitud (ej. la palabra reservada `while` y un identificador genérico que empiece por `w`), Flex utiliza el orden físico en la especificación. Al colocar las palabras reservadas estrictamente arriba de los identificadores, se garantiza una clasificación correcta.
3.  **Arquitectura Acoplada y Manejo de Flujos:** El punto de entrada en C gestiona eficientemente el redireccionamiento a `yyin`, controlando mediante estados el ciclo de vida del analizador léxico (`yylex()`) hasta alcanzar el final del archivo (`EOF`) o detectar un carácter inválido.

---

## 👥 Créditos y Autoría

*   **Desarrollador:** Rubén Gámez Torrijos
*   **Asignatura:** Compiladores y Lenguajes Formales (CC.LL.FF.)
*   **Curso:** 2025/2026
*   **Grado:** Ingeniería Informática
*   **Universidad:** Universidad Europea de Madrid (UEM)

Este proyecto ha sido desarrollado como parte de la Actividad Obligatoria 2 para la asignatura de Computadores y Lenguajes Formales, sirviendo como una aplicación directa de la teoría de autómatas deterministas, expresiones regulares y construcción de compiladores modernos.
