# Roteiro e Guia de Defesa Oral (Professor Gabriel Candido) - v2.1

Este material orienta a equipe (Alexandre, Beatriz e Mauricio) durante a defesa presencial/oral. O foco e demonstrar como os servicos solicitados pelo professor (DHCP, DNS, Intranet com Requisicoes e VPN) foram incorporados com rigor tecnico, preservando a seguranca e o isolamento por firewall.

---

## 1. Visao Geral da Apresentacao da Defesa (3 a 5 minutos)

### Introducao
"Professor, a partir da arquitetura do relatorio da Celepar, implementamos a camada central de seguranca e servicos essenciais:
1. Firewall Stateful e Roteamento Inter-VLAN com controle rigoroso em Camada 4.
2. Servicos de Infraestrutura Basica: DHCP dinamico e DNS interno com resolucao do dominio celepar.local.
3. Zona de Servidores (VLAN 20): Hospeda o compartilhamento de arquivos (files.local), impressoras e o Servidor Web da Intranet com formulario funcional para requisicoes e chamados de T.I.
4. Acesso Remoto Seguro (VPN): Tunel criptografado para colaboradores remotos e administracao externa, sem expor portas desnecessarias na WAN."

---

## 2. Roteiro de Demonstracao Pratica

1. Apresentacao da Topologia e Gateways:  
   Demonstrar as 4 subinterfaces das VLANs e a sub-rede da VPN (10.0.50.0/24).
2. Demonstracao da Intranet na VLAN 20:  
   - Acessar o navegador na VLAN 30 (Estacao) no endereco http://intranet.celepar.local (ou http://10.0.20.10). A aplicacao carrega normalmente.
   - Acessar o mesmo endereco a partir do computador da VLAN 40 (Visitante). O firewall descarta os pacotes e a conexao e rejeitada.
3. Demonstracao do Servidor de Arquivos:  
   - Na VLAN 30, testar a porta 445 (SMB) -> Conexao estabelecida.
   - No mesmo terminal, tentar porta 22 (SSH) no servidor -> Conexao bloqueada.
4. Demonstracao da Protecao da Gerencia (VLAN 10):  
   - Enviar requisicao ICMP para 10.0.10.1 a partir da estacao ou do visitante -> Pacotes descartados pelo firewall.
5. Demonstracao da Resolucao DNS e DHCP:  
   - Exibir a estacao recebendo configuracao IP dinamica (10.0.30.x) e resolvendo intranet.celepar.local para 10.0.20.10.

---

## 3. Questoes Provaveis da Arguicao Tecnica

### Pergunta 1: "Por que alocar o Servidor Web da Intranet na VLAN 20 em vez de uma DMZ publica?"
Resposta:  
"Uma DMZ publica e destinada a servicos que precisam ser alcancados diretamente por qualquer usuario da internet. No nosso cenario, a Intranet e corporativa e restrita a colaboradores e operacao interna. Aloca-la na VLAN 20 assegura que o acesso fique restrito as estacoes corporativas autenticadas e usuarios de VPN, mantendo a aplicacao totalmente invisivel e protegida contra a rede de visitantes e a internet externa."

### Pergunta 2: "Como o DNS opera para os visitantes e para os funcionarios?"
Resposta:  
"Adotamos uma abordagem de resolucao condicional:
- Os colaboradores da VLAN 30 utilizam o DNS interno, que resolve os nomes corporativos (intranet.celepar.local e files.local) e encaminha consultas externas recursivamente para a internet.
- Os visitantes da VLAN 40 recebem via DHCP servidores DNS publicos ou uma configuracao restrita que nao resolve a zona interna, impedindo o reconhecimento e mapeamento da estrutura corporativa."

### Pergunta 3: "Se a WAN bloqueia conexoes de entrada por padrao, como a VPN consegue se conectar de fora?"
Resposta:  
"O firewall possui uma regra de excecao explicita na interface WAN restrita unicamente a porta UDP 1194, destinada ao servico OpenVPN do gateway. Qualquer outra tentativa de entrada e descartada pela regra padrao de bloqueio. O tunel so e liberado apos autenticacao com chave e certificado digital TLS. Uma vez conectado, o cliente recebe um IP da faixa 10.0.50.0/24, sujeitando-se as politicas internas do firewall."

### Pergunta 4: "O que impede um usuario da VLAN 40 de configurar um IP estatico da VLAN 30 para tentar burlar o firewall?"
Resposta:  
"A seguranca esta ancorada na associacao fisica de portas e nas tags 802.1Q dos switches. Quando um usuario se conecta em uma porta de acesso da VLAN 40, todo o trafego emitido por ele recebe a tag 40 na camada de enlace. Mesmo alterando o endereco IP localmente, os pacotes alcancam a subinterface VLAN 40 do roteador/firewall, sendo filtrados pelas regras da VLAN 40 e bloqueados por politicas de anti-spoofing."

### Pergunta 5: "Qual a finalidade do sistema de requisicao integrado a Intranet?"
Resposta:  
"Ele atua como a interface de aplicacao para os colaboradores da Celepar solicitarem suporte tecnico, permissoes a pastas de rede e liberacao de acessos. Demonstra na pratica como servicos de aplicacao operam suportados e protegidos pela infraestrutura de rede e pelas politicas de firewall implementadas."
