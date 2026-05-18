#!/bin/bash
# Inicializa repo git y prepara primer commit

cd "$(dirname "$0")/.."

if [ ! -d ".git" ]; then
    git init
    echo "✅ Repositorio Git inicializado"
fi

git branch -M main 2>/dev/null || true

if ! grep -q "lex.yy.c" .gitignore 2>/dev/null; then
    cat << 'EOF' >> .gitignore
# Flex/Lex generados
lex.yy.c
lex.yy.*
src/analizador
src/analizador.exe
*.o
*.a
*.so
.DS_Store
pruebas/*.out
EOF
    echo "✅ .gitignore actualizado"
fi

echo "📋 Siguientes pasos manuales:"
echo "  1. git add ."
echo "  2. git commit -m \"feat: entrega actividad 2 - analizador léxico con Flex\""
echo "  3. Crear repo en GitHub y copiar URL"
echo "  4. git remote add origin <URL>"
echo "  5. git push -u origin main"
