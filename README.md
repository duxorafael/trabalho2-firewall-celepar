# 🛡️ Trabalho 2: Implementação Prática de Firewall (Projeto Celepar)
**Disciplina:** Redes de Computadores – 4º Período  
**Instituição:** Instituto Federal do Paraná (IFPR) – Campus Pinhais  
**Professor:** Gabriel Vinicius Canzi Candido  
**Integrantes:** Alexandre Raphael Marques de Freitas, Beatriz Regina Nahas, Maurício Rockembach dos Santos  

---

## 📌 Visão Geral do Projeto
Este repositório contém os artefatos práticos para a segunda etapa do projeto de infraestrutura de rede corporativa. A partir do dimensionamento teórico documentado no relatório v2.0 da Celepar ([`docs/armf_brn_mrs.pdf`](docs/armf_brn_mrs.pdf)), implementamos e validamos a camada de **Segurança Lógica e Filtragem de Pacotes** do gateway central.

### Segmentação de Sub-redes (VLANs)
| VLAN | Identificação | Sub-rede | Gateway | Finalidade |
|---|---|---|---|---|
| **10** | Gerenciamento | `10.0.10.0/24` | `10.0.10.1` | Gerência dos switches, APs e interfaces de administração. |
| **20** | Servidores / Corporativo | `10.0.20.0/24` | `10.0.20.1` | Servidor de arquivos (`files.local` / `10.0.20.5`) e impressoras corporativas. |
| **30** | Estações de Trabalho | `10.0.30.0/24` | `10.0.30.1` | 96 postos cabeados dos colaboradores Celepar. |
| **40** | Wi-Fi Visitantes | `10.0.40.0/24` | `10.0.40.1` | Rede sem fio isolada para visitantes e dispositivos BYOD. |

---

## 🗂️ Estrutura do Repositório

```text
Trabalho2_Firewall_Celepar/
│
├── README.md                          # Este guia mestre
├── .gitignore                         # Filtro de arquivos temporários e logs
│
├── docs/
│   ├── armf_brn_mrs.pdf               # Relatório teórico v2.0 da Celepar (Trabalho 1)
│   ├── matriz_regras.md               # Detalhamento e justificativa técnica das regras de firewall
│   └── roteiro_defesa.md              # Roteiro de defesa oral com o professor Gabriel
│
├── configs/
│   ├── pfsense/                       # Plano A: Implementação prática com VMs
│   │   ├── guia_instalacao_vms.md     # Guia passo a passo de setup no VirtualBox
│   │   └── regras_pfsense.txt         # Relação exata das regras para a GUI do pfSense
│   └── packet_tracer/                 # Plano B: Implementação no Cisco Packet Tracer
│       ├── guia_packet_tracer.md      # Como montar a topologia no Packet Tracer
│       └── router_cisco_ios.cfg       # Script CLI completo (ROAS, VLANs, DHCP e ACLs)
│
└── testes/
    ├── test_firewall.ps1              # Script de validação automática em PowerShell (Windows)
    └── test_firewall.sh               # Script de validação automática em Bash (Linux / Alpine)
```

---

## 🚀 Como Executar o Projeto

### Opção 1: Ambiente com Máquinas Virtuais (pfSense) - Recomendado
1. Siga as instruções em [`configs/pfsense/guia_instalacao_vms.md`](configs/pfsense/guia_instalacao_vms.md).
2. Suba o pfSense como roteador central interligando as redes internas.
3. Configure as interfaces virtuais das VLANs e aplique as regras descritas em [`configs/pfsense/regras_pfsense.txt`](configs/pfsense/regras_pfsense.txt).
4. Inicie as máquinas clientes e rode os scripts de validação na pasta [`testes/`](testes/).

### Opção 2: Simulação no Cisco Packet Tracer
1. Abra o Cisco Packet Tracer e siga as instruções em [`configs/packet_tracer/guia_packet_tracer.md`](configs/packet_tracer/guia_packet_tracer.md).
2. Cole os comandos do arquivo [`configs/packet_tracer/router_cisco_ios.cfg`](configs/packet_tracer/router_cisco_ios.cfg) no CLI do roteador.
3. Realize os testes de ping e requisições HTTP nos terminais dos computadores simulados.

---

## 🛡️ Matriz de Regras de Firewall (Tabela 3 do Relatório)

| Regra | Origem | Destino | Porta / Serviço | Ação | Objetivo |
|:---:|---|---|---|:---:|---|
| **1** | VLAN 40 (Visitantes) | WAN (Internet) | HTTP (80), HTTPS (443), DNS (53) | **Permitir** | Acesso controlado à navegação web para visitantes. |
| **2** | VLAN 40 (Visitantes) | VLANs 10, 20, 30 | Qualquer | **Bloquear** | Isolamento total da rede de visitantes dos ativos da Celepar. |
| **3** | WAN (Internet) | Rede Interna | Qualquer | **Bloquear** | Bloqueio padrão de conexões de entrada não solicitadas (*stateful inspection*). |
| **4** | VLAN 30 (Estações) | VLAN 20 (Servidores) | SMB (445), IPP (631) | **Permitir** | Acesso dos colaboradores aos arquivos e servidores de impressão. |
| **5** | VLANs 20, 30, 40 | VLAN 10 (Gerência) | Qualquer | **Bloquear** | Restrição estrita de acesso aos ativos de gerência da infraestrutura. |

---

## 🎯 Preparação para a Defesa
Para consultar argumentos técnicos, justificativas das portas, fluxo dos pacotes e possíveis perguntas que o professor Gabriel pode fazer durante a arguição, veja o [`docs/roteiro_defesa.md`](docs/roteiro_defesa.md).
