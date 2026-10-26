# Registro de Alteracoes (Changelog) - Projeto Celepar
Disciplina: Redes de Computadores - 4o Periodo (IFPR)  
Equipe: Alexandre Raphael Marques de Freitas, Beatriz Regina Nahas, Mauricio Rockembach dos Santos  

---

## [v2.1] - 2026-10-26 (Integracao de Servicos Corporativos e Acesso Remoto)

### Motivacao da Atualizacao
Atendimento aos requisitos complementares validados pelo professor Gabriel Candido, integrando servicos de infraestrutura (DHCP e DNS), servicos de aplicacao (Portal Web Intranet com Sistema de Requisicoes de T.I.) e acesso remoto seguro (VPN), mantendo a integridade do modelo de seguranca, segmentacao de VLANs e firewall stateful da versao v2.0.

---

### Tabela Comparativa de Mudancas: v2.0 -> v2.1

| Recurso                 | v2.0 (Anterior)    | v2.1 (Atualizada)                                  |
|-------------------------|--------------------|----------------------------------------------------|
| Servicos VLAN 20        | Apenas SMB e IPP   | Servidor Web Intranet e Requisicoes (10.0.20.10:80)|
| DNS                     | Conceito generico  | Zona celepar.local (intranet, files e router)      |
| DHCP                    | Citado no texto    | Escopos com exclusoes para VLAN 30 e 40            |
| VPN                     | Nao especificada   | OpenVPN UDP 1194 com sub-rede 10.0.50.0/24         |
| Firewall (VLAN 30 -> 20)| Libera 445 e 631   | Libera 445, 631, 80 e 443 (Intranet Celepar)       |
| Firewall (VPN)          | Inexistente        | Acesso restrito a Servidores e Gerencia (Admin)    |
| Visitantes (VLAN 40)    | Bloqueado em SMB   | Isolamento total mantido (sem acesso a Intranet)   |
| Testes Automatizados    | SMB e Ping         | Adicionado teste HTTP na Intranet                  |

---

## [v2.0] - 2026-10-23 (Versao Base Teorica)
- Dimensionamento de cabeamento estruturado e infraestrutura fisica para 96 estacoes na Celepar.
- Planejamento de 4 VLANs: 10 (Gerencia), 20 (Servidores), 30 (Estacoes) e 40 (Visitantes).
- Definicao da Matriz de Regras de Firewall (Tabela 3) e estimativa de custos.
