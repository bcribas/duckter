#!/bin/bash

if [[ ! -d lorem ]]; then
  git clone https://github.com/per9000/lorem.git
  if [[ "$?" != "0" ]]; then
    printf "Erro clonando o lorem\n"
    exit 1;
  fi
fi

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
    local CHAVE=$(printf "$IT-$(date +%s)$i"|md5sum | cut -b1-20|tr -d '\n')
    local PAIS=${PAISES[$(($RANDOM%$PAISESCT))]}
    #echo "add key $CHAVE: $PAIS $(printf "$IT-$(date +%s)$i"|shasum)"
    echo "add key $CHAVE: $PAIS $(./lorem/lorem --foo -n $((RANDOM%MAXFRASES+5)) --randomize|tr -d '\n'|cut -b1-995)"
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
    local TAGNAME="$(printf "$PRE-$(date +%s)$i"|md5sum | cut -b1-20|tr -d '\n')"
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
  local TOTBUSCAS=$((${#HITEDTAGS[@]}*$1/100))
  echo ${HITEDTAGS[@]}|tr ' ' '\n'|sort -R| head -n $TOTBUSCAS| while read l; do
    echo "show tagcontent $l"
  done
}
