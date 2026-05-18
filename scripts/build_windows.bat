

@echo off
rem Script de compilacion inteligente para Windows (CMD/PowerShell)
rem Desarrollado por Antigravity (Versión ASCII segura)

setlocal enabledelayedexpansion

echo =========================================================
echo === COMPILACION DEL ANALIZADOR LEXICO EN WINDOWS / WSL ===
echo =========================================================

rem Directorios del proyecto
set "SCRIPT_DIR=%~dp0"
set "PROJECT_DIR=%SCRIPT_DIR%.."
set "SRC_DIR=%PROJECT_DIR%\src"

rem Inicializar indicadores de disponibilidad de herramientas nativas
set "HAS_FLEX=0"
set "HAS_GCC=0"

rem Verificar la presencia de Flex en Windows
where flex >nul 2>&1
if !errorlevel! equ 0 set "HAS_FLEX=1"

rem Verificar la presencia de GCC en Windows
where gcc >nul 2>&1
if !errorlevel! equ 0 set "HAS_GCC=1"

rem Caso 1: Compilacion nativa en Windows disponible
if !HAS_FLEX! equ 1 if !HAS_GCC! equ 1 (
    echo [NATIVO] Se han detectado Flex y GCC de forma nativa en Windows.
    echo [NATIVO] Procediendo con la compilacion nativa en Windows...
    
    cd /d "%SRC_DIR%"
    
    echo [NATIVO] 1. Ejecutando Flex...
    flex analizador.l
    if !errorlevel! neq 0 (
        echo [ERROR] [NATIVO] Error al procesar analizador.l con Flex.
        goto try_wsl
    )
    
    echo [NATIVO] 2. Compilando lex.yy.c y main.c con GCC...
    gcc lex.yy.c main.c -o analizador.exe
    if !errorlevel! neq 0 (
        echo [ERROR] [NATIVO] Error al compilar con GCC.
        goto try_wsl
    )
    
    echo =========================================================
    echo [EXITO] Compilacion nativa en Windows completada con exito.
    echo Ubicacion del ejecutable: src\analizador.exe
    echo =========================================================
    goto fin
)

rem Caso 2: Fallback a WSL2 si faltan herramientas nativas
:try_wsl
echo [FALLBACK] Faltan herramientas de compilacion nativas en Windows (flex/gcc).
echo [FALLBACK] Se activara el redireccionamiento automatico a WSL2 (Ubuntu/Linux).

rem Verificar si WSL2 esta instalado
where wsl >nul 2>&1
if !errorlevel! neq 0 (
    echo [ERROR DE CONFIGURACION] No se encontro 'wsl.exe' en tu sistema ni herramientas nativas.
    echo Asegurate de tener instalado WSL2 o las herramientas de WinFlexBison y MinGW en Windows.
    exit /b 1
)

echo [WSL] WSL2 detectado. Ejecutando build_wsl.sh de forma remota...

rem Ir al directorio del script para ejecucion en ruta relativa
cd /d "%SCRIPT_DIR%"

rem Ejecutar el script convirtiendo los saltos de linea de Windows a Linux de forma local en la carpeta scripts
wsl bash -c "tr -d '\r' < ./build_wsl.sh > ./build_wsl_linux.sh && chmod +x ./build_wsl_linux.sh && ./build_wsl_linux.sh && rm -f ./build_wsl_linux.sh"

if !errorlevel! neq 0 (
    echo [ERROR] Fallo la compilacion en WSL2. Comprueba tu distribucion.
    exit /b 1
)

echo =========================================================
echo [EXITO] Compilacion via WSL2 completada con exito.
echo Ubicacion del ejecutable en Linux: src/analizador
echo =========================================================
goto fin

:fin
cd /d "%SCRIPT_DIR%"
endlocal
