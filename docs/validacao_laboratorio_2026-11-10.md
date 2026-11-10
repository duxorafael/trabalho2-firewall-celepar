# Validação prática do laboratório CELEPAR — 10 de novembro de 2026

> Este documento cataloga os 19 prints fornecidos. Os status abaixo descrevem **somente o que os registros efetivamente demonstram**. O ambiente é uma simulação acadêmica no VirtualBox, não infraestrutura da CELEPAR em produção.

## Topologia e serviços

- **CELEPAR-FW:** pfSense CE 2.9.0, cinco interfaces: WAN `em0` `10.0.2.15` (NAT VirtualBox), LAN de gerenciamento `em1` `10.0.10.1`, redes internas de servidores `em2` `10.0.20.1`, estações `em3` `10.0.30.1` e visitantes `em4` `10.0.40.1`.
- **CELEPAR-SRV:** Ubuntu Server, IP `10.0.20.5` e IP secundário `10.0.20.10` na mesma interface. Serviços: Nginx, Samba, Zabbix Server/Agent 2, Chrony.
- **CELEPAR-ESTACAO:** Ubuntu Desktop `10.0.30.50/24`, por DHCP.
- **CELEPAR-VISITANTE:** Ubuntu Desktop `10.0.40.50/24`, por DHCP.
- **VPN OpenVPN:** cliente Windows `10.0.50.2`, gateway `10.0.50.1`.

**VLAN ≠ rede interna VirtualBox:** o protótipo usa interfaces separadas no firewall, sem evidência de tags 802.1Q; não declarar que trunk 802.1Q foi testado.

## Catálogo das evidências

Todas as imagens listadas abaixo estão no diretório [`evidencias/2026-11-10/`](evidencias/2026-11-10/).

| ID | Arquivo | Resultado verificável |
|---|---|---|
| 01 | [DNS interno](evidencias/2026-11-10/01_dns_interno.png) | `nslookup intranet.celepar.local 10.0.30.1` resolve `10.0.20.10` — aprovado |
| 02 | [HTTP intranet](evidencias/2026-11-10/02_http_intranet.png) | `curl -I http://10.0.20.10` → `HTTP/1.1 200 OK`, servidor Nginx — aprovado |
| 03 | [SMB estação permitido](evidencias/2026-11-10/03_smb_estacao_permitido.png) | `nc -zv -w 3 10.0.20.5 445` → TCP conectado — aprovado (somente porta) |
| 04 | [WebGUI bloqueio no pfSense](evidencias/2026-11-10/04_webgui_bloqueio_log.png) | Log de bloqueio `10.0.30.50` → `10.0.10.1:80` — aprovado |
| 05 | [WebGUI bloqueio na estação](evidencias/2026-11-10/05_webgui_bloqueio_terminal.png) | `nc` para `10.0.10.1:80` → timeout — aprovado, em conjunto com 04 |
| 06 | [SSH bloqueio no pfSense](evidencias/2026-11-10/06_ssh_bloqueio_log.png) | Log de bloqueio `10.0.30.50` → `10.0.20.5:22` — aprovado |
| 07 | [SSH bloqueio na estação](evidencias/2026-11-10/07_ssh_bloqueio_terminal.png) | `nc` para `10.0.20.5:22` → timeout — aprovado, em conjunto com 06 |
| 08 | [DHCP estação](evidencias/2026-11-10/08_dhcp_estacao.png) | `ip a` → endereço dinâmico `10.0.30.50/24` — aprovado |
| 09 | [HTTP visitante bloqueio no pfSense](evidencias/2026-11-10/09_http_visitante_bloqueio_log.png) | Log de bloqueio `10.0.40.50` → `10.0.20.10:80` — aprovado |
| 10 | [HTTP visitante bloqueio no terminal](evidencias/2026-11-10/10_http_visitante_bloqueio_terminal.png) | `curl -I --connect-timeout 3 http://10.0.20.10` → timeout — aprovado com 09 |
| 11 | [SMB visitante bloqueio no pfSense](evidencias/2026-11-10/11_smb_visitante_bloqueio_log.png) | Log de bloqueio `10.0.40.50` → `10.0.20.5:445` — aprovado |
| 12 | [SMB visitante bloqueio no terminal](evidencias/2026-11-10/12_smb_visitante_bloqueio_terminal.png) | `nc` para `10.0.20.5:445` → timeout — aprovado com 11 |
| 13 | [DHCP visitante](evidencias/2026-11-10/13_dhcp_visitante.png) | `ip a` → endereço dinâmico `10.0.40.50/24` — aprovado |
| 14 | [Visitante HTTPS externo](evidencias/2026-11-10/14_visitante_https_externo.png) | `curl -I https://example.com` → `HTTP/2 200` — saída externa aprovada |
| 15 | [SSH administrativo pela VPN](evidencias/2026-11-10/15_ssh_vpn.png) | Login SSH em `10.0.20.5`, origem informada `10.0.50.2`; rota para `10.0.20.0/24` via `10.0.50.1` — aprovado |
| 16 | [Ping e traceroute VPN](evidencias/2026-11-10/16_ping_tracert_vpn.png) | Ping 4/4, rota por `10.0.50.1` até `10.0.20.5` — aprovado |
| 17 | [Zabbix três hosts](evidencias/2026-11-10/17_zabbix_tres_hosts.png) | ZBX estação e servidor verdes; SNMP pfSense verde; coleta recente — aprovado (analisar alerta do servidor) |
| 18 | [Saída externa do servidor](evidencias/2026-11-10/18_conectividade_externa_servidor.png) | `ping -c 3 8.8.8.8` → 3 recebidos, 0% de perda — conectividade aprovada; tradução NAT não observada diretamente |
| 19 | [NTP Chrony](evidencias/2026-11-10/19_chrony_ntp.png) | `chronyc tracking`: referência `0A001401` (= `10.0.20.1`), stratum 3, Leap Normal — aprovado |

## Matriz de validação

| Origem | Destino | Serviço | Comportamento observado |
|---|---|---|---|
| Estação `10.0.30.50` | DNS `10.0.30.1` | UDP/TCP 53 | Resolve intranet |
| Estação | Intranet `10.0.20.10` | TCP 80 | HTTP 200 |
| Estação | Servidor `10.0.20.5` | TCP 445 | Conecta |
| Estação | Servidor `10.0.20.5` | TCP 22 | Bloqueado, log do pfSense |
| Estação | Gestão `10.0.10.1` | TCP 80 | Bloqueado, log do pfSense |
| Visitante `10.0.40.50` | Intranet `10.0.20.10` | TCP 80 | Bloqueado, log do pfSense |
| Visitante | Servidor `10.0.20.5` | TCP 445 | Bloqueado, log do pfSense |
| Visitante | `example.com` | TCP 443 | HTTP/2 200 |
| Windows via VPN `10.0.50.2` | Servidor `10.0.20.5` | TCP 22 | Login autenticado, rota via VPN |
| Servidor | pfSense `10.0.20.1` | NTP UDP 123 | Sincronização normal no Chrony |
| Zabbix | Estação, servidor e pfSense | Agent 2 TCP 10050 / SNMP UDP 161 | Indicadores verdes e itens recentes |

## Interpretações e cuidados

- **Firewall:** combinar timeout do cliente com registro de *Block* no firewall para distinguir política de bloqueio de indisponibilidade do serviço.
- **NAT:** conexão externa bem-sucedida indica roteamento até a Internet, **não** registra sozinha o endereço traduzido. Complementar com *Diagnostics → Packet Capture* na WAN para demonstrar tradução, se exigido.
- **SMB:** teste `nc` comprova conexão TCP/445, não transferência de arquivos nem login.
- **Web:** `curl -I` comprova serviço HTTP, não necessariamente um formulário de chamados funcional.
- **Zabbix:** três indicadores verdes comprovam disponibilidade dos métodos monitorados; conferir e documentar o alerta restante em `CELEPAR-SRV`.
- **VPN:** a rota manual via Host-only `10.0.10.1` foi retirada; a captura final mostra rota via `10.0.50.1` e origem do login `10.0.50.2`.
- **Segurança:** não publicar `.ovpn` com chaves, certificados privados, senhas, backups íntegros do firewall ou capturas com tokens. IPs privados da simulação são adequados ao relatório, com revisão de dados pessoais.

## Pendências administrativas

O edital prevê relatório técnico `relatorio.pdf`, referências, configuração justificada e arquivo ZIP contendo a pasta do grupo, bem como defesa presencial. As imagens não substituem o relatório. Este arquivo auxilia na redação e na demonstração.
