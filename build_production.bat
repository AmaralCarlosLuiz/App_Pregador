@echo off
chcp 65001 >nul
title Pregador Pro - Build de Produção Web Nativo Ultra-Rápido

echo ============================================================================
echo   PREGADOR PRO - EMPACOTAMENTO WEB ONLINE NATIVO (PWA + OFFLINE-FIRST)
echo   Desenvolvido por Carlos Luiz Amaral
echo ============================================================================
echo.

if not exist "webapp\index.html" (
    echo [ERRO] Pasta webapp\ nao encontrada.
    pause
    exit /b 1
)

echo [1/3] Preparando diretorio de distribuicao build\web...
if exist "build\web" rmdir /s /q "build\web"
mkdir "build\web" >nul 2>&1

echo [2/3] Copiando aplicacao web nativa (HTML5 / CSS3 / JS + 150 Modelos + 6 Biblias)...
xcopy "webapp\*" "build\web\" /E /I /Y >nul
if exist "instaladores_ios\Pregador_Pro_iOS_iPadOS.mobileconfig" (
    copy /y "instaladores_ios\Pregador_Pro_iOS_iPadOS.mobileconfig" "build\web\Pregador_Pro.mobileconfig" >nul
)

echo [3/3] Validando integridade dos arquivos...
if not exist "build\web\app.js" (
    echo [ERRO] Falha ao empacotar build\web.
    pause
    exit /b 1
)

echo.
echo ============================================================================
echo   BUILD CONCLUIDO EM SEGUNDOS! Artefatos prontos em: build\web\
echo ============================================================================
echo.
exit /b 0
