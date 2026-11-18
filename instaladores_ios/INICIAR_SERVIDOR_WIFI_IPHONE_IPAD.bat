@echo off
chcp 65001 >nul
cd /d "%~dp0.."
title Pregador Pro - Servidor de Instalacao Wi-Fi para iPhone e iPad
echo ============================================================================
echo   PREGADOR PRO - INSTALACAO IMEDIATA NO IPHONE E IPAD (Wi-Fi Local)
echo   Desenvolvido por Carlos Luiz Amaral
echo ============================================================================
echo.
echo [1/2] Descobrindo o endereco IP local do seu computador no Wi-Fi...
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /R /C:"IPv4"') do (
    for /f "tokens=*" %%b in ("%%a") do (
        echo   App (Safari ^> Adicionar a Tela de Inicio^): http://%%b:8080/App_Pregador/
        echo   Instalador .mobileconfig (Safari^):          http://%%b:8080/App_Pregador/Pregador_Pro.mobileconfig
    )
)
echo.
if exist "build\web\index.html" (
    where python >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        echo [2/2] Servindo build de producao ^(build\web^) na porta 8080...
        echo   Pressione Ctrl+C para encerrar o servidor.
        echo.
        python -c "import http.server, os; os.chdir('build/web'); exec('''\nclass H(http.server.SimpleHTTPRequestHandler):\n    extensions_map = {**http.server.SimpleHTTPRequestHandler.extensions_map, '.mobileconfig': 'application/x-apple-aspen-config', '.wasm': 'application/wasm', '.js': 'application/javascript'}\n    def translate_path(self, path):\n        p = path.split('?',1)[0].split('#',1)[0]\n        if p.startswith('/App_Pregador/'): path = '/' + p[len('/App_Pregador/'):]\n        elif p == '/App_Pregador': path = '/'\n        return super().translate_path(path)\n    def do_GET(self):\n        if self.path == '/':\n            self.send_response(302); self.send_header('Location', '/App_Pregador/'); self.end_headers(); return\n        super().do_GET()\nhttp.server.ThreadingHTTPServer(('0.0.0.0', 8080), H).serve_forever()\n''')"
        pause
        exit /b 0
    )
)

echo [2/2] Iniciando servidor Flutter otimizado na porta 8080...
echo   No iPhone/iPad (Safari), toque em Compartilhar [icone seta p/ cima]
echo   e selecione "Adicionar a Tela de Inicio" para instalar o App!
echo.
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080 --release
pause
