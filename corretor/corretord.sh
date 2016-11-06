#!/bin/bash

HOJE=$(date +"%Y-%m-%d")
TMPFILE=$(mktemp)

echo "Sincronizando Fontes"
rsync -aHx recebetrabalho@trinium.naquadah.com.br:entrega/submissions/*.c exec/

echo "Enviar status de processando"
echo 'processing' > /tmp/status
scp /tmp/status recebetrabalho@trinium.naquadah.com.br:entrega/results/status.txt

FIMSYNC=$(date +%s)

make bin

make hoje > tabelas/tabelas-$HOJE.t2t

AGORA=$(date +%s)

printf "Aguardando tempo minimo de 60s"
while (( AGORA - FIMSYNC < 60 )); do
  printf "."
  sleep 5
  AGORA=$(date +%s)
done
echo

echo 'idle' > /tmp/status.txt
scp /tmp/status.txt tabelas/tabelas-$HOJE.t2t recebetrabalho@trinium.naquadah.com.br:entrega/results