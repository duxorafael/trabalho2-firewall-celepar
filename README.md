# Trabalho 2: Implementacao Pratica de Firewall (Projeto Celepar)
Disciplina: Redes de Computadores - 4o Periodo  
Instituicao: Instituto Federal do Parana (IFPR) - Campus Pinhais  
Professor: Gabriel Vinicius Canzi Candido  
Integrantes: Alexandre Raphael Marques de Freitas, Beatriz Regina Nahas, Mauricio Rockembach dos Santos  

---

## 1. Visao Geral do Projeto (v2.1)
Este repositorio contem a implementacao pratica da infraestrutura de rede corporativa projetada para o escritorio da Celepar (docs/armf_brn_mrs.pdf).

O foco central e a Seguranca Logica, Segmentacao de Redes e Firewall Stateful, integrando os servicos requeridos:
1. Firewall Central e Roteamento Inter-VLAN (Filtragem em Camada 4 com politica de menor privilegio).
2. Servico de DHCP (Distribuicao dinamica com pools dedicados por VLAN).
3. Servico de DNS Interno (Resolucao autoritativa para o dominio celepar.local e recursao externa).
4. Servidor Web e Intranet Corporativa (Portal interno com sistema de requisicao de servicos de T.I. na VLAN 20).
5. Acesso Remoto Seguro via VPN (Tunel criptografado para colaboradores remotos e administracao externa).

---

## 2. Segmentacao de Sub-redes e Servicos

| Segmento | Identificacao | Sub-rede | Gateway | Servicos Ativos |
|---|---|---|---|---|
| VLAN 10 | Gerenciamento | 10.0.10.0/24 | 10.0.10.1 | Gerencia dos switches, APs, gateway e Servidor DNS (10.0.10.1). |
| VLAN 20 | Servidores / Corporativo | 10.0.20.0/24 | 10.0.20.1 | Servidor de Arquivos SMB (10.0.20.5) e Servidor Web Intranet/Requisicoes (10.0.20.10). |
| VLAN 30 | Estacoes de Trabalho | 10.0.30.0/24 | 10.0.30.1 | 96 computadores fisicos recebendo IP via DHCP (10.0.30.50-200). |
| VLAN 40 | Wi-Fi Visitantes | 10.0.40.0/24 | 10.0.40.1 | Dispositivos moveis e BYOD recebendo IP via DHCP (10.0.40.50-200) isolados de ativos internos. |
| VPN | Acesso Remoto Seguro | 10.0.50.0/24 | 10.0.50.1 | Tunel OpenVPN/IPsec para colaboradores e T.I. externa via WAN (UDP 1194). |

---

## 3. Estrutura do Repositorio

```text
Trabalho2_Firewall_Celepar/
|
|-- README.md                          # Guia principal do projeto
|-- CHANGELOG.md                       # Historico formal de versionamento (v2.0 -> v2.1)
|-- .gitignore                         # Filtro de arquivos temporarios e logs
|
|-- docs/
|   |-- armf_brn_mrs.pdf               # Relatorio teorico v2.0 de referencia
|   |-- matriz_regras.md               # Especificacao tecnica de regras e seguranca
|   `-- roteiro_defesa.md              # Roteiro formal para a defesa com o professor Gabriel
|
|-- servicos/
|   `-- intranet/
|       `-- index.html                 # Portal Web Intranet da Celepar com Sistema de Requisicoes
|
|-- configs/
|   |-- pfsense/                       # Plano A: Implementacao com Maquinas Virtuais
|   |   |-- guia_instalacao_vms.md     # Guia de configuracao com DNS, DHCP, Web e OpenVPN
|   |   `-- regras_pfsense.txt         # Relacao textual de regras para a interface web
|   `-- packet_tracer/                 # Plano B: Implementacao no Cisco Packet Tracer
|       |-- guia_packet_tracer.md      # Montagem com Switch, Servidor Web/DNS e PCs
|       `-- router_cisco_ios.cfg       # Script CLI completo (ROAS, ACLs, DHCP, NAT e DNS)
|
`-- testes/
    |-- test_firewall.ps1              # Script de teste automatizado em PowerShell (Windows)
    `-- test_firewall.sh               # Script de teste automatizado em Bash (Linux)
```

---

## 4. Matriz de Regras de Firewall

1. Visitantes (VLAN 40 -> WAN): Permite apenas navegacao web e DNS (portas 80, 443 e 53).
2. Isolamento de Visitantes (VLAN 40 -> Redes Internas): Bloqueio irrestrito. Visitantes nao acessam arquivos, Intranet nem gerencia.
3. Estacoes para Servidores (VLAN 30 -> VLAN 20): Permite arquivos (SMB 445), impressao (IPP 631) e Intranet / Requisicoes (HTTP 80 / HTTPS 443). Demais portas fechadas.
4. Protecao da Gerencia (VLANs 20, 30, 40 -> VLAN 10): Bloqueio irrestrito para estacoes comuns.
5. Acesso Remoto Seguro (VPN -> VLAN 20/10): Colaboradores remotos acessam Intranet e SMB; administradores credenciados acessam VLAN 10.
6. Borda Externa (WAN -> LAN): Bloqueio padrao de conexoes de entrada nao solicitadas (Stateful), permitindo unicamente o tunel VPN autenticado (UDP 1194).

---

## 5. Portal Web da Intranet (Servicos de Requisicao)
O arquivo servicos/intranet/index.html e o portal oficial simulando a intranet da Celepar hospedada no servidor 10.0.20.10:
- Permite a colaboradores da VLAN 30 e da VPN abrirem chamados tecnicos de suporte.
- Demonstra status em tempo real dos servicos (SMB, DNS, DHCP, VPN e Web).
- Pode ser aberto em qualquer navegador, servidor Nginx/Apache ou importado no servico HTTP do Cisco Packet Tracer.
