#!/bin/bash

RUNS=0

while true; do
  HOJE=$(date +"%Y-%m-%d")
  echo "Enviar status de processando"
  echo 'processing' > /tmp/status
  scp /tmp/status recebetrabalho@trinium.naquadah.com.br:entrega/results/status.txt

  echo "Sincronizando Fontes"
  rsync -aHx recebetrabalho@trinium.naquadah.com.br:entrega/submissions/*.c exec/


  FIMSYNC=$(date +%s)

  make bin

  printf "make hoje"
  make hoje > tabelas/tabelas-$HOJE.t2t
  printf "\n\n" >> tabelas/tabelas-$HOJE.t2t
  echo '.'

  AGORA=$(date +%s)

  printf "Aguardando tempo minimo de 65s"
  while (( AGORA - FIMSYNC < 65 )); do
    printf "."
    sleep 5
    AGORA=$(date +%s)
  done
  echo

  echo 'idle' > /tmp/status.txt

  TOSLEEP=$((1800 + RANDOM%9000))
  NEXTROUND="$(date --date="$TOSLEEP sec")"
  if [[ "$(date --date="$TOSLEEP sec" +"%Y-%m-%d")" != "$HOJE" ]]; then
    NEXTROUND="$(date --date="tomorrow 00:00:00")"
    TOSLEEP=$(( $(date --date="tomorrow 00:00:00" +%s) - $AGORA +10))
    RUNS=-1

    #preparar para permitir download das entradas
    HASHDODIA=$(md5sum entradas/${HOJE}.in|awk '{print $1}')
    HASHSMALL=$RANDOM
    if ! grep -q "^$HASHDODIA " entradas-hash; then
      echo "$HASHDODIA $HOJE-$HASHSMALL" >> entradas-hash
    fi
    todownload=~/utfpr/pagina/aed1/2016-2/trabalho1/entradas/$HOJE-$HASHSMALL.in
    if [[ ! -e "${todownload}.xz" ]]; then
      cp -a "entradas/${HOJE}.in" "$todownload"
      xz "${todownload}"
    fi
    sed -i "/Timelimit = /i \
- Hash para download do arquivo: $HASHDODIA" tabelas/tabelas-$HOJE.t2t
    printf "Sync Pagina"
    bash ~/utfpr/syncwww
    echo '.'
  fi

  #RUNS=0 significa a primeira rodada do dia
  if [[ "$RUNS" == "0" ]]; then
    cat tabelas/*-2016*.t2t > tabelas/tabelas-consolidadas.t2t
  fi

  echo "$NEXTROUND" > /tmp/nextround.txt

  rsync -zaHx entradas-hash /tmp/status.txt /tmp/nextround.txt tabelas/*.t2t recebetrabalho@trinium.naquadah.com.br:entrega/results

  echo '8<----------------------------------------------------------'
  cat tabelas/tabelas-$HOJE.t2t
  echo '8<----------------------------------------------------------'
  echo "Dormir até: $NEXTROUND"
  sleep $TOSLEEP
  ((RUNS++))
done
