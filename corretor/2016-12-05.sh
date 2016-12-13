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

POSSIBILIDADES=(q w e r t y u i o p a s d f g h j k l z x c v b n m Q W E R T Y U I O P A S D F G H J K L Z X C V B N M 1 2 3 4 5 6 7 8 9 0)
POSSIBILIDADESTAM=${#POSSIBILIDADES[@]}
FRASAO=
for((i=0;i<999;i++)); do
  FRASAO+=${POSSIBILIDADES[$((RANDOM%62))]}
done


#gerar um arquivo simples

#PAISES=($(awk '{print $1}' ../paises|tr '\n' ' '))
#PAISESCT=${#PAISES[@]}

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
    TAMKEY=$((10+RANDOM%24))
    local CHAVE=$(printf "$IT-$(date +%s)$i"|sha1sum | cut -b1-$TAMKEY|tr -d '\n')
    #local PAIS=${PAISES[$(($RANDOM%$PAISESCT))]}
    #echo "add key $CHAVE: $PAIS $(printf "$IT-$(date +%s)$i"|shasum)"
    echo "add key $CHAVE: $(echo $FRASAO|cut -b1-$((1+RANDOM%MAXFRASES)))"
    CHAVES[$chavescount]=$CHAVE
    ((chavescount++))
  done
}

function gentags()
{
  local QTD=$1
  local PRE=$2
  local i=0
  PREFIXO=""
  for((i=0;i<800;i++)); do
    PREFIXO+="a"
  done

  for((i=0;i<$QTD;i++)); do
    TAMTAG=999
    local TAGNAME="$PREFIXO$(printf "$PRE-$(date +%s)$i"|sha512sum|awk '{print $1}'|tr -d '\n')"
    local TOKEY="${CHAVES[$(($RANDOM%${#CHAVES[@]}))]}"
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
  echo ${HITEDTAGS[@]}|tr ' ' '\n'|shuf| head -n $TOTBUSCAS| while read l; do
    echo "show tagcontent $l"
  done
}

ITERACOES=60000
addchaves 50 $RANDOM 3 > /tmp/tt
echo "add key brunoquebratudo: Esta chave devera quebrar algum programa" >> /tmp/tt
echo "add key brunoquebratudo2: Esta chave devera quebrar algum cache" >> /tmp/tt
shuf /tmp/tt
gentags 5000 $RANDOM

echo "tag hit #$FRASAO brunoquebratudo"
ND=0
LASTTH=brunoquebratudo

for((k=0;k<ITERACOES;k++)); do
  printf "$k" >&2

  taghit 10  > /tmp/tt
  if (( ND == 2 )); then
    ND=0;
    if [[ "$LASTTH" == "brunoquebratudo" ]]; then
      LASTTH=brunoquebratudo2
      echo "tag hit #$FRASAO brunoquebratudo2"
    else
      LASTTH=brunoquebratudo
      echo "tag hit #$FRASAO brunoquebratudo"
    fi
  else
    echo "show tagcontent #$FRASAO"
  fi

  for((i=0;i<1;i++)); do
    ((UAU=RANDOM%100))
    if (( UAU == 0)); then
      echo list trending top 3
    elif (( UAU == 1 )); then
      echo list trending bottom 3
    elif (( UAU == 5 )) || (( UAU == 10 )) || (( UAU == 80 )); then
      echo new day
      #gentags 10 $RANDOM
      ((ND++))
    fi
  done >> /tmp/tt
  #sort -R -t ' ' -k 3 /tmp/tt
  shuf /tmp/tt
  echo '.' >&2
done

echo dump keys
echo dump tags
