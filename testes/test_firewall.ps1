<#
.SYNOPSIS
    Script de validação automatizada de regras de firewall para estações Windows.
    Disciplina: Redes de Computadores - IFPR (Projeto Celepar)
    Autores: Alexandre, Beatriz e Maurício
#>

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  TESTE AUTOMATIZADO DE FIREWALL - PROJETO CELEPAR (IFPR)  " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host ""

$ipConfig = Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -like "10.0.*" } | Select-Object -First 1
Write-Host "[*] IP Atual da Máquina de Teste: $($ipConfig.IPAddress)" -ForegroundColor Yellow
Write-Host ""

function Validar-Porta {
    param (
        [string]$Descricao,
        [string]$IP,
        [int]$Porta,
        [bool]$EsperadoPermitido
    )

    Write-Host "[-] Testando: $Descricao ($IP:$Porta)..." -NoNewline
    $resultado = Test-NetConnection -ComputerName $IP -Port $Porta -WarningAction SilentlyContinue -InformationLevel Quiet

    if ($resultado -eq $EsperadoPermitido) {
        if ($resultado) {
            Write-Host " [PASSOU - CONECTADO]" -ForegroundColor Green
        } else {
            Write-Host " [PASSOU - BLOQUEADO COM SUCESSO]" -ForegroundColor Green
        }
    } else {
        Write-Host " [FALHOU]" -ForegroundColor Red
        Write-Host "    -> Esperado: $(if($EsperadoPermitido){'Permitir'}else{'Bloquear'}), Obtido: $(if($resultado){'Conectado'}else{'Bloqueado'})" -ForegroundColor DarkYellow
    }
}

function Validar-Ping {
    param (
        [string]$Descricao,
        [string]$IP,
        [bool]$EsperadoPermitido
    )

    Write-Host "[-] Testando Ping: $Descricao ($IP)..." -NoNewline
    $resultado = Test-Connection -ComputerName $IP -Count 2 -Quiet

    if ($resultado -eq $EsperadoPermitido) {
        if ($resultado) {
            Write-Host " [PASSOU - RESPOSTA RECEBIDA]" -ForegroundColor Green
        } else {
            Write-Host " [PASSOU - DROPADO COM SUCESSO]" -ForegroundColor Green
        }
    } else {
        Write-Host " [FALHOU]" -ForegroundColor Red
        Write-Host "    -> Esperado: $(if($EsperadoPermitido){'Resposta'}else{'Drop'}), Obtido: $(if($resultado){'Respondeu'}else{'Sem resposta'})" -ForegroundColor DarkYellow
    }
}

Write-Host "--- TESTES DE REGRAS DE FIREWALL ---" -ForegroundColor Magenta

# Teste 1: Regra 4 - Estações para Servidores (Porta 445 SMB)
Validar-Porta -Descricao "Regra 4: Acesso ao Servidor de Arquivos (SMB 445)" -IP "10.0.20.5" -Porta 445 -EsperadoPermitido $true

# Teste 2: Regra 4 - Bloqueio de portas não autorizadas no servidor (Porta SSH 22)
Validar-Porta -Descricao "Regra 4: Bloqueio de porta nao autorizada no Servidor (SSH 22)" -IP "10.0.20.5" -Porta 22 -EsperadoPermitido $false

# Teste 3: Regra 5 - Bloqueio de acesso à rede de Gerência (10.0.10.1)
Validar-Ping -Descricao "Regra 5: Bloqueio de Ping para a Gerencia (10.0.10.1)" -IP "10.0.10.1" -EsperadoPermitido $false
Validar-Porta -Descricao "Regra 5: Bloqueio de Web Admin na Gerencia (Porta 80)" -IP "10.0.10.1" -Porta 80 -EsperadoPermitido $false

# Teste 4: Saída para a Internet (Portas 80 e 443)
Validar-Porta -Descricao "Saida Internet: Conexao HTTPS (1.1.1.1:443)" -IP "1.1.1.1" -Porta 443 -EsperadoPermitido $true

Write-Host ""
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  BATERIA DE TESTES FINALIZADA                            " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan
