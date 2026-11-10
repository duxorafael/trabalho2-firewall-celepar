# Testes de conectividade — executar em Windows na interface/rede apropriada.
# Por padrao, modo VPN: verifica a rota do Windows e SSH para o servidor.
# NAO usar este script para afirmar bloqueios da ESTACAO (o Windows e administrador).
$rota = Get-NetRoute -AddressFamily IPv4 -DestinationPrefix '10.0.20.0/24' -ErrorAction SilentlyContinue |
    Where-Object { $_.NextHop -eq '10.0.50.1' }
if ($rota) {
    Write-Host '[PASS] Rota da rede do servidor via OpenVPN 10.0.50.1' -ForegroundColor Green
    $rota | Select-Object DestinationPrefix,NextHop,InterfaceAlias,RouteMetric | Format-Table
} else {
    Write-Host '[FALHA] Rota via OpenVPN 10.0.50.1 nao encontrada' -ForegroundColor Red
}
$tcp = Test-NetConnection -ComputerName '10.0.20.5' -Port 22 -WarningAction SilentlyContinue -InformationLevel Quiet
if ($tcp) { Write-Host '[PASS] SSH TCP/22 do servidor acessivel' -ForegroundColor Green } else { Write-Host '[FALHA] SSH TCP/22 inacessivel' -ForegroundColor Red }
Write-Host 'Aviso: TCP conectado nao equivale a autenticacao SSH. Verifique com ssh manualmente.'
