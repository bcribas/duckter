#!/bin/bash

INPUT=$1
sample=$INPUT
TMPFILE=$(mktemp)

function executa()
{
  local ENTRADA=$1
  local BIN=$2
  local TEMPLATE=$TMPFILE-$BIN-$RANDOM
  /usr/bin/time -f "%M %e" ./$BIN < $ENTRADA > $TEMPLATE.sol 2> $TEMPLATE.tempo
  echo $TEMPLATE
}

function geralinha()
{
  local TEMPLATE=$1
  local NOME=$2
  if ! wc -l ${TEMPLATE}.tempo|grep -q '^1 '; then
    printf "| %-15s | %10s | %7s | %10s | %-32s |\n" "$NOME"\
            "- -" "- -" "- -" "$(head -n1 $TEMPLATE.tempo)"
    return
  fi

  read MEMORIA TEMPO < $TEMPLATE.tempo
  MEMORIAMEGA=$(echo "scale=2;$MEMORIA/1024"|bc -l)

  SCORE=$(echo "scale=2;($MEMORIAMEGA*10+100*$TEMPO)/110"|bc -l)
  MD5="$(md5sum $TEMPLATE.sol|awk '{print $1}')"
  printf "| %-15s | %10s | %7s | %10s | $MD5 |\n" "$NOME"\
          "$MEMORIAMEGA MB" "$TEMPO" "$SCORE"
}

echo "--> $sample"

#Calibra tempo com ssimples.O0
SSIMPLES=$(executa $INPUT ssimples.O0)
if ! wc -l ${SSIMPLES}.tempo|grep -q '^1 '; then
  echo "Ops. ssimples.O0 falhou"
  cat ${SSIMPLES}.tempo
  exit 1
fi
read SSIMPLESMEM SSIMPLESTEMPO < $SSIMPLES.tempo
SOSEGUNDOS="$(cut -d'.' -f1 <<< "$SSIMPLESTEMPO")"
((SOSEGUNDOS+=60))
((SOSEGUNDOS*=2))
ulimit -t $SOSEGUNDOS
echo "  Timelimit = $SOSEGUNDOS"

printf "| %-15s | %10s | %7s | %10s | %-32s |\n" "Executavel" "Tam. MB" \
        "Tempo" "Score" "MD5 da Saida"

for O in e O0 O2 O3; do
  for bin in *.$O; do
    if [[ "$bin" == "ssimples.O0" ]]; then
      geralinha $SSIMPLES "Super Simples"
      continue
    fi
    ARQ=$(executa $INPUT $bin)
    geralinha $ARQ $bin
  done
done | sort -t'|' -k2 | sort -s -n -t'|' -k5
echo

rm ${TMPFILE}*
