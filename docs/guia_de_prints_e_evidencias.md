# Guia de Coleta de Evidencias e Prints (Relatorio Tecnico - IFPR)
Disciplina: Redes de Computadores - 4o Periodo
Projeto: Firewall, Segmentacao e Servicos Corporativos Celepar
Equipe: Alexandre, Beatriz e Mauricio

---

## Objetivo deste Documento
Padronizar a captura de telas (screenshots) e saidas de terminal que devem ser anexadas no relatorio tecnico da Beatriz para comprovar o funcionamento de todos os servicos e regras exigidos pelo professor Gabriel Candido.

Dica de Organizacao: Salvar todos os prints na pasta docs/prints/ com os nomes sugeridos abaixo (ex: print_01_dashboard.png).

---

## Bloco 1: Infraestrutura e Segmentacao (pfSense)

### Print 01: Dashboard Geral do pfSense
- Arquivo sugerido: print_01_pfsense_dashboard.png
- O que mostrar: Tela inicial do pfSense mostrando o status do sistema, utilizacao de memoria/CPU e o painel de interfaces ativas com os respectivos enderecos IP.
- Legenda para o relatorio: "Figura X: Painel principal do gateway central pfSense com interfaces e subinterfaces ativas."

### Print 02: Configuracao das VLANs
- Arquivo sugerido: print_02_interfaces_vlans.png
- Onde tirar: Menu Interfaces -> VLANs.
- O que mostrar: Tabela com as 4 VLANs criadas (VLAN 10 - Gerencia, VLAN 20 - Servidores, VLAN 30 - Estacoes, VLAN 40 - Visitantes) vinculadas a interface pai.
- Legenda para o relatorio: "Figura X: Mapeamento de tags 802.1Q e descricao das VLANs no gateway corporativo."

### Print 03: Atribuicao de Interfaces e Enderecos IP
- Arquivo sugerido: print_03_interfaces_assignments.png
- Onde tirar: Menu Interfaces -> Assignments.
- O que mostrar: Lista com cada interface associada ao seu gateway correto:
  - VLAN10: 10.0.10.1/24
  - VLAN20: 10.0.20.1/24
  - VLAN30: 10.0.30.1/24
  - VLAN40: 10.0.40.1/24
- Legenda para o relatorio: "Figura X: Atribuicao estatica de enderecamento IP para os gateways de cada sub-rede."

---

## Bloco 2: Servicos de Rede (DHCP, DNS e VPN)

### Print 04: Servidor DHCP Ativo
- Arquivo sugerido: print_04_dhcp_server_config.png
- Onde tirar: Menu Services -> DHCP Server (aba VLAN30 ou VLAN40).
- O que mostrar: O servico habilitado, a faixa de distribuicao (ex: 10.0.30.50 a 10.0.30.200), o gateway e os servidores DNS configurados.
- Legenda para o relatorio: "Figura X: Escopo DHCP dinamico configurado para a rede de estacoes de trabalho."

### Print 05: Tabela de Leases (Clientes DHCP Conectados)
- Arquivo sugerido: print_05_dhcp_leases.png
- Onde tirar: Menu Status -> DHCP Leases.
- O que mostrar: As maquinas clientes (Estacao de Trabalho e Visitante) recebendo seus IPs dinamicos com seus Hostnames e enderecos MAC.
- Legenda para o relatorio: "Figura X: Concessoes ativas de DHCP demonstrando alocacao correta de IPs por VLAN."

### Print 06: Configuracao do DNS Resolver (Host Overrides)
- Arquivo sugerido: print_06_dns_resolver_entries.png
- Onde tirar: Menu Services -> DNS Resolver -> General Settings (secao Host Overrides no final da pagina).
- O que mostrar: As entradas mapeadas para a rede interna:
  - intranet.celepar.local -> 10.0.20.10
  - files.local -> 10.0.20.5
  - router.local -> 10.0.10.1
- Legenda para o relatorio: "Figura X: Mapeamento autoritativo de dominios locais no DNS Resolver interno."

### Print 07: Configuracao da VPN (OpenVPN)
- Arquivo sugerido: print_07_openvpn_server.png
- Onde tirar: Menu VPN -> OpenVPN -> Servers.
- O que mostrar: O servidor OpenVPN configurado na porta UDP 1194, protocolo IPv4, Tunnel Network 10.0.50.0/24 e Local Network 10.0.20.0/24.
- Legenda para o relatorio: "Figura X: Parametros do servidor OpenVPN com sub-rede dedicada para acesso remoto."

---

## Bloco 3: Regras de Firewall (Aba por Aba)

### Print 08: Regras da Interface WAN
- Arquivo sugerido: print_08_firewall_rules_wan.png
- Onde tirar: Menu Firewall -> Rules -> aba WAN.
- O que mostrar: Regra de permissao da porta UDP 1194 (OpenVPN) e bloqueio padrao de todo o restante de entrada.
- Legenda para o relatorio: "Figura X: Politica de borda WAN restringindo conexoes externas apenas a porta autenticada da VPN."

### Print 09: Regras da VLAN 30 (Estacoes de Trabalho)
- Arquivo sugerido: print_09_firewall_rules_vlan30.png
- Onde tirar: Menu Firewall -> Rules -> aba VLAN30.
- O que mostrar:
  1. Bloqueio para a VLAN 10 (Gerencia).
  2. Permissao para a VLAN 20 nas portas especificas: 80, 443 (Intranet) e 445, 631 (SMB/IPP).
  3. Bloqueio do restante para a VLAN 20.
  4. Permissao de saida para a Internet.
- Legenda para o relatorio: "Figura X: Regras de filtragem da VLAN 30 aplicando o principio do menor privilegio sobre os servidores."

### Print 10: Regras da VLAN 40 (Visitantes)
- Arquivo sugerido: print_10_firewall_rules_vlan40.png
- Onde tirar: Menu Firewall -> Rules -> aba VLAN40.
- O que mostrar:
  1. Permissao de DNS (53) e Web (80, 443) para qualquer destino externo.
  2. Bloqueio irrestrito para todas as redes internas (10.0.0.0/8).
- Legenda para o relatorio: "Figura X: Politica de isolamento total da VLAN 40 contra os ativos corporativos internos."

---

## Bloco 4: Validacao Pratica nos Clientes (Terminais e Telas)

### Print 11: Acesso ao Portal Web da Intranet (VLAN 30)
- Arquivo sugerido: print_11_intranet_acesso_sucesso.png
- Onde tirar: No navegador da VM Estacao de Trabalho (VLAN 30).
- O que mostrar: Navegador abrindo http://intranet.celepar.local ou http://10.0.20.10 com o portal de chamados carregado perfeitamente.
- Legenda para o relatorio: "Figura X: Acesso bem-sucedido ao portal Intranet Celepar a partir da rede corporativa de estacoes."

### Print 12: Bloqueio da Intranet para Visitantes (VLAN 40)
- Arquivo sugerido: print_12_intranet_bloqueio_visitante.png
- Onde tirar: No navegador da VM Visitante (VLAN 40).
- O que mostrar: Tentativa de abrir http://10.0.20.10 resultando em "Tempo limite esgotado" ou "Nao e possivel acessar este site".
- Legenda para o relatorio: "Figura X: Bloqueio imposto pelo firewall impedindo que dispositivos visitantes acessem a Intranet."

### Print 13: Execucao do Script de Testes Automatizado
- Arquivo sugerido: print_13_script_testes_terminal.png
- Onde tirar: No terminal PowerShell ou Linux da Estacao de Trabalho rodando test_firewall.ps1 ou test_firewall.sh.
- O que mostrar: A tela com os resultados claros:
  - SMB (445): [PASSOU - CONECTADO]
  - Intranet (80): [PASSOU - CONECTADO]
  - Porta SSH nao autorizada (22): [PASSOU - BLOQUEADO COM SUCESSO]
  - Ping na Gerencia (10.0.10.1): [PASSOU - DROPADO COM SUCESSO]
  - Conexao HTTPS Externa (443): [PASSOU - CONECTADO]
- Legenda para o relatorio: "Figura X: Bateria de testes automatizados confirmando o comportamento esperado de cada regra do firewall."

---

## Checklist Rapido de Coleta

- [ ] Print 01: Dashboard do pfSense
- [ ] Print 02: VLANs criadas
- [ ] Print 03: Interfaces e IPs configurados
- [ ] Print 04: Configuracao do DHCP
- [ ] Print 05: Concessoes (Leases) do DHCP
- [ ] Print 06: Mapeamento de Host Overrides no DNS
- [ ] Print 07: Servidor OpenVPN
- [ ] Print 08: Regras da interface WAN
- [ ] Print 09: Regras da VLAN 30
- [ ] Print 10: Regras da VLAN 40
- [ ] Print 11: Portal Intranet aberto na VLAN 30
- [ ] Print 12: Bloqueio do portal na VLAN 40
- [ ] Print 13: Execucao do script de testes
