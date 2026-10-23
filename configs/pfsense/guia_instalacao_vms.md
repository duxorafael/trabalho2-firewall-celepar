# 🚀 Guia de Implementação no pfSense (Ambiente VirtualBox)

Este guia ensina a configurar o ambiente com **pfSense** no VirtualBox para reproduzir a arquitetura do projeto Celepar.

---

## 1. Topologia de Máquinas Virtuais no VirtualBox

Para uma bancada leve e funcional, você precisa de:
1. **VM 1: `pfsense-router`** (Gateway/Firewall)
   - **RAM:** 1024 MB (1 GB)
   - **CPU:** 1 vCPU
   - **Adaptador 1:** Placa em modo **Bridge** ou **NAT** (Simula a WAN / Internet pública).
   - **Adaptador 2:** Placa em modo **Rede Interna** (nome: `lan-celepar`).

2. **VM 2: `estacao-vlan30`** (Cliente simulando posto de trabalho)
   - Pode ser Alpine Linux (128 MB RAM) ou Lubuntu/TinyCore/Windows mini.
   - **Placa de Rede:** Rede Interna (`lan-celepar`).

3. **VM 3: `servidor-vlan20`** (Servidor corporativo `files.local`)
   - Alpine Linux ou Ubuntu Server bem leve.
   - **Placa de Rede:** Rede Interna (`lan-celepar`).

---

## 2. Configuração Inicial do pfSense

Após instalar a ISO do pfSense:
1. Atribua as interfaces:
   - `vtnet0` ou `em0` ➔ **WAN** (recebe IP do VirtualBox via DHCP).
   - `vtnet1` ou `em1` ➔ **LAN** (Interface pai dos troncos).
2. Acesse a interface web do pfSense a partir de um navegador em uma máquina conectada ou via porta de gerenciamento (`https://192.168.1.1` inicial).

---

## 3. Criação das VLANs no pfSense

No menu superior do pfSense:
1. Acesse **Interfaces ➔ VLANs** e clique em **+ Add**:
   - **Parent Interface:** `em1` (ou a interface interna)
   - **VLAN Tag:** `10` | **Description:** `VLAN_GERENCIA`
   - Salvar.
2. Repita o processo para as demais VLANs:
   - Tag `20` ➔ `VLAN_SERVIDORES`
   - Tag `30` ➔ `VLAN_ESTACOES`
   - Tag `40` ➔ `VLAN_VISITANTES`
3. Vá em **Interfaces ➔ Assignments**:
   - Associe cada VLAN criada a uma nova interface (ex: `OPT1` ➔ `VLAN 10`, `OPT2` ➔ `VLAN 20`, etc.).
   - Clique em cada interface criada, marque **Enable Interface** e defina o IPv4 estático:
     - `VLAN10`: `10.0.10.1` (Máscara `/24`)
     - `VLAN20`: `10.0.20.1` (Máscara `/24`)
     - `VLAN30`: `10.0.30.1` (Máscara `/24`)
     - `VLAN40`: `10.0.40.1` (Máscara `/24`)

---

## 4. Habilitar Servidor DHCP

Acesse **Services ➔ DHCP Server**:
1. Na aba **VLAN30 (Estações)**:
   - Marque **Enable DHCP server on VLAN30 interface**.
   - Faixa de endereços: `10.0.30.50` até `10.0.30.200`.
   - Gateway: `10.0.30.1`.
   - DNS: `10.0.10.1` (ou `1.1.1.1`, `8.8.8.8`).
2. Na aba **VLAN40 (Visitantes)**:
   - Marque **Enable DHCP server on VLAN40 interface**.
   - Faixa: `10.0.40.50` até `10.0.40.200`.
   - Gateway: `10.0.40.1`.

---

## 5. Criação de Aliases (Facilita as regras)

Vá em **Firewall ➔ Aliases ➔ IP**:
- Clique em **+ Add**:
  - **Name:** `REDES_INTERNAS`
  - **Type:** Network(s)
  - **Networks:** `10.0.0.0 / 8`
  - **Description:** Todas as sub-redes internas da Celepar.

Vá em **Firewall ➔ Aliases ➔ Ports**:
- Clique em **+ Add**:
  - **Name:** `PORTAS_SERVICOS_CORP`
  - **Type:** Port(s)
  - **Ports:** `445` (SMB) e `631` (IPP)
  - **Description:** Portas permitidas para o servidor de arquivos e impressoras.

- Clique em **+ Add**:
  - **Name:** `PORTAS_WEB_VISITANTE`
  - **Type:** Port(s)
  - **Ports:** `80`, `443`, `53`
  - **Description:** Navegação e resolução DNS para visitantes.

---

## 6. Configuração das Regras em *Firewall ➔ Rules*

Veja os detalhes textuais de cada tela no arquivo [`regras_pfsense.txt`](regras_pfsense.txt).
Lembre-se sempre de clicar em **Apply Changes** no topo da página após salvar cada regra.
