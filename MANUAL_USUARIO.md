# Manual del Usuario

Este manual describe paso a paso cómo preparar tu entorno, compilar y ejecutar el analizador léxico en múltiples plataformas (Windows nativo y WSL2/Linux), así como el formato de salida y el manejo de errores léxicos.

---

## 1. Requisitos Previos del Sistema

El proyecto está diseñado para funcionar tanto en Windows nativo como en WSL2 (Subsistema de Windows para Linux). Necesitas tener disponibles las siguientes herramientas en tu entorno preferido:

### Opción A: Entorno WSL2 / Linux (Recomendado)
*   **Flex:** Generador de analizadores léxicos.
*   **GCC:** Compilador de C.
*   **Make/Diff:** Herramientas de automatización de pruebas.

*Instalación rápida en terminal Ubuntu/Debian:*
```bash
sudo apt update
sudo apt install -y flex gcc build-essential
```

### Opción B: Entorno Windows Nativo (CMD o PowerShell)
*   **MinGW / MSYS2:** Proporciona `gcc.exe` para Windows.
*   **WinFlexBison:** Proporciona `flex.exe` nativo para Windows.
*   *Nota:* Si estas herramientas no se encuentran en tu PATH de Windows, los scripts `.bat` del proyecto detectarán su ausencia y delegarán automáticamente la ejecución a WSL2 de manera transparente.

---

## 2. Estructura de Carpetas del Proyecto

```
.
├── src/                          # Código fuente
│   ├── analizador.l              # Especificación del analizador en Flex
│   └── main.c                    # Punto de entrada en C (función main)
├── pruebas/                      # Casos de prueba (.pys) y salidas esperadas (.out)
│   ├── testA_correcto.pys        # Código fuente de prueba válido
│   ├── testA_correcto.out        # Tokenización esperada del test correcto
│   ├── testB_error.pys           # Código fuente con un error léxico
│   └── testB_error.out           # Tokenización parcial y mensaje de error esperado
├── scripts/                      # Scripts de automatización
│   ├── build_wsl.sh              # Script de compilación para WSL2/Linux
│   ├── run_tests_wsl.sh          # Validador de pruebas para WSL2/Linux
│   ├── build_windows.bat         # Script de compilación híbrido para Windows
│   ├── run_tests_windows.bat     # Validador de pruebas híbrido para Windows
│   ├── init_git.sh               # Script de inicialización de Git para WSL/Linux
│   └── init_git.bat              # Script de inicialización de Git para Windows
├── .gitignore                    # Archivo de exclusiones de Git
├── DOC_EXPPLICACION_PARTES.md    # Explicación teórica y técnica del analizador
├── MANUAL_USUARIO.md             # Este manual de usuario
└── COMENTARIOS_CONCLUSIONES.md   # Conclusiones del desarrollo académico
```

---

## 3. Compilación y Ejecución en Windows y WSL2

Hemos desarrollado scripts inteligentes para que no tengas que preocuparte de los comandos de compilación.

### En Windows (Nativos y con Fallback automático a WSL)
Abre una consola (`cmd` o `PowerShell`) en la carpeta `scripts/` de la entrega:

1.  **Compilar el proyecto:**
    ```cmd
    build_windows.bat
    ```
    *   *¿Qué hace?* Busca herramientas nativas de Windows en tu PATH. Si las tiene, genera `src\analizador.exe`. Si no las tiene, llama automáticamente a la terminal de WSL2 para compilar el binario `src/analizador` en Linux.

2.  **Ejecutar los Tests automatizados:**
    ```cmd
    run_tests_windows.bat
    ```
    *   *¿Qué hace?* Detecta qué binario se ha compilado (Windows o Linux/WSL) y ejecuta los tests de la carpeta `pruebas/`. Compara las salidas de forma automatizada mediante herramientas de diferencia (`diff` en Linux, `fc` en Windows) e indica con colores y mensajes claros si las pruebas pasaron (`PASS`) o fallaron (`FAIL`).

---

### En WSL2 / Linux Directo
Abre la terminal de Linux en la carpeta de la entrega y haz ejecutables los scripts:
```bash
chmod +x scripts/*.sh
```

1.  **Compilar el proyecto:**
    ```bash
    ./scripts/build_wsl.sh
    ```
    *   Generará el archivo compilado `src/analizador`.

2.  **Ejecutar los Tests:**
    ```bash
    ./scripts/run_tests_wsl.sh
    ```
    *   Ejecuta todos los archivos `.pys` de la carpeta `pruebas/` y compara su salida con sus correspondientes `.out` usando `diff`.

---

## 4. Ejecución Manual del Analizador

Si deseas procesar un archivo personalizado sin los scripts automatizados, puedes invocar al ejecutable pasándole como argumento la ruta del archivo de entrada:

### Ejecución manual en Windows:
```cmd
src\analizador.exe pruebas\testA_correcto.pys
```

### Ejecución manual en WSL2 / Linux:
```bash
./src/analizador pruebas/testA_correcto.pys
```

---

## 5. Formato de Salida del Analizador

El analizador léxico procesa la entrada secuencialmente. Cada token identificado se imprime en una línea de texto individual en la consola con el siguiente formato estricto:

```
TOKEN   lexema  nº_de_línea
```
*Los campos están separados exactamente por tabulaciones (`\t`).*

### Ejemplo de salida parcial para el código `x = 10` en la línea 8:
```
IDENTIFICADOR	x	8
OP_ASIGNACION	=	8
NUMERO	10	8
```

---

## 6. Manejo de Errores Léxicos

Si el analizador léxico encuentra un carácter no definido en la gramática del mini-lenguaje (como por ejemplo `@`, `$` o `?`), la ejecución:
1.  Imprime inmediatamente un mensaje de error léxico con el siguiente formato exacto:
    ```
    ERROR LÉXICO: carácter/símbolo no reconocido '<lexema>' en línea <N>
    ```
2.  **Detiene la ejecución del programa de inmediato** finalizando con un código de salida `1` (`exit(1)`). Esto previene que se consuman recursos en fases de compilación posteriores si el código fuente es incorrecto.

### Ejemplo de salida para `y = @20` en la línea 3:
```
IDENTIFICADOR	y	3
OP_ASIGNACION	=	3
ERROR LÉXICO: carácter/símbolo no reconocido '@' en línea 3
```
*(Y el programa termina indicando error en el flujo de ejecución).*

---

## 🔄 Control de Versiones con Git

### Inicialización local
```bash
# WSL/Linux
cd scripts && bash init_git.sh

# Windows CMD
cd scripts && init_git.bat
```

### Subir a GitHub
Crea un nuevo repositorio en GitHub (público o privado).
Copia la URL HTTPS o SSH que te proporciona GitHub.
Ejecuta en la raíz del proyecto:

```bash
git remote add origin https://github.com/RubenGamezTorrijos/CC.LL.FF_Actividad2_Lexico.git
git push -u origin main
```

### Estructura recomendada de commits
*   `feat: implementación inicial del analizador léxico`
*   `test: añade batería de pruebas tipo A y B`
*   `docs: completa documentación y manual de usuario`
*   `fix: corrige manejo de saltos de línea en Windows`

