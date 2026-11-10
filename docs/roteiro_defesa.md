# Roteiro de defesa — protótipo CELEPAR

1. **Topologia (30 s):** explicar as quatro VMs e os cinco adaptadores do pfSense, distinguindo redes internas do VirtualBox de VLANs 802.1Q do planejamento original.
2. **Endereçamento (30 s):** apresentar DHCP da estação `10.0.30.50` e do visitante `10.0.40.50`, além de DNS interno `intranet.celepar.local` → `10.0.20.10`.
3. **Serviço corporativo (30 s):** HTTP 200 da intranet Nginx e porta TCP 445 do Samba acessível pela estação; não afirmar upload/chamado/cópia se não demonstrado.
4. **Firewall (60 s):** contrastar estação (HTTP 80, SMB 445 permitidos; SSH 22 e gestão 80 negados) com visitante (HTTP intranet e SMB internos negados, internet HTTPS permitida), mostrando os logs de bloqueio.
5. **Serviços de infraestrutura (30 s):** Chrony sincronizado com o pfSense, saída externa e como a configuração Automatic Outbound NAT encaminha a rede (reconhecer que os prints de ping não capturam o NAT em si).
6. **Zabbix (30 s):** ZBX verde no servidor e na estação; SNMP verde no pfSense; discutir métricas, alertas e o alerta remanescente no servidor.
7. **VPN (30 s):** no Windows, rota `10.0.20.0/24` por `10.0.50.1`, `tracert`, login SSH no servidor com origem `10.0.50.2`.

## Perguntas prováveis

**Por que separar as redes?** Princípio do menor privilégio e redução do movimento lateral: visitantes não entram em servidores ou gestão.

**Firewall é somente timeout?** Não. O teste combinou o timeout no cliente com *Block* no log da interface correspondente.

**Com que método o Zabbix monitora?** Agent 2 para Ubuntu e SNMP para pfSense, com indicadores verdes e dados recentes.

**Como sabem que a VPN foi usada?** A rota após remoção do caminho Host-only aponta para `10.0.50.1`; o login SSH do servidor identificou o cliente `10.0.50.2`.

**Os testes comprovam NAT?** Saída externa sim; para observar precisamente a tradução, usar Packet Capture WAN ou tabela de estados.

**VLANs 802.1Q existem na bancada?** Não há evidência de trunk. Cada segmento está conectado a uma Internal Network distinta do VirtualBox.

**O que será entregue?** `relatorio.pdf`, evidências organizadas e ZIP de acordo com o enunciado, com justificativas técnicas e referências.
