#!/bin/bash

RUNS=0

while true; do
  HOJE=$(date +"%Y-%m-%d")
  echo "Sincronizando Fontes"
  rsync -aHx recebetrabalho@trinium.naquadah.com.br:entrega/submissions/*.c exec/

  echo "Enviar status de processando"
  echo 'processing' > /tmp/status
  scp /tmp/status recebetrabalho@trinium.naquadah.com.br:entrega/results/status.txt

  FIMSYNC=$(date +%s)

  make bin

  make hoje > tabelas/tabelas-$HOJE.t2t
  printf "\n\n" >> tabelas/tabelas-$HOJE.t2t

  AGORA=$(date +%s)

  printf "Aguardando tempo minimo de 65s"
  while (( AGORA - FIMSYNC < 65 )); do
    printf "."
    sleep 5
    AGORA=$(date +%s)
  done
  echo

  echo 'idle' > /tmp/status.txt

  NEXTROUND="$(date --date="3 hours")"
  TOSLEEP=3h
  if [[ "$(date --date="3 hours" +"%Y-%m-%d")" != "$HOJE" ]]; then
    NEXTROUND="$(date --date="tomorrow 00:00:00")"
    TOSLEEP=$(( $(date --date="tomorrow 00:00:00" +%s) - $AGORA +10))
    RUNS=-1
  fi

  #RUNS=0 significa a primeira rodada do dia
  if [[ "$RUNS" == "0" ]]; then
    cat tabelas/*-2016.t2t > tabelas/tabelas-consolidadas.t2t
  fi

  echo "$NEXTROUND" > /tmp/nextround.txt

  rsync -aHx /tmp/status.txt /tmp/nextround.txt tabelas/*.t2t recebetrabalho@trinium.naquadah.com.br:entrega/results

  sleep $TOSLEEP
  ((RUNS++))
done
