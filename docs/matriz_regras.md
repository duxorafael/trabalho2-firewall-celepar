# Matriz de Regras de Firewall e Politicas de Seguranca (v2.1)

Este documento detalha o comportamento logico, portas e justificativas de seguranca para as regras do firewall, incorporando os servicos corporativos solicitados pelo professor (DHCP, DNS, Servidor Web / Intranet com Requisicoes e VPN), mantendo foco na arquitetura de seguranca e menor privilegio.

---

## 1. Principios de Seguranca Adotados

1. Principio do Menor Privilegio (Least Privilege): Nenhum segmento de rede possui permissao padrao de acesso a outro segmento. Todo o trafego nao explicitamente permitido e descartado (Default Drop / Deny All).
2. Inspecao de Estado (Stateful Packet Inspection - SPI): O firewall mantem uma tabela de estados (conntrack / state table). Pacotes que pertencem a conexoes iniciadas legitimamente de dentro da rede recebem permissao automatica de retorno (ESTABLISHED, RELATED), sem a necessidade de abrir portas de entrada indiscriminadas na WAN.
3. Isolamento de Zonas por Risco:
   - Zona Critica (VLAN 10 - Gerenciamento): Acesso restrito a administradores credenciados (ou via VPN administrativa autenticada).
   - Zona Corporativa Segura (VLAN 20 - Servidores): Concentra o servidor de arquivos (files.local / 10.0.20.5), o servidor web da Intranet/Requisicoes (intranet.celepar.local / 10.0.20.10) e impressoras corporativas.
   - Zona de Operacao (VLAN 30 - Estacoes de Trabalho): 96 postos cabeados dos colaboradores Celepar.
   - Zona Nao Confiavel / Untrusted (VLAN 40 - Wi-Fi Visitantes): Apenas saida restrita para navegacao externa (isolamento total contra qualquer ativo interno).
   - Zona de Acesso Remoto (VPN - 10.0.50.0/24): Tunel criptografado para colaboradores remotos e administracao externa de T.I.

---

## 2. Mapa dos Servicos Corporativos

| Servico | Host / IP | Porta(s) | Descricao e Seguranca |
|---|---|---|---|
| DHCP Central | Gateway Central (10.0.x.1) | UDP 67 / 68 | Escopos dinamicos para VLAN 30 e 40 com exclusao de IPs estaticos. |
| DNS Resolver | 10.0.10.1 (Gateway) | UDP/TCP 53 | Resolucao interna autoritativa (celepar.local) e recursao externa com cache. |
| Servidor de Arquivos (SMB) | 10.0.20.5 (files.local) | TCP 445 | Compartilhamento seguro de diretorios corporativos Celepar. |
| Servidor Web / Intranet | 10.0.20.10 (intranet.celepar.local) | TCP 80 / 443 | Portal de chamados e requisicao de servicos de T.I. dos colaboradores. |
| Servidor de Impressao | 10.0.20.0/24 | TCP 631 | Protocolo IPP para envio de documentos as impressoras do andar. |
| Gateway VPN (OpenVPN/IPsec) | WAN (203.0.113.2) | UDP 1194 | Tunel criptografado de acesso remoto alocando IPs na faixa 10.0.50.0/24. |

---

## 3. Matriz Completa de Regras de Firewall

| Regra | Origem | Destino | Porta / Servico | Acao | Objetivo / Justificativa |
|:---:|---|---|---|:---:|---|
| 1 | VLAN 40 (Visitantes) | WAN (Internet) | HTTP (80), HTTPS (443), DNS (53) | Permitir | Acesso controlado a navegacao web para visitantes. |
| 2 | VLAN 40 (Visitantes) | Redes Internas (10.0.0.0/8) | Qualquer | Bloquear | Isolamento total: visitantes nao acessam a Intranet, SMB nem gerencia. |
| 3 | WAN (Internet) | Gateway WAN | UDP 1194 (OpenVPN) | Permitir | Ponto de entrada exclusivo para tunel VPN autenticado com certificado. |
| 4 | WAN (Internet) | Redes Internas | Qualquer | Bloquear | Bloqueio padrao de conexoes nao solicitadas (stateful inspection). |
| 5 | VLAN 30 (Estacoes) | VLAN 20 (Servidores) | SMB (445), IPP (631), HTTP (80), HTTPS (443) | Permitir | Acesso aos arquivos, impressoras e Portal Intranet / Sistema de Requisicoes. |
| 6 | VLAN 30 (Estacoes) | VLAN 20 (Servidores) | Qualquer outra porta | Bloquear | Bloqueia SSH (22), RDP (3389) e banco de dados contra acessos nao autorizados. |
| 7 | VPN (10.0.50.0/24) | VLAN 20 (Servidores) | SMB (445), HTTP (80), HTTPS (443) | Permitir | Colaborador remoto acessa arquivos e portal de requisicoes com seguranca. |
| 8 | VPN (10.0.50.0/24) | VLAN 10 (Gerencia) | SSH (22), HTTPS (443) | Permitir (Admin) | Administrador de T.I. gerencia switches e roteadores remotamente via VPN. |
| 9 | VLANs 20, 30, 40 | VLAN 10 (Gerencia) | Qualquer | Bloquear | Protecao estrita das interfaces administrativas locais contra usuarios comuns. |
| 10 | VLAN 30, 40 | Gateway Local | UDP 67/68 (DHCP), UDP 53 (DNS) | Permitir | Permite obtencao de IP automatico e resolucao de nomes internos/externos. |
| Default | Qualquer | Qualquer | Qualquer | Bloquear | Default Drop: todo trafego nao explicitado acima e descartado. |

---

## 4. Analise Tecnica de Seguranca dos Servicos

### Posicionamento da Intranet e Sistema de Requisicoes na VLAN 20
A alocacao do servidor web na VLAN 20 (Zona de Servidores) resguarda a aplicacao tanto do acesso publico irrestrito da WAN quanto da rede de visitantes (VLAN 40). O trafego das estacoes de trabalho (VLAN 30) para a aplicacao e restrito estritamente as portas 80 e 443. Caso a aplicacao sofra qualquer incidente, o isolamento em Camada 3 impede a propagacao lateral para as estacoes dos colaboradores ou para os ativos de gerencia.

### Seguranca da VPN na Porta UDP 1194 e Sub-rede 10.0.50.0/24
O servico de VPN estabelece um canal criptografado via TLS/SSL. Ao delimitar uma sub-rede exclusiva (10.0.50.0/24), o firewall mantem a capacidade de aplicar politicas granulares aos clientes externos (Regras 7 e 8) sem misturar permissoes com as maquinas fisicas da empresa, viabilizando controle de acesso e auditoria.
