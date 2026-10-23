# 🎓 Roteiro e Guia de Defesa Oral (Professor Gabriel Candido)

Este material foi preparado para orientar a equipe (**Alexandre, Beatriz e Maurício**) durante a **defesa presencial/oral** do Trabalho 2. Não há slides — a avaliação é uma conversa técnica onde o professor avalia o domínio dos conceitos, a lógica das decisões e a execução prática.

---

## 🧭 Visão Estratégica da Apresentação da Defesa (3 a 5 minutos)

### 1. Introdução rápida (O que foi feito)
> *"Professor, pegamos a arquitetura proposta no Trabalho 1 para o escritório da Celepar e implementamos a camada mais crítica de segurança: o **Firewall e o Roteamento Inter-VLAN**.*  
> *Traduzimos a **Tabela 3** do relatório em regras reais de filtragem por pacotes (Camada 4) e estado de conexão, garantindo o princípio do menor privilégio entre os 96 postos, o servidor de arquivos corporativo, a gerência e os visitantes."*

### 2. Demonstração Prática (Ao vivo)
Tenha a topologia aberta (seja no pfSense/VirtualBox ou no Packet Tracer).
1. **Mostrar as Interfaces/VLANs:** Mostrar os 4 gateways configurados (`10.0.10.1`, `20.1`, `30.1`, `40.1`).
2. **Mostrar as Regras Ordenadas:** Explicar que o firewall avalia as regras de cima para baixo (*first match wins*).
3. **Executar a bateria de testes:**
   - Abrir o terminal da **VLAN 30 (Estação)** e testar porta 445 no Servidor (`10.0.20.5`) ➔ **Passa**.
   - No mesmo terminal, tentar pingar ou abrir SSH na porta 22 do Servidor ➔ **Bloqueado**.
   - No terminal da **VLAN 40 (Visitante)**, tentar pingar qualquer IP interno `10.0.x.x` ➔ **Bloqueado**.
   - No terminal da **VLAN 40**, tentar navegar para um IP/site externo (porta 80/443) ➔ **Passa**.
   - Tentar acessar a interface do gateway `10.0.10.1` a partir da estação ➔ **Bloqueado**.

---

## ❓ Perguntas Típicas do Professor e Como Responder

### Pergunta 1: *"Por que vocês bloquearam a VLAN 10 para todo mundo? Como o administrador acessa os equipamentos?"*
* **Resposta Ideal:**  
  > *"A VLAN 10 é a rede de Gerenciamento Out-of-Band da Celepar. Nela estão os painéis web dos switches, APs e do roteador. Se qualquer estação de trabalho tivesse acesso, uma máquina infectada com malware ou um funcionário mal-intencionado poderia tentar brute-force no switch. O administrador de redes acessa a VLAN 10 conectando um notebook físico diretamente na porta dedicada do rack da Sala de T.I. ou através de uma estação autorizada com IP fixo ou VPN administrativa."*

### Pergunta 2: *"Na Regra 3, vocês bloqueiam todo o tráfego da WAN para a rede interna. Se a WAN é bloqueada, como os computadores conseguem navegar e receber as páginas web de volta?"*
* **Resposta Ideal:**  
  > *"Porque o firewall opera como **Stateful Packet Inspection (SPI)**. Quando um cliente interno da VLAN 30 inicia uma conexão saindo pela porta 443 para a WAN, o firewall registra essa sessão na tabela de estados (conntrack). Quando o servidor web externo responde, o firewall reconhece que aquele pacote pertence a um estado `ESTABLISHED/RELATED` e permite a entrada. A Regra 3 bloqueia apenas conexões **iniciadas externamente** que não foram solicitadas por ninguém de dentro."*

### Pergunta 3: *"Por que colocar portas específicas (445 e 631) entre a VLAN 30 e a VLAN 20 em vez de liberar todo o tráfego TCP?"*
* **Resposta Ideal:**  
  > *"Pelo **princípio do menor privilégio**. As estações de trabalho dos 96 colaboradores da Celepar só precisam abrir arquivos na rede (porta SMB 445) e enviar impressões (porta IPP 631). Se liberássemos todo o tráfego TCP, qualquer vulnerabilidade em outros serviços do servidor (como SSH, banco de dados ou painel de gerenciamento) ficaria exposta a varreduras vindas da rede de estações."*

### Pergunta 4: *"Qual a diferença entre uma regra no switch (ACL L2/L3) e no firewall/roteador central?"*
* **Resposta Ideal:**  
  > *"O switch camada 2 apenas faz o isolamento de broadcast separando as tags 802.1Q. Quando o pacote precisa passar de uma VLAN para outra (inter-VLAN routing), ele obrigatoriamente sobe pelo enlace trunk para o gateway/firewall. É no gateway que ocorre a inspeção de camada 3 (endereço IP) e camada 4 (portas TCP/UDP), aplicando as regras da nossa matriz antes de encaminhar o pacote de volta para o switch."*

### Pergunta 5: *"O que acontece se uma regra de 'Bloquear Tudo' ficar no topo da lista de regras?"*
* **Resposta Ideal:**  
  > *"O firewall realiza o casamento de regras sequencialmente (*top-down*). Se uma regra abrangente de 'Drop Any' estiver no topo, ela será acionada imediatamente e descartará o pacote antes que o firewall consiga ler as regras de permissão abaixo dela. Por isso, as regras mais específicas (permissões por porta) ficam acima, e o bloqueio geral (*Default Drop*) fica no final."*

---

## 💡 Dicas de Postura para a Defesa
- **Segurança ao falar:** Usem os termos técnicos corretos: *trunk 802.1Q*, *router-on-a-stick*, *stateful inspection*, *default drop*, *least privilege*.
- **Divisão entre os três:** Qualquer um dos três deve saber explicar tanto a topologia quanto o teste. Se o professor apontar para a Beatriz ou para o Maurício perguntando sobre a porta 445 ou o isolamento da VLAN 40, a resposta deve estar na ponta da língua com base neste roteiro.
