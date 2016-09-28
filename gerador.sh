#!/bin/bash

if [[ ! -d lorem ]]; then
  git clone https://github.com/per9000/lorem.git
  if [[ "$?" != "0" ]]; then
    printf "Erro clonando o lorem\n"
    exit 1;
  fi
fi

#gerar um arquivo simples

PAISES=(ROU ESA BHU PHI BRA RWA ERI SSD DJI GUI BRA)

declare -a CHAVES
chavescount=0
declare -a TAGS
tagscount=0;

function addchaves()
{
  local QTD=$1
  local IT=$2
  for((i=0;i<$QTD;i++)); do
    CHAVE=$(printf "$IT-$(date +%s)$i"|md5sum | cut -b1-8|tr -d '\n')
    PAIS=${PAISES[$(($RANDOM%11))]}
    echo "add key $CHAVE: $PAIS $(./lorem/lorem --poe -n 5 --randomize)"
    CHAVES[$chavescount]=$CHAVE
    ((chavescount++))
  done
}

function addtags()
{
  QTD=$1
  PRE=$2
  for((i=0;i<$QTD;i++)); do
    TAGNAME="$(./lorem/lorem -n 1 --randomize)"
    printf "add tag #$TAGNAME ${CHAVES[$(($RANDOM%${#CHAVES[@]}))]}\n"
    TAGS[$tagscount]="#$TAGNAME"
    ((tagscount++))
  done
}

function buscatags()
{
  local TOTBUSCAS=$((tagscount/$1))
  echo ${TAGS[@]}|tr ' ' '\n'|sort -R| head -n $TOTBUSCAS| while read l; do
    echo "search tag content $l"
  done
}

#criar 100 chaves
addchaves 100 A

#adicionar 50 tags
addtags 50 A

#fazer buscas em 10% das tags
buscatags 10

#adicionar mais 50 chaves
addchaves 50 B

#buscar top 10 tags
echo "list tranding top 10"
