# 🛡️ Matriz de Regras de Firewall e Políticas de Segurança

Este documento detalha o comportamento lógico, portas e justificativas de segurança para cada regra definida na **Tabela 3** do relatório v2.0 da Celepar.

---

## 1. Princípios de Segurança Adotados

1. **Princípio do Menor Privilégio (*Least Privilege*):** Nenhum segmento de rede possui permissão padrão de acesso a outro segmento. Todo o tráfego não explicitamente permitido é descartado (*Default Drop / Deny All*).
2. **Inspeção de Estado (*Stateful Packet Inspection - SPI*):** O firewall mantém uma tabela de estados (`conntrack` / *state table*). Pacotes que pertencem a conexões iniciadas legitimamente de dentro da rede recebem permissão automática de retorno (`ESTABLISHED, RELATED`), sem a necessidade de abrir portas de entrada indiscriminadas na WAN.
3. **Isolamento de Zonas por Risco:**
   - **Zona Crítica (VLAN 10):** Acesso restrito a administradores credenciados.
   - **Zona Corporativa Segura (VLAN 20):** Apenas portas autorizadas de serviço são expostas.
   - **Zona de Operação (VLAN 30):** Estações cabeadas dos funcionários.
   - **Zona Desconfiável / Untrusted (VLAN 40):** Apenas saída para navegação externa.

---

## 2. Detalhamento Técnico das Regras

### Regra 1: Navegação de Visitantes (VLAN 40 ➔ WAN)
- **Origem:** `10.0.40.0/24`
- **Destino:** `0.0.0.0/0` (WAN / Internet)
- **Protocolos / Portas:**
  - `TCP 80` (HTTP)
  - `TCP 443` (HTTPS)
  - `UDP/TCP 53` (DNS)
- **Ação:** `PASS / PERMIT`
- **Justificativa:** Visitantes e dispositivos pessoais de funcionários (BYOD) necessitam apenas de acesso à internet e resolução de nomes externa. Qualquer tentativa de usar portas de SSH, Telnet, P2P, SMTP ou protocolos desconhecidos é bloqueada na origem.

---

### Regra 2: Isolamento da Rede de Visitantes (VLAN 40 ➔ VLANs 10, 20, 30)
- **Origem:** `10.0.40.0/24`
- **Destino:** `10.0.0.0/8` (RFC 1918 - Rede Corporativa Celepar)
- **Protocolos / Portas:** `ANY`
- **Ação:** `BLOCK / DROP`
- **Justificativa:** Evita varreduras de porta (*port scans*), tentativas de exploração lateral (*lateral movement*), infecções por malware ou acesso indevido aos servidores corporativos a partir de celulares ou notebooks não homologados que se conectam ao Wi-Fi visitante.

---

### Regra 3: Proteção de Borda (WAN ➔ Rede Interna)
- **Origem:** WAN (`Qualquer IP público`)
- **Destino:** Sub-redes internas (`10.0.0.0/8`)
- **Protocolos / Portas:** `ANY`
- **Ação:** `BLOCK / DROP` (Tráfego de entrada não solicitado)
- **Justificativa:** Regra básica de borda corporativa com NAT. Nenhuma porta de entrada deve ficar aberta para o mundo exterior sem um IP público dedicado ou DNAT/Port Forwarding explícito (e mesmo para acesso remoto, a recomendação adotada no relatório foi VPN autenticada).

---

### Regra 4: Acesso das Estações aos Servidores (VLAN 30 ➔ VLAN 20)
- **Origem:** `10.0.30.0/24`
- **Destino:** `10.0.20.0/24` (especificamente `10.0.20.5 - files.local`)
- **Protocolos / Portas:**
  - `TCP 445` (Microsoft-DS / SMB para compartilhamento de arquivos)
  - `TCP 631` (IPP - Internet Printing Protocol para impressoras de rede)
- **Ação:** `PASS / PERMIT` (com regra de `DROP` para todo o resto subsequente)
- **Justificativa:** Os 96 computadores dos funcionários necessitam acessar a pasta de rede da Celepar e mandar impressões para os equipamentos departamentais. Outras portas (como SSH 22, RDP 3389, SQL 3306/5432, HTTP/HTTPS no servidor) ficam fechadas para os usuários comuns, evitando acessos administrativos ou vetores de exploração.

---

### Regra 5: Proteção da Gerência (VLANs 20, 30, 40 ➔ VLAN 10)
- **Origem:** `10.0.20.0/24`, `10.0.30.0/24`, `10.0.40.0/24`
- **Destino:** `10.0.10.0/24`
- **Protocolos / Portas:** `ANY`
- **Ação:** `BLOCK / DROP`
- **Justificativa:** Os painéis de administração web (HTTPS/SSH) dos 4 switches TP-Link SG3428XMP, dos 6 Access Points EAP650, da PDU do rack e da interface do próprio roteador residem na VLAN 10. Bloquear o acesso das demais VLANs garante que um computador comprometido na estação de trabalho não consiga atacar o plano de controle (*control plane*) da infraestrutura. O acesso à VLAN 10 só é possível conectando fisicamente na porta reservada do rack ou via estação exclusiva do time de T.I.
