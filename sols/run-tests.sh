#!/bin/bash

INPUT=$1
sample=$INPUT
TMPFILE=$(mktemp)

echo "--> $sample"
printf "| %-15s | %10s | %7s | %10s | %-32s |\n" "Executavel" "Tam. MB" \
        "Tempo" "Score" "MD5 da Saida"
for O in e O0 O2 O3; do
  for bin in *.$O; do
    #if grep -q ssimples <<< "$bin"; then continue; fi
    /usr/bin/time -f "%M %e" ./$bin < $sample > $TMPFILE.sol 2> $TMPFILE.tempo
    read MEMORIA TEMPO < $TMPFILE.tempo
    MEMORIAMEGA=$(echo "scale=2;$MEMORIA/1024"|bc -l)
    #((MEMORIA*=1024))
    SCORE=$(echo "scale=2;($MEMORIAMEGA*10+100*$TEMPO)/110"|bc -l)
    MD5="$(md5sum $TMPFILE.sol|awk '{print $1}')"
    printf "| %-15s | %10s | %7s | %10s | $MD5 |\n" "$bin"\
            "$MEMORIAMEGA MB" "$TEMPO" "$SCORE"
  done
done | sort -t'|' -k2 | sort -s -n -t'|' -k5
echo

rm $TMPFILE{,.sol,.tempo}
