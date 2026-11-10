# Evidências do laboratório de 10/11/2026

Os **19 prints fornecidos** foram organizados na pasta `docs/evidencias/2026-11-10/` e descritos um a um em [`validacao_laboratorio_2026-11-10.md`](validacao_laboratorio_2026-11-10.md). Cada figura tem identificação, comando, origem, destino, resultado e uma ressalva técnica quando cabível.

Para montar o relatório, priorize prints que comprovem cada requisito: DHCP da estação e visitante, DNS interno, HTTP 200 da intranet, SMB/445 permitido, bloqueios com os logs correspondentes do pfSense, HTTPS externo do visitante, VPN/SSH com rota via 10.0.50.1, Zabbix três hosts verdes, Chrony e conectividade externa do servidor.

## Capturas adicionais recomendadas

- Tradução efetiva NAT na interface WAN do pfSense (captura ou estado) — distinto de simples saída para a Internet.
- O alerta restante no host CELEPAR-SRV dentro do Zabbix.
- Se a aplicação final exigir, comprovação de autenticação e cópia de arquivos em SMB ou funcionamento do fluxo do portal de chamados.

**Privacidade:** antes da publicação, revisar IPs da rede doméstica, MACs físicos, nomes de usuários e qualquer token. Não expor senhas, chaves privadas ou exports íntegros de configurações.
