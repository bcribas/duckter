#!/bin/bash

RUNS=0

while true; do
  HOJE=$(date +"%Y-%m-%d")
  echo "Enviar status de processando"
  DSEMANA=$(date +%a)

  if [[ "$DSEMANA" == "Sun" || "$DSEMANA" == "Wed" ]] && [[ "$RUNS" == "1" ]]; then
    echo 'processando resumo' > /tmp/status.txt; echo 'check status' > /tmp/nextround.txt
  else
    echo 'processing' > /tmp/status.txt; echo 'check status' > /tmp/nextround.txt
  fi
  scp /tmp/status.txt /tmp/nextround.txt recebetrabalho@trinium.naquadah.com.br:entrega/results/

  echo "Sincronizando Fontes"
  rsync -aHx recebetrabalho@trinium.naquadah.com.br:entrega/submissions/* exec/


  FIMSYNC=$(date +%s)

  make bin -k

  if [[ "$DSEMANA" == "Sun" || "$DSEMANA" == "Wed" ]] && [[ "$RUNS" == "1" ]]; then
    bash gera-resumo.sh | tee tabelas/tabelas-resumo.t2t
  fi

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

  TOSLEEP=$((1800 + RANDOM%7200))
  if (( AGORA - FIMSYNC > 1800 ));then
    TOSLEEP=$((300 + RANDOM%1800))
  fi
  NEXTROUND="$(date --date="$TOSLEEP sec")"
  if [[ "$(date --date="$TOSLEEP sec" +"%Y-%m-%d")" != "$HOJE" ]]; then
    NEXTROUND="$(date --date="tomorrow 00:00:00")"
    TOSLEEP=$(( $(date --date="tomorrow 00:00:00" +%s) - $AGORA +10))
    if (( TOSLEEP > 10000 )); then
      TOSLEEP=120
      NEXTROUND="$(date --date="$TOSLEEP sec")"
    fi
    RUNS=-1

    #preparar para permitir download das entradas
    HASHDODIA=$(md5sum entradas/${HOJE}.in|awk '{print $1}')
    HASHSMALL=$RANDOM
    if ! grep -q "^$HASHDODIA " entradas-hash; then
      echo "$HASHDODIA $HOJE-$HASHSMALL" >> entradas-hash
      todownload=~/utfpr/pagina/aed1/2016-2/trabalho1/entradas/$HOJE-$HASHSMALL.in
      if [[ ! -e "${todownload}.xz" ]]; then
        cp -a "entradas/${HOJE}.in" "$todownload"
        chmod a+r "$todownload"
        xz "${todownload}"
      fi
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
