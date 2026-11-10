# Guia da bancada VirtualBox realmente utilizada

## VMs e interfaces

1. **CELEPAR-FW**: pfSense CE 2.9.0, cinco adaptadores: `em0` WAN VirtualBox NAT; `em1` Host-only 10.0.10.1; `em2` Internal Network `CELEPAR-V20` 10.0.20.1; `em3` Internal Network `CELEPAR-V30` 10.0.30.1; `em4` Internal Network `CELEPAR-V40` 10.0.40.1.
2. **CELEPAR-SRV**: Ubuntu Server, adaptador conectado `CELEPAR-V20`; endereços 10.0.20.5/24 e 10.0.20.10/24; gateway 10.0.20.1; Nginx, Samba, Zabbix, Chrony.
3. **CELEPAR-ESTACAO**: Ubuntu Desktop em `CELEPAR-V30`, endereço DHCP 10.0.30.50/24, gateway 10.0.30.1.
4. **CELEPAR-VISITANTE**: Ubuntu Desktop em `CELEPAR-V40`, endereço DHCP 10.0.40.50/24, gateway 10.0.40.1.
5. **Windows host**: 10.0.10.2 Host-only e 10.0.50.2 na VPN OpenVPN (se conectado).

As redes virtuais independentes evitam uso de trunk 802.1Q no laboratório; o projeto original de VLANs 802.1Q fica como referência teórica.

## Passos gerais, não roteiro de reinstalação cega

1. Criar as VMs e conferir os nomes das redes internas **exatamente iguais** nos dois lados de cada conexão.
2. Associar as cinco interfaces do pfSense às redes corretas e configurar os gateways IPv4 `/24`.
3. Habilitar escopos DHCP em ESTACOES e VISITANTES, sem incluir endereços fixos.
4. Configurar DNS Resolver (Unbound) no pfSense e host override `intranet.celepar.local` → 10.0.20.10.
5. Habilitar firewall por interface, de forma que ESTACOES acessam web e SMB, mas não SSH nem a WebGUI; VISITANTES saem para HTTPS externo, mas não acessam redes internas.
6. Usar Automatic Outbound NAT para o tráfego de saída, com verificação posterior pelo estado/captura WAN.
7. Configurar Chrony no servidor utilizando o pfSense `10.0.20.1` como fonte NTP.
8. Instalar Nginx na intranet `10.0.20.10`, Samba na porta 445 do servidor `10.0.20.5`.
9. Instalar Zabbix Server no servidor e Zabbix Agent 2 na estação, habilitando SNMP no pfSense. No agente da estação configurar `Server=10.0.20.5`, `ServerActive=10.0.20.5`, `Hostname=CELEPAR-ESTACAO`. Garantir que um único agente escute TCP 10050.
10. Configurar OpenVPN com túnel `10.0.50.0/24` e rota à rede de servidores; conferir que o Windows não mantém uma rota Host-only concorrente para `10.0.20.0/24`.

## Comandos de validação sem efeitos colaterais

Na estação:

```bash
ip -4 addr show enp0s3
nslookup intranet.celepar.local 10.0.30.1
curl -I http://10.0.20.10
nc -zv -w 3 10.0.20.5 445
nc -zv -w 3 10.0.20.5 22
nc -zv -w 3 10.0.10.1 80
```

No visitante:

```bash
ip -4 addr show enp0s3
curl -I https://example.com
curl -I --connect-timeout 3 http://10.0.20.10
nc -zv -w 3 10.0.20.5 445
```

No servidor:

```bash
chronyc tracking
ping -c 3 8.8.8.8
```

No PowerShell do Windows com OpenVPN conectado:

```powershell
Get-NetRoute -AddressFamily IPv4 -DestinationPrefix '10.0.20.0/24' | Select-Object DestinationPrefix,NextHop,InterfaceAlias,RouteMetric
tracert -d 10.0.20.5
ssh wauriciors@10.0.20.5
```

**Não subir credenciais ou arquivos `.ovpn` com chaves.** Consulte o catálogo de prints em `docs/validacao_laboratorio_2026-11-10.md`.
