#!/usr/bin/env bash
# Testes de conectividade do laboratorio CELEPAR — executar na CELEPAR-ESTACAO.
set -u
pass=0; fail=0
check_tcp(){ local desc="$1" host="$2" port="$3" expected="$4"; if timeout 5 nc -z -w 3 "$host" "$port" >/dev/null 2>&1; then got=allow; else got=deny; fi; if [[ "$got" == "$expected" ]];then echo "PASS $desc ($host:$port = $got)"; pass=$((pass+1));else echo "FAIL $desc ($host:$port = $got, esperado $expected)";fail=$((fail+1));fi; }
check_tcp 'SMB interno permitido' 10.0.20.5 445 allow
check_tcp 'SSH interno bloqueado' 10.0.20.5 22 deny
check_tcp 'WebGUI de gestao bloqueada' 10.0.10.1 80 deny
check_tcp 'Intranet permitida' 10.0.20.10 80 allow
if nslookup intranet.celepar.local 10.0.30.1 2>/dev/null | grep -q '10.0.20.10'; then echo 'PASS DNS intranet';pass=$((pass+1));else echo 'FAIL DNS intranet';fail=$((fail+1));fi
if curl -sSI --max-time 5 http://10.0.20.10 | grep -q '^HTTP/.* 200';then echo 'PASS HTTP intranet 200';pass=$((pass+1));else echo 'FAIL HTTP intranet';fail=$((fail+1));fi
echo "Resumo: $pass aprovados; $fail falhas"; ((fail==0))
