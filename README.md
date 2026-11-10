# Trabalho 2 — Implementação prática de rede e firewall (CELEPAR)

**Instituição:** IFPR — Campus Pinhais · **Disciplina:** Projeto de Redes de Computadores  
**Equipe:** Alexandre Raphael Marques de Freitas, Beatriz Regina Nahas e Maurício Rockembach dos Santos.

Este repositório reúne o projeto teórico e as evidências do **protótipo prático de quatro VMs**, implantado no VirtualBox e validado em 10/11/2026. Os resultados estão detalhados em [`docs/validacao_laboratorio_2026-11-10.md`](docs/validacao_laboratorio_2026-11-10.md).

## Arquitetura real implementada

| Segmento | Sub-rede | Gateway pfSense | Máquina / observação |
|---|---|---|---|
| WAN | VirtualBox NAT | `em0`, DHCP `10.0.2.15` | Acesso externo |
| Gestão | `10.0.10.0/24` | `em1` `10.0.10.1` | Windows Host-only `10.0.10.2` |
| Servidores | `10.0.20.0/24` | `em2` `10.0.20.1` | CELEPAR-SRV `10.0.20.5`; Nginx intranet `10.0.20.10` |
| Estações | `10.0.30.0/24` | `em3` `10.0.30.1` | CELEPAR-ESTACAO DHCP `10.0.30.50` |
| Visitantes | `10.0.40.0/24` | `em4` `10.0.40.1` | CELEPAR-VISITANTE DHCP `10.0.40.50` |
| VPN | `10.0.50.0/24` | OpenVPN `10.0.50.1` | Cliente Windows `10.0.50.2` |

**Atenção:** as redes de servidores, estações e visitantes foram conectadas a **interfaces físicas virtuais distintas**, cada uma em uma *Internal Network* do VirtualBox, **não** em trunk 802.1Q. A identificação "VLAN 10/20/30/40" permanece na documentação *teórica* e em alguns arquivos históricos, mas não descreve encapsulamento VLAN observado no protótipo. O projeto original para 96 estações é um dimensionamento teórico, não o número de máquinas instaladas.

## Serviços implantados e testados

| Serviço | Implementação | Resultado observado |
|---|---|---|
| DHCP | pfSense | IP dinâmico nas VMs estação e visitante |
| DNS | DNS Resolver do pfSense | `intranet.celepar.local` → `10.0.20.10` |
| Firewall | pfSense | Estação: HTTP 80 e SMB 445 permitidos; SSH 22 e WebGUI 80 bloqueados. Visitante: intranet 80 e SMB 445 bloqueados |
| Intranet | Nginx no Ubuntu Server | HTTP 200 OK em `10.0.20.10:80` |
| Arquivos | Samba | Porta TCP 445 alcançável da estação; transferência autenticada não demonstrada nos prints |
| NTP | Chrony ↔ pfSense | Fonte `10.0.20.1`, `Leap status: Normal` |
| NAT e Internet | pfSense / VirtualBox | Acesso externo da VM visitante e ping externo do servidor; ainda sem captura da tradução pós-NAT |
| Monitoramento | Zabbix Server/Agent 2 e SNMP | Três hosts com indicadores ZBX/SNMP verdes e dados recentes |
| VPN | OpenVPN | Rota do cliente `10.0.20.0/24` via `10.0.50.1`; SSH autenticado no servidor a partir do IP `10.0.50.2` |

## Arquivos

- [`docs/validacao_laboratorio_2026-11-10.md`](docs/validacao_laboratorio_2026-11-10.md) — catálogo das 19 provas, comandos, conclusões e limitações.
- [`docs/evidencias/2026-11-10/`](docs/evidencias/2026-11-10/) — capturas de tela recebidas, com nomes normalizados.
- [`docs/matriz_regras.md`](docs/matriz_regras.md) — matriz resumida de acesso e segurança observados.
- [`configs/pfsense/guia_instalacao_vms.md`](configs/pfsense/guia_instalacao_vms.md) — guia da topologia e testes efetivos.
- [`configs/pfsense/regras_pfsense.txt`](configs/pfsense/regras_pfsense.txt) — resumo de regras esperadas/observadas (não substitui export do pfSense).
- [`testes/test_firewall.sh`](testes/test_firewall.sh) — script de verificação na estação Linux (sem alterar o firewall).
- [`CHANGELOG.md`](CHANGELOG.md) — histórico de atualização.

Os diretórios `configs/packet_tracer/` e `docs/prints/` já existentes permanecem como materiais históricos; não são prova da implementação em VirtualBox.

## Pendências para entrega

- Checar o **alerta ativo** mostrado no host `CELEPAR-SRV` no Zabbix.
- Caso exigido, capturar uma evidência de **tradução NAT** na WAN do pfSense. Ping/HTTPS externos provam conectividade, não isoladamente a tradução.
- Validar operações de usuário final além do simples teste de portas, caso necessário: autenticação/cópia SMB, página ou fluxo de chamados.
- Concluir `relatorio.pdf`, organizar ZIP do professor e ensaiar a defesa técnica. **Não subir credenciais, certificados privados nem backups sem sanitização.**
