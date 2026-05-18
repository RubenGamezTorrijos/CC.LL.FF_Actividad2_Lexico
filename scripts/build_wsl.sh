#!/bin/bash
# Script de compilación del analizador léxico en WSL2/Linux
# Desarrollado por Antigravity

# Forzar salida en caso de error en cualquier comando
set -e

echo "========================================================="
echo "=== COMPILACIÓN DEL ANALIZADOR LÉXICO EN WSL2 / LINUX ==="
echo "========================================================="

# Directorio donde se encuentra el script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$( dirname "$SCRIPT_DIR" )"

cd "$PROJECT_DIR/src"

echo "1. Comprobando herramientas instaladas..."
if ! command -v flex &> /dev/null; then
    echo "❌ ERROR: Flex no está instalado en tu distribución de WSL2."
    echo "Sugerencia: Ejecuta 'sudo apt update && sudo apt install flex' en tu terminal WSL."
    exit 1
fi

if ! command -v gcc &> /dev/null; then
    echo "❌ ERROR: GCC no está instalado en tu distribución de WSL2."
    echo "Sugerencia: Ejecuta 'sudo apt update && sudo apt install build-essential' en tu terminal WSL."
    exit 1
fi

echo "   [OK] Flex y GCC detectados."

echo "2. Generando analizador léxico con Flex..."
flex analizador.l

echo "3. Compilando el código generado con GCC..."
gcc lex.yy.c main.c -o analizador

echo "========================================================="
echo "✅ ¡COMPILACIÓN COMPLETADA CON ÉXITO!"
echo "Ubicación del binario: src/analizador"
echo "========================================================="
