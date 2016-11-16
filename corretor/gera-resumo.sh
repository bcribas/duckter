#!/bin/bash

make bin -k
for i in entradas/*in; do
  ARQ="$(basename $i .in)"
  SMALL="$(cut -d '-' -f 2- <<< "$ARQ")"
  if [[ "$ARQ" == "$(date +"%Y-%m-%d")" ]]; then
    break
  fi
  cd exec && IGNORECACHE=1 bash ../../sols/run-tests.sh ../entradas/$ARQ.in
  cd ..
done

printf "\n\n\n"

echo "=RESUMO GERAL ="
TOTCOL=2
printf "| %-35s |" "Nome"
for i in entradas/*in; do
  ARQ="$(basename $i .in)"
  SMALL="$(cut -d '-' -f 2- <<< "$ARQ")"
  if [[ "$ARQ" == "$(date +"%Y-%m-%d")" ]]; then
    break
  fi
  printf " %8s |" "$SMALL"
  ((TOTCOL++))
done

printf " %12s |\n" "Score Total"

declare -A SCORESSIMPLES
declare -A SCORESIMPLES
for bin in exec/ssimples.O0 exec/simples.O2; do
  BIN=$(basename $bin)
  TOTSCORE=0
  SCORE=0
  for in in entradas/*in; do
    ARQ="$(basename $in )"
    if [[ "$ARQ" == "$(date +"%Y-%m-%d")" ]]; then
      break
    fi
    #2016-11-12.in.ca1fb365.e.last.is
    if test -e exec/$ARQ.$BIN.last.is && grep -q "correto" exec/$ARQ.$BIN.last.is; then
      SCORE=$(awk -F '|' '{print $(NF-2)}' exec/$ARQ.$BIN.last)
      SCORE="${SCORE// }"
      TOTSCORE=$(echo "$TOTSCORE+$SCORE"|bc)
    else
      SCORE="- -"
    fi
    if [[ "$BIN" == "ssimples.O0" ]]; then
      SCORESSIMPLES[$ARQ]=$SCORE
    else
      SCORESIMPLES[$ARQ]=$SCORE
    fi
  done

done

for bin in exec/*.e exec/*.epp exec/*O0 exec/*O2; do
  BIN=$(basename $bin)
  TOTSCORE=0
  NOME=$BIN
  if [[ -e "../entrega/passwd" ]]; then
    N="$(cut -d'.' -f1 <<< "$BIN")"
    NOME="$(grep "^$N:" ../entrega/passwd|cut -d':' -f3)"
  fi
  SCORE=0
  if grep -q -i "simples" <<< "$BIN"; then
    tput setab 7
    tput setaf 0
    tput bold
  fi
  SSIMPLESCORRETOS="0"
  SIMPLESCORRETOS="0"
  ERRADOS=0
  printf "| %-35s |" "$NOME"
  for in in entradas/*in; do
    ARQ="$(basename $in )"
    if [[ "$ARQ" == "$(date +"%Y-%m-%d").in" ]]; then
      break
    fi
    #2016-11-12.in.ca1fb365.e.last.is
    if test -e exec/$ARQ.$BIN.last.is && grep -q "correto" exec/$ARQ.$BIN.last.is; then
      SCORE=$(awk -F '|' '{print $(NF-2)}' exec/$ARQ.$BIN.last)
      SCORE="${SCORE// }"
      TOTSCORE=$(echo "$TOTSCORE+$SCORE"|bc)
      SSIMPLESCORRETOS+="+${SCORESSIMPLES[$ARQ]}"
      SIMPLESCORRETOS+="+${SCORESIMPLES[$ARQ]}"
    else
      SCORE="- -"
      ((ERRADOS++))
      TOTSCORE=$(echo "$TOTSCORE+1000+${SCORESSIMPLES[$ARQ]}+${SCORESIMPLES[$ARQ]}"|bc)
    fi
    printf " %8s |" "$SCORE"
  done
  FIML=""
  if grep -q -i "simples" <<< "$BIN"; then
    FIML="$(tput sgr0)"
  fi
  if ((ERRADOS == 0 )); then
    printf " %12s |$FIML\n" "$TOTSCORE"
  else
    printf " %12s |$FIML\n" "$TOTSCORE"
  fi
done | sort -n -t '|' -k $((1+TOTCOL))

echo
echo "-- Gerado em $(date -R)"
