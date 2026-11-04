@echo off
chcp 65001 >nul
title Pregador Pro - Servidor de Instalacao Wi-Fi para iPhone e iPad
echo ============================================================================
echo   PREGADOR PRO - INSTALACAO IMEDIATA NO IPHONE 14 PRO MAX, IPHONE 12 E IPAD
echo   Desenvolvido por Carlos Luiz Amaral
echo ============================================================================
echo.
echo [1/2] Descobrindo o endereco IP local do seu computador no Wi-Fi...
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /R /C:"IPv4"') do (
    echo   👉 Abra o Safari do seu iPhone / iPad no endereco: http:%%a:8080
)
echo.
echo [2/2] Iniciando servidor otimizado na porta 8080...
echo   No iPhone/iPad (Safari), toque em Compartilhar [icone seta p/ cima]
echo   e selecione "Adicionar a Tela de Inicio" para instalar o App!
echo.
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080 --release
pause
