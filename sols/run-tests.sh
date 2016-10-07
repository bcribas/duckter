#!/bin/bash

INPUT=$1
sample=$INPUT

echo "--> $sample"
printf "| %-15s | %7s | %7s | %10s | %-32s |\n" "Executavel" "Tam. MB" \
        "Tempo" "Score" "MD5 da Saida"
for O in O0 O2 O3; do
  for bin in *.$O; do
    #if grep -q ssimples <<< "$bin"; then continue; fi
    /usr/bin/time -f "%M %e" ./$bin < $sample > /tmp/sol 2> /tmp/tempo
    read MEMORIA TEMPO < /tmp/tempo
    ((MEMORIAMEGA=MEMORIA/1024))
    #((MEMORIA*=1024))
    SCORE=$(echo "$MEMORIAMEGA*100*$TEMPO"|bc)
    MD5="$(md5sum /tmp/sol|awk '{print $1}')"
    printf "| %-15s | %7s | %7s | %10s | $MD5 |\n" "$bin"\
            "$MEMORIAMEGA MB" "$TEMPO" "$SCORE"
  done
done | sort -t'|' -k2 | sort -s -n -t'|' -k5
echo
