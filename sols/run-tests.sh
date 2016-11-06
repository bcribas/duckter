#!/bin/bash

INPUT=$1
sample=$INPUT
BASENAME="$(basename $sample)"
TMPFILE=$(mktemp)

function executa()
{
  local ENTRADA=$1
  local BIN=$2
  local TEMPLATE=$TMPFILE-$BIN-$RANDOM

  #verifica se ja existe execucao para esta entrada
  if [[ -e ${BASENAME}.$BIN.sol ]]; then
    if [[ "${BASENAME}.$BIN.sol" -nt "$BIN" ]]; then
      rm -f "${BASENAME}.$BIN.certos"
      TEMPLATE="${BASENAME}.$BIN"
      echo $TEMPLATE
      return
    fi
  fi

  if [[ "$HOSTNAME" == "jaguapitanga" ]]; then
    cp $BIN ~/.local/share/lxc/duckterrunner/rootfs/tmp/
    lxc-attach -n duckterrunner -- /root/executa.sh /tmp/$BIN $TL < $ENTRADA > $TEMPLATE.sol 2> $TEMPLATE.tempo
  else
    echo "=== CUIDADO, AMBIENTE NAO SEGURO DE EXECUCAO ===" >&2
    /usr/bin/time -f "%M %e" ./$BIN < $ENTRADA > $TEMPLATE.sol 2> $TEMPLATE.tempo
  fi
  for i in sol tempo; do
    cp ${TEMPLATE}.$i ${BASENAME}.$BIN.$i
  done

  echo $TEMPLATE
}

function verificaresposta()
{
  local SOL=$1
  local GABARITO=$2
  local RESP=Accepted
  if diff $GABARITO $SOL &>/dev/null; then
    RESP="Aceito"
  elif diff -bB $GABARITO $SOL &>/dev/null; then
    RESP="Erro de Apresentação"
  else
    RESP="Resposta Errada"
  fi
  echo $RESP
  return
}

function imprimelinha()
{
  local NOME="$1"
  local MEMORIAMEGA="$2"
  local TEMPO="$3"
  local SCORE="$4"
  local MD5="$5"

  if grep -q -i "Simples" <<< "$NOME"; then
    tput setab 7
    tput setaf 0
    tput bold
  fi
  if grep -q -i "ANTERIOR" <<< "$MD5"; then
    tput setaf 1
  fi

  printf "| %-35s | %10s | %7s | %10s | %-34s |$(tput sgr 0)\n" "$NOME"\
          "$MEMORIAMEGA MB" "$TEMPO" "$SCORE" "$MD5"
}

function geralinha()
{
  local TEMPLATE=$1
  local BIN=$2
  local NOME=$BIN
  if [[ -e "../../entrega/passwd" ]]; then
    local N="$(cut -d'.' -f1 <<< "$BIN")"
    NOME="$(grep "^$N:" ../../entrega/passwd|cut -d':' -f3)"
  fi

  if [[ ! -e "$BIN" ]]; then
    STATUS="Erro de Compilacao"
    imprimelinha "$NOME" "- -" "- -" "- -" "$STATUS" >> ${TMPFILE}.errados
    return
  fi

  read MEMORIA TEMPO <<< "$(tail -n1 $TEMPLATE.tempo)"

  local MEMORIAMEGA=$(echo "scale=2;$MEMORIA/1024"|bc -l)

  local STATUS="$(verificaresposta $TEMPLATE.sol $SSIMPLES.sol)"

  if ! wc -l ${TEMPLATE}.tempo|grep -q '^1 '; then
    STATUS="$(head -n1 $TEMPLATE.tempo)"
    if echo "$TEMPO > $TL"| bc|grep -q '^1'; then
      STATUS="Tempo Limite de Execução Excedido"
      TEMPO="TLE"
    fi
    imprimelinha "$NOME" "- -" "$TEMPO" "- -" "$STATUS" >> ${TMPFILE}.errados
    return
  fi

  if [[ "$STATUS" != "Aceito" ]]; then
    imprimelinha "$NOME" "- -" "$TEMPO" "- -" "$STATUS" >> ${TMPFILE}.errados
    return
  fi

  local SCORE=$(echo "scale=2;($MEMORIAMEGA*10+100*$TEMPO)/110"|bc -l)
  local MD5="$(md5sum $TEMPLATE.sol|awk '{print $1}')"
  imprimelinha "$NOME" "$MEMORIAMEGA MB" "$TEMPO" "$SCORE" "$MD5" >> ${TMPFILE}.certos
  if [[ -e ${BASENAME}.$BIN.certos ]]; then
    cat ${BASENAME}.$BIN.certos >> ${TMPFILE}.certos
  fi
  imprimelinha "$NOME" "$MEMORIAMEGA" "$TEMPO" "$SCORE" "Versao ANTERIOR"  > ${BASENAME}.$BIN.certos

}

echo "=$(basename $sample)="

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
((SOSEGUNDOS+=SOSEGUNDOS/2))
TL=$SOSEGUNDOS
ulimit -t $((SOSEGUNDOS+30))
echo "- Timelimit = $TL"
echo "- Corretos:"

printf "| %-35s | %10s | %7s | %10s | %-34s |\n" "Executavel" "Tam. MB" \
        "Tempo" "Score" "MD5 da Saida"

for O in e epp O0 O2 O3; do
  for bin in *.$O; do
    if [[ ! -e "$bin" ]]; then
      continue;
    fi
    if [[ "$bin" == "ssimples.O0" ]]; then
      geralinha $SSIMPLES $bin
      continue
    fi
    ARQ=$(executa $INPUT $bin)
    geralinha $ARQ $bin
  done
done

cat $TMPFILE.certos| sort -t'|' -k2 | sort -s -n -t'|' -k5
echo
echo
echo "- Errados"

#procura por erros de compilacao
for i in *.c; do
  if [[ ! -e "$i" ]]; then
    continue
  fi
  BINSERIA=$(basename $i .c).e
  if [[ ! -e $BINSERIA ]]; then
    geralinha falso $BINSERIA
  fi
done

if [[ ! -e "${TMPFILE}.errados" ]]; then
  echo "ninguem aqui :)"
else
  cat ${TMPFILE}.errados
fi

echo
echo "-- Gerado em $(date -R)"

rm ${TMPFILE}*
