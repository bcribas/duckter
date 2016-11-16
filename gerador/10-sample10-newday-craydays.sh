#!/bin/bash

POSSIBILIDADES=(q w e r t y u i o p a s d f g h j k l z x c v b n m Q W E R T Y U I O P A S D F G H J K L Z X C V B N M 1 2 3 4 5 6 7 8 9 0)
POSSIBILIDADESTAM=${#POSSIBILIDADES[@]}
FRASAO=
for((i=0;i<1000;i++)); do
  FRASAO+=${POSSIBILIDADES[$((RANDOM%62))]}
done


#gerar um arquivo simples

PAISES=($(awk '{print $1}' ../paises|tr '\n' ' '))
PAISESCT=${#PAISES[@]}

declare -a CHAVES
chavescount=0
declare -a TAGS
declare -A TAGSREF
declare -A HITEDTAGS
tagscount=0;

function gerarandom()
{
  local P=$((RANDOM%9+1))
  echo $P$RANDOM$RANDOM$RANDOM
}

function addchaves()
{
  local QTD=$1
  local IT=$2
  local MAXFRASES=$3
  local i=0
  if [[ "$MAXFRASES" == "" ]]; then
    MAXFRASES=5
  fi
  for((i=0;i<$QTD;i++)); do
    TAMKEY=$((6+RANDOM%34))
    local CHAVE=$(printf "$IT-$(date +%s)$i"|sha1sum | cut -b1-$TAMKEY|tr -d '\n')
    local PAIS=${PAISES[$(($RANDOM%$PAISESCT))]}
    #echo "add key $CHAVE: $PAIS $(printf "$IT-$(date +%s)$i"|shasum)"
    echo "add key $CHAVE: $PAIS $(echo $FRASAO|cut -b1-$((1+RANDOM%MAXFRASES)))"
    CHAVES[$chavescount]=$CHAVE
    ((chavescount++))
  done
}

function gentags()
{
  local QTD=$1
  local PRE=$2
  local i=0
  for((i=0;i<$QTD;i++)); do
    TAMTAG=$((6+RANDOM%34))
    local TAGNAME="$(printf "$PRE-$(date +%s)$i"|sha1sum | cut -b1-$TAMTAG|tr -d '\n')"
    local TOKEY="${CHAVES[$(($(gerarandom)%${#CHAVES[@]}))]}"
    #printf "tag hit #$TAGNAME $TOKEY\n"
    TAGS[$tagscount]="#$TAGNAME"
    TAGSREF["#$TAGNAME"]="$TOKEY"
    ((tagscount++))
  done
}

function taghit()
{
  local QTD=$1
  local i=0
  for((i=0;i<$QTD;i++)); do
    local TAGNAME="${TAGS[$(($(gerarandom)%tagscount))]}"
    local TOKEY="${TAGSREF["$TAGNAME"]}"
    HITEDTAGS["$TAGNAME"]="$TAGNAME"
    printf "tag hit $TAGNAME $TOKEY\n"
  done

}

function buscatags()
{
  local TOTBUSCAS=$((1+${#HITEDTAGS[@]}*$1/100))
  echo ${HITEDTAGS[@]}|tr ' ' '\n'|shuf| head -n $TOTBUSCAS| while read l; do
    echo "show tagcontent $l"
  done
}

ITERACOES=3

for((k=0;k<ITERACOES;k++)); do
  addchaves 10 $RANDOM 30 > /tmp/tt
  shuf /tmp/tt
  gentags 300 $RANDOM
  taghit 50  > /tmp/tt
  echo new day >> /tmp/tt
  echo new day >> /tmp/tt
  echo new day >> /tmp/tt
  shuf /tmp/tt
done

echo dump keys
echo dump tags
