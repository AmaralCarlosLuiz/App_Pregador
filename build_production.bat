@echo off
chcp 65001 >nul
title Pregador Pro - Build de Produção Deterministico

echo ============================================================================
echo   PREGADOR PRO - BUILD DETERMINÍSTICO DE PRODUÇÃO
echo   Desenvolvido por Carlos Luiz Amaral
echo ============================================================================
echo.

echo [1/4] Desativando telemetria e bloqueios de prompt do Flutter...
call flutter config --no-analytics >nul 2>&1

echo [2/4] Verificando dependências do projeto...
call flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo [ERRO] Falha ao baixar dependências do pubspec.yaml.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo [3/4] Compilando Web / PWA de Produção (Base HREF: /App_Pregador/)...
call flutter build web --release --base-href "/App_Pregador/"
if %ERRORLEVEL% NEQ 0 (
    echo [ERRO] Falha na compilação do Flutter Web.
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo [4/4] Empacotando instalador mobileconfig no build de distribuição...
if exist "instaladores_ios\Pregador_Pro_iOS_iPadOS.mobileconfig" (
    copy /y "instaladores_ios\Pregador_Pro_iOS_iPadOS.mobileconfig" "build\web\Pregador_Pro.mobileconfig" >nul
)

echo.
echo ============================================================================
echo   BUILD CONCLUÍDO COM SUCESSO!
echo   Artefatos prontos em: build/web/
echo ============================================================================
echo.
exit /b 0
