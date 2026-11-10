# Histórico de alterações — CELEPAR

## 2026-11-10 — atualização de documentação da bancada prática

- Documentados os quatro participantes de rede virtuais: pfSense, servidor, estação e visitante; mais acesso remoto Windows pelo OpenVPN.
- Corrigida diferença entre projeto teórico com VLANs 802.1Q e protótipo de redes internas separadas no VirtualBox.
- Organizadas 19 capturas autênticas em `docs/evidencias/2026-11-10/` e associadas aos testes.
- Incorporados resultados de DNS, DHCP, Nginx, Samba/445, bloqueios de SSH/WebGUI/HTTP/SMB, HTTPS do visitante, NTP/Chrony, Zabbix/SNMP, VPN/SSH e conectividade externa.
- Adicionadas limitações de escopo: conectividade não prova por si só NAT traduzido; porta 445 não prova operação de compartilhamento; HTTP 200 não prova chamados; alerta do servidor Zabbix pede análise.
- Atualizados scripts para testes coerentes com o laboratório.

## 2026-10-26 — v2.1 (planejamento teórico)

Planejados DHCP, DNS, portal web interno, VPN e regras de firewall. A descrição original consta no histórico do repositório. Não interpretar essa versão teórica como um registro de testes efetivamente executados.

## 2026-10-23 — v2.0

Projeto base com dimensionamento de infraestrutura e políticas de isolamento.
