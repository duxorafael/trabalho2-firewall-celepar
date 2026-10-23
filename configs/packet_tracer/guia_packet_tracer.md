# 🔌 Guia de Implementação no Cisco Packet Tracer

Caso a equipe prefira demonstrar a topologia no Packet Tracer ou manter como plano de contingência, siga este roteiro de montagem simples e rápida.

---

## 1. Dispositivos Necessários no Packet Tracer

* **1x Roteador:** Modelo `Cisco 2911` ou `1941` (Nome: `GW-FIREWALL-CELEPAR`).
* **1x Switch:** Modelo `Cisco Catalyst 2960` (Nome: `SW-CORE-CELEPAR`).
* **1x Servidor:** (Nome: `SRV-FILES`, simulando `10.0.20.5`).
* **3x PCs:**
  * `PC-TI-ADMIN` (Conectado na VLAN 10).
  * `PC-ESTACAO-TRABALHO` (Conectado na VLAN 30).
  * `PC-VISITANTE` (Conectado na VLAN 40).
* **1x Servidor Web Externo:** Conectado na porta `G0/1` do roteador simulando a WAN/Internet (`203.0.113.1`).

---

## 2. Conexões de Cabos
* Cabo direto entre `Roteador G0/0` e `Switch G0/1`.
* Cabo direto entre `Switch Fa0/10` e `PC-TI-ADMIN`.
* Cabo direto entre `Switch Fa0/20` e `SRV-FILES`.
* Cabo direto entre `Switch Fa0/30` e `PC-ESTACAO-TRABALHO`.
* Cabo direto entre `Switch Fa0/40` e `PC-VISITANTE`.

---

## 3. Configuração do Switch Cisco 2960

Abra a aba **CLI** do switch e cole os seguintes comandos para criar as VLANs e configurar o tronco:

```cisco
enable
configure terminal
hostname SW-CORE-CELEPAR

! Criar as 4 VLANs do projeto Celepar
vlan 10
 name GERENCIA
exit
vlan 20
 name SERVIDORES
exit
vlan 30
 name ESTACOES
exit
vlan 40
 name VISITANTES
exit

! Porta Trunk ligada ao Roteador (G0/0 do router -> G0/1 do switch)
interface GigabitEthernet0/1
 switchport mode trunk
 switchport trunk allowed vlan 10,20,30,40
 no shutdown
exit

! Associar portas de acesso às respectivas VLANs
interface FastEthernet0/10
 switchport mode access
 switchport access vlan 10
 no shutdown
exit

interface FastEthernet0/20
 switchport mode access
 switchport access vlan 20
 no shutdown
exit

interface FastEthernet0/30
 switchport mode access
 switchport access vlan 30
 no shutdown
exit

interface FastEthernet0/40
 switchport mode access
 switchport access vlan 40
 no shutdown
exit

end
write memory
```

---

## 4. Configuração do Roteador / Firewall

1. Abra a aba **CLI** do roteador.
2. Responda `no` caso apareça a pergunta de configuração guiada (*Continue with configuration dialog?*).
3. Abra o arquivo [`router_cisco_ios.cfg`](router_cisco_ios.cfg), copie todo o conteúdo e cole no terminal do roteador.

---

## 5. Como Testar no Packet Tracer

1. **Obter IP nos PCs:**
   - No `PC-ESTACAO-TRABALHO` e no `PC-VISITANTE`, vá em **Desktop ➔ IP Configuration** e selecione **DHCP**. Eles devem receber IPs da faixa `10.0.30.x` e `10.0.40.x` com sucesso.
   - No `SRV-FILES`, configure IP Estático: `10.0.20.5`, máscara `255.255.255.0`, Gateway `10.0.20.1`.
2. **Testes no Prompt de Comando (Desktop ➔ Command Prompt):**
   - **Do PC-VISITANTE:**
     - `ping 10.0.20.5` ➔ Deve dar **Request timed out** (Bloqueado pela ACL).
     - `ping 10.0.10.1` ➔ Deve dar **Request timed out** (Bloqueado).
     - Acessar `http://203.0.113.1` pelo **Web Browser** ➔ Deve carregar a página normalmente.
   - **Do PC-ESTACAO-TRABALHO:**
     - `ping 10.0.10.1` ➔ Deve dar **Request timed out** (VLAN 10 protegida).
     - No **Web Browser**, acessar o servidor de arquivos se tiver serviço HTTP ativo (ou usar o modo Simulation com pacotes TCP na porta 445).
