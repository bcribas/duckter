#!/bin/bash
#This file is part of DUCKTER.
#
#DUCKTER is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#DUCKTER is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with DUCKTER.  If not, see <http://www.gnu.org/licenses/>.

make bin -k
declare -a ENTRADAS
ENTRADASCT=0

for i in entradas/*in; do
  ARQ="$(basename $i .in)"
  SMALL="$(cut -d '-' -f 2- <<< "$ARQ")"
  ENTRADAS[$ENTRADASCT]="$SMALL"
  ((ENTRADASCT++))
  if [[ "$ARQ" == "$(date +"%Y-%m-%d")" ]]; then
    break
  fi
  cd exec && IGNORECACHE=1 bash ../../sols/run-tests.sh ../entradas/$ARQ.in
  cd ..
done


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

declare -A SCORETOT

for((k=0;k<=ENTRADASCT/7;k++)); do
  printf "\n\n\n"
  echo "=RESUMO GERAL pt.$k="
  TOTCOL=2
  tput bold
  printf "| %-35s |" "Nome"
  ((i=k*7));
  ((fim=i+7));
  while (( i<fim )) && (( i < ENTRADASCT )); do
    ARQ="2016-${ENTRADAS[$i]}"
    SMALL="$(cut -d '-' -f 2- <<< "$ARQ")"
    if [[ "$ARQ" == "$(date +"%Y-%m-%d")" ]]; then
      break
    fi
    printf " %8s |" "$SMALL"
    ((TOTCOL++))
    ((i++))
  done

  if ((fim < ENTRADASCT-1 )); then
    printf " %12s|\n" "Score Parcial"
  else
    printf " %12s |\n" "Score Total"
  fi
  tput sgr 0


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
    ((in=k*7));
    ((fimin=in+7));
    while (( in<fimin )) && (( in < ENTRADASCT )); do
      ARQ="2016-${ENTRADAS[$in]}.in"
      if [[ "$ARQ" == "$(date +"%Y-%m-%d").in" ]]; then
        break
      fi
      #2016-11-12.in.ca1fb365.e.last.is
      if test -e exec/$ARQ.$BIN.last.is && grep -q "correto" exec/$ARQ.$BIN.last.is; then
        SCORE=$(awk -F '|' '{print $(NF-2)}' exec/$ARQ.$BIN.last)
        SCORE="${SCORE// }"
        TOTSCORE=$(echo "0${SCORETOT[$BIN]}+$SCORE"|bc)
        SCORETOT[$BIN]=$TOTSCORE
        SSIMPLESCORRETOS+="+${SCORESSIMPLES[$ARQ]}"
        SIMPLESCORRETOS+="+${SCORESIMPLES[$ARQ]}"
      else
        SCORE="- -"
        ((ERRADOS++))
        TOTSCORE=$(echo "0${SCORETOT[$BIN]}+${SCORESSIMPLES[$ARQ]}/2+${SCORESSIMPLES[$ARQ]}"|bc)
        SCORETOT[$BIN]=$TOTSCORE
      fi
      printf " %8s |" "$SCORE"
      ((in++))
    done
    FIML=""
    if grep -q -i "simples" <<< "$BIN"; then
      FIML="$(tput sgr0)"
    fi
    if ((ERRADOS == 0 )); then
      printf " %12s |$FIML\n" "${SCORETOT[$BIN]}"
    else
      printf " %12s |$FIML\n" "${SCORETOT[$BIN]}"
    fi
  done > /tmp/ordena
  sort -n -t '|' -k $((1+TOTCOL)) /tmp/ordena
done

echo
echo "-- Gerado em $(date -R)"
