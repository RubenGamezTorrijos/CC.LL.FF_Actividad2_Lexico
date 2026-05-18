


@echo off
REM Inicializa repo git y prepara primer commit (Windows)

cd /d "%~dp0.."

if not exist ".git" (
    git init
    echo ✅ Repositorio Git inicializado
)

git branch -M main 2>nul || rem

if not exist ".gitignore" (
    type nul > .gitignore
)

findstr /C:"lex.yy.c" .gitignore >nul 2>&1
if errorlevel 1 (
    echo # Flex/Lex generados>> .gitignore
    echo lex.yy.c>> .gitignore
    echo lex.yy.*>> .gitignore
    echo src/analizador>> .gitignore
    echo src/analizador.exe>> .gitignore
    echo *.o>> .gitignore
    echo *.a>> .gitignore
    echo *.so>> .gitignore
    echo .DS_Store>> .gitignore
    echo pruebas/*.out>> .gitignore
    echo ✅ .gitignore actualizado
)

echo 📋 Siguientes pasos manuales:
echo   1. git add .
echo   2. git commit -m "feat: entrega actividad 2 - analizador léxico con Flex"
echo   3. Crear repo en GitHub y copiar URL
echo   4. git remote add origin ^<URL^>
echo   5. git push -u origin main
pause
