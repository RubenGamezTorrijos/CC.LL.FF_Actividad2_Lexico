@echo off
rem Script de ejecucion de pruebas en Windows con soporte de fallback inteligente a WSL2
rem Desarrollado por Antigravity (Version ASCII segura)

setlocal enabledelayedexpansion

echo =========================================================
echo === EJECUCION DE PRUEBAS AUTOMATIZADAS EN WINDOWS / WSL ===
echo =========================================================

rem Directorios del proyecto
set "SCRIPT_DIR=%~dp0"
set "PROJECT_DIR=%SCRIPT_DIR%.."
set "PRUEBAS_DIR=%PROJECT_DIR%\pruebas"
set "SRC_DIR=%PROJECT_DIR%\src"

rem Caso 1: Se dispone de ejecutable nativo de Windows (analizador.exe)
if exist "%SRC_DIR%\analizador.exe" (
    echo [NATIVO] Se ha detectado ejecutable nativo Windows. Ejecutando pruebas nativas...
    set "EXE_PATH=%SRC_DIR%\analizador.exe"
    goto run_native
)

rem Caso 2: Se dispone de ejecutable de WSL (analizador)
if exist "%SRC_DIR%\analizador" (
    echo [WSL] No hay ejecutable de Windows, pero se ha detectado binario de WSL.
    echo [WSL] Redirigiendo ejecucion de tests a WSL de forma transparente...
    goto run_wsl
)

echo [ERROR] No se encontro ningun ejecutable del analizador (ni nativo Windows ni WSL).
echo Por favor, compila el proyecto primero ejecutando 'build_windows.bat'.
exit /b 1

:run_native
set "ALL_PASSED=1"

for %%F in ("%PRUEBAS_DIR%\test*.pys") do (
    set "FILE_PATH=%%F"
    set "BASE_NAME=%%~nF"
    set "EXPECTED_OUT=%PRUEBAS_DIR%\!BASE_NAME!.out"
    set "TEMP_OUT=%PRUEBAS_DIR%\!BASE_NAME!_actual.tmp"
    
    echo ---------------------------------------------------------
    echo Test: !BASE_NAME!.pys
    
    if not exist "!EXPECTED_OUT!" (
        echo [ADVERTENCIA] No existe el archivo esperado '!EXPECTED_OUT!'. Saltando test...
        continue
    )
    
    rem Ejecutar capturando salida y errores
    "!EXE_PATH!" "!FILE_PATH!" > "!TEMP_OUT!" 2>&1
    set "EXIT_CODE=!errorlevel!"
    
    rem Evaluar si es un test de error (contiene "error" en el nombre)
    echo !BASE_NAME! | findstr /I "error" >nul
    if !errorlevel! equ 0 (
        if !EXIT_CODE! neq 1 (
            echo [FAIL] El test con error '!BASE_NAME!' devolvio codigo !EXIT_CODE! (se esperaba 1).
            set "ALL_PASSED=0"
            del "!TEMP_OUT!" >nul 2>&1
            continue
        )
    ) else (
        if !EXIT_CODE! neq 0 (
            echo [FAIL] El test correcto '!BASE_NAME!' fallo con codigo !EXIT_CODE! (se esperaba 0).
            set "ALL_PASSED=0"
            del "!TEMP_OUT!" >nul 2>&1
            continue
        )
    )
    
    rem Comparar la salida esperada y la real omitiendo espacios en blanco (FC /W)
    fc /W "!EXPECTED_OUT!" "!TEMP_OUT!" >nul 2>&1
    if !errorlevel! equ 0 (
        echo [PASS] La salida coincide exactamente.
    ) else (
        echo [FAIL] Se encontraron diferencias logicas en la salida.
        echo ---- DIFERENCIAS (Esperado vs Real) ----
        fc /W "!EXPECTED_OUT!" "!TEMP_OUT!"
        set "ALL_PASSED=0"
    )
    
    del "!TEMP_OUT!" >nul 2>&1
)

echo =========================================================
if !ALL_PASSED! equ 1 (
    echo [EXITO] TODAS LAS PRUEBAS NATIVAS HAN PASADO CON EXITO (PASS)
    exit /b 0
) else (
    echo [ADVERTENCIA] Se han encontrado fallos en los tests. Revisa la salida de consola.
    exit /b 1
)

:run_wsl
cd /d "%SCRIPT_DIR%"
wsl bash -c "tr -d '\r' < ./run_tests_wsl.sh > ./run_tests_wsl_linux.sh && chmod +x ./run_tests_wsl_linux.sh && ./run_tests_wsl_linux.sh && rm -f ./run_tests_wsl_linux.sh"
exit /b !errorlevel!

:fin
cd /d "%SCRIPT_DIR%"
endlocal
