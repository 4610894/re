@echo off
setlocal

:: Configuracoes (ajuste apenas o nome do arquivo HTML, se necessario)
set "PASTA_DASHBOARD=%USERPROFILE%\Saude_da_Operacao"
set "ARQUIVO_HTML=dashboard.html"

:: Valida se a pasta e o HTML existem no caminho absoluto
if not exist "%PASTA_DASHBOARD%" (
    echo [ERRO] Pasta nao encontrada: %PASTA_DASHBOARD%
    echo Execute primeiro o script de instalacao.
    pause
    exit /b 1
)

if not exist "%PASTA_DASHBOARD%\%ARQUIVO_HTML%" (
    echo [ERRO] Arquivo "%ARQUIVO_HTML%" nao encontrado em %PASTA_DASHBOARD%.
    pause
    exit /b 1
)

:: Detecta o executavel real do Python
set "PY_CMD="
python --version >nul 2>&1 && set "PY_CMD=python"
if not defined PY_CMD (
    py --version >nul 2>&1 && set "PY_CMD=py"
)
if not defined PY_CMD (
    echo [ERRO] Python nao encontrado nesta maquina.
    pause
    exit /b 1
)

:: Solicita ao Windows uma porta aleatoria livre via Python (bind na porta 0)
set "PORTA="
for /f "usebackq delims=" %%p in (`%PY_CMD% -c "import socket; s=socket.socket(); s.bind(('127.0.0.1', 0)); print(s.getsockname()[1]); s.close()"`) do set "PORTA=%%p"

if not defined PORTA (
    echo [ERRO] Nao foi possivel obter uma porta livre.
    pause
    exit /b 1
)

echo ==================================================
echo   Dashboard - Saude da Operacao
echo ==================================================
echo.
echo Servidor ativo em: http://127.0.0.1:%PORTA%/%ARQUIVO_HTML%
echo Mantenha esta janela aberta enquanto usa o dashboard.
echo Feche esta janela para encerrar o servidor.
echo.

:: Aguarda ~2 segundos em paralelo e abre o navegador padrao na porta sorteada
start /b cmd /c "ping -n 3 127.0.0.1 >nul & start http://127.0.0.1:%PORTA%/%ARQUIVO_HTML%"

:: Sobe o servidor preso ao caminho absoluto na porta aleatoria obtida
%PY_CMD% -m http.server %PORTA% --bind 127.0.0.1 --directory "%PASTA_DASHBOARD%"
