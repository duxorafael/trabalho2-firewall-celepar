#!/bin/bash
# ==============================================================================
# Script de validação automatizada de regras de firewall para estações Linux.
# Disciplina: Redes de Computadores - IFPR (Projeto Celepar)
# Autores: Alexandre, Beatriz e Maurício
# ==============================================================================

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}==========================================================${NC}"
echo -e "${CYAN}  TESTE AUTOMATIZADO DE FIREWALL - PROJETO CELEPAR (IFPR)  ${NC}"
echo -e "${CYAN}==========================================================${NC}"
echo ""

MEU_IP=$(hostname -I | awk '{print $1}')
echo -e "${YELLOW}[*] IP Atual da Máquina de Teste: ${MEU_IP}${NC}"
echo ""

function testar_porta() {
    local DESCRICAO="$1"
    local IP="$2"
    local PORTA="$3"
    local ESPERADO="$4" # 1 = Espera conectar, 0 = Espera bloquear

    echo -n "[-] Testando: ${DESCRICAO} (${IP}:${PORTA})... "
    nc -z -w 2 "$IP" "$PORTA" > /dev/null 2>&1
    local STATUS=$?

    if [ "$ESPERADO" -eq 1 ]; then
        if [ "$STATUS" -eq 0 ]; then
            echo -e "${GREEN}[PASSOU - CONECTADO]${NC}"
        else
            echo -e "${RED}[FALHOU - ERA PARA CONECTAR]${NC}"
        fi
    else
        if [ "$STATUS" -ne 0 ]; then
            echo -e "${GREEN}[PASSOU - BLOQUEADO COM SUCESSO]${NC}"
        else
            echo -e "${RED}[FALHOU - CONEXÃO NÃO DEVERIA ENTRAR]${NC}"
        fi
    fi
}

function testar_ping() {
    local DESCRICAO="$1"
    local IP="$2"
    local ESPERADO="$3"

    echo -n "[-] Testando Ping: ${DESCRICAO} (${IP})... "
    ping -c 2 -W 2 "$IP" > /dev/null 2>&1
    local STATUS=$?

    if [ "$ESPERADO" -eq 1 ]; then
        if [ "$STATUS" -eq 0 ]; then
            echo -e "${GREEN}[PASSOU - RESPONDEU]${NC}"
        else
            echo -e "${RED}[FALHOU - SEM RESPOSTA]${NC}"
        fi
    else
        if [ "$STATUS" -ne 0 ]; then
            echo -e "${GREEN}[PASSOU - DROPADO COM SUCESSO]${NC}"
        else
            echo -e "${RED}[FALHOU - PING NÃO DEVERIA RESPONDER]${NC}"
        fi
    fi
}

echo -e "${CYAN}--- INICIANDO TESTES ---${NC}"

# Teste 1: Regra 4 - Estações para Servidores (Porta 445 SMB)
testar_porta "Regra 4: Acesso ao Servidor de Arquivos (SMB 445)" "10.0.20.5" 445 1

# Teste 2: Regra 4 - Bloqueio de porta SSH no Servidor (SSH 22)
testar_porta "Regra 4: Bloqueio de SSH no Servidor (SSH 22)" "10.0.20.5" 22 0

# Teste 3: Regra 5 - Bloqueio de Ping e Web para a Gerência (10.0.10.1)
testar_ping "Regra 5: Bloqueio de Ping na Gerencia (10.0.10.1)" "10.0.10.1" 0
testar_porta "Regra 5: Bloqueio de Web Admin na Gerencia (Porta 80)" "10.0.10.1" 80 0

# Teste 4: Saída para a Internet (HTTPS 443)
testar_porta "Saida Internet: Conexao HTTPS (1.1.1.1:443)" "1.1.1.1" 443 1

echo ""
echo -e "${CYAN}==========================================================${NC}"
echo -e "${CYAN}  BATERIA DE TESTES FINALIZADA                            ${NC}"
echo -e "${CYAN}==========================================================${NC}"
