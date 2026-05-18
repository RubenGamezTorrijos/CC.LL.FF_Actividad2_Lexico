#!/bin/bash
# Script de pruebas automatizadas en WSL2/Linux con validación por diff
# Desarrollado por Antigravity

echo "========================================================="
echo "=== EJECUCIÓN DE PRUEBAS AUTOMATIZADAS EN WSL2 / LINUX ==="
echo "========================================================="

# Directorios de interés
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$( dirname "$SCRIPT_DIR" )"
ANALIZADOR="$PROJECT_DIR/src/analizador"
PRUEBAS_DIR="$PROJECT_DIR/pruebas"

# Verificar existencia del ejecutable
if [ ! -f "$ANALIZADOR" ]; then
    echo "❌ ERROR: No se encontró el ejecutable '$ANALIZADOR'."
    echo "Por favor, ejecuta primero el script 'build_wsl.sh' para compilar el proyecto."
    exit 1
fi

ALL_PASSED=true

# Iterar sobre todos los ficheros .pys en la carpeta de pruebas
for test_file in "$PRUEBAS_DIR"/test*.pys; do
    # Obtener el nombre del test
    base_name=$(basename "$test_file" .pys)
    expected_out="$PRUEBAS_DIR/${base_name}.out"
    temp_out="$PRUEBAS_DIR/${base_name}_actual.tmp"
    
    echo "---------------------------------------------------------"
    echo "Test: $base_name.pys"
    
    # Comprobar si existe el fichero de salida esperado
    if [ ! -f "$expected_out" ]; then
        echo "⚠️  ADVERTENCIA: No existe el fichero esperado '$expected_out'. Saltando test..."
        continue
    fi

    # Ejecutar y capturar salida estándar y de error juntas
    "$ANALIZADOR" "$test_file" > "$temp_out" 2>&1
    exit_code=$?
    
    # Comprobar si el test debe dar error o es correcto
    if [[ "$base_name" == *"error"* ]]; then
        # Test con error esperado (debe dar exit_code 1)
        if [ $exit_code -ne 1 ]; then
            echo "❌ FAIL: El test con error '$base_name' retornó código de salida $exit_code (se esperaba 1)."
            ALL_PASSED=false
            rm -f "$temp_out"
            continue
        fi
    else
        # Test correcto (debe dar exit_code 0)
        if [ $exit_code -ne 0 ]; then
            echo "❌ FAIL: El test correcto '$base_name' falló con código de salida $exit_code (se esperaba 0)."
            ALL_PASSED=false
            rm -f "$temp_out"
            continue
        fi
    fi
    
    # Comparar la salida con la esperada omitiendo saltos de línea Carriage Return (\r)
    # y comparando de forma estricta el resto del texto
    if diff -q -w "$expected_out" "$temp_out" > /dev/null; then
        echo "✅ PASS: La salida coincide exactamente con '$expected_out'."
    else
        echo "❌ FAIL: Se encontraron discrepancias lógicas."
        echo "---- DIFERENCIAS (Esperado vs Real) ----"
        diff -u "$expected_out" "$temp_out"
        ALL_PASSED=false
    fi
    
    # Limpiar el fichero temporal
    rm -f "$temp_out"
done

echo "========================================================="
if [ "$ALL_PASSED" = true ]; then
    echo "🎉 ¡FELICIDADES! TODAS LAS PRUEBAS HAN PASADO CON ÉXITO (PASS)."
    exit 0
else
    echo "⚠️  ATENCIÓN: Se han encontrado fallos en los tests. Revisa los logs anteriores."
    exit 1
fi
echo "========================================================="
