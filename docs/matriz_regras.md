# Matriz de permissões — laboratório CELEPAR (10/11/2026)

Este documento resume o **comportamento observado** nas evidências. Para regras exatas (ordem, alias, NAT, portas e destinos), consultar a interface do pfSense e um export sanitizado; a matriz não é export do firewall.

| Origem | Destino | Porta | Regra/resultado esperado | Evidência |
|---|---|---|---|---|
| Estação `10.0.30.50` | Resolver local `10.0.30.1` | 53 | Permitir DNS | E01 |
| Estação | Intranet `10.0.20.10` | TCP 80 | Permitir HTTP | E02 |
| Estação | Arquivos `10.0.20.5` | TCP 445 | Permitir SMB | E03 |
| Estação | Servidor `10.0.20.5` | TCP 22 | **Bloquear SSH** | E06–E07 |
| Estação | pfSense gestão `10.0.10.1` | TCP 80 | **Bloquear WebGUI** | E04–E05 |
| Visitante `10.0.40.50` | Intranet `10.0.20.10` | TCP 80 | **Bloquear HTTP interno** | E09–E10 |
| Visitante | Servidor `10.0.20.5` | TCP 445 | **Bloquear SMB interno** | E11–E12 |
| Visitante | Internet (example.com) | TCP 443 | Permitir HTTPS externo | E14 |
| Cliente VPN `10.0.50.2` | Servidor `10.0.20.5` | TCP 22 | Permitir SSH administrativo | E15–E16 |
| Servidor `10.0.20.5` | pfSense `10.0.20.1` | UDP 123 | Permitir NTP | E19 |
| Zabbix | pfSense `10.0.20.1` | UDP 161 | Permitir SNMP | E17 |
| Zabbix | Estação `10.0.30.50` | TCP 10050 | Permitir Zabbix Agent 2 | E17 |

## Por que as regras são importantes

- **Menor privilégio:** portas de aplicação permitidas sem liberar o SSH da estação para o servidor.
- **Isolamento:** visitantes mantêm navegação HTTPS externa, mas não entram na intranet ou no SMB.
- **Gestão protegida:** estação comum não acessa o painel pfSense na rede administrativa.
- **Acesso remoto controlado:** administrativo via túnel OpenVPN e autenticação SSH.
- **Monitoramento:** o servidor coleta métricas pelo Agent 2 e SNMP, com exceções pontuais sem abrir toda a rede.

**Observação:** o simulador usa interfaces virtuais dedicadas, não tags 802.1Q. A referência de VLAN nos arquivos teóricos não corresponde a trunk configurado neste experimento.
