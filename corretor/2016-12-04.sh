#!/bin/bash

POSSIBILIDADES=(q w e r t y u i o p a s d f g h j k l z x c v b n m Q W E R T Y U I O P A S D F G H J K L Z X C V B N M 1 2 3 4 5 6 7 8 9 0)
POSSIBILIDADESTAM=${#POSSIBILIDADES[@]}
FRASAO=
for((i=0;i<1000;i++)); do
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
    #TAMKEY=$((10+RANDOM%24))
    local CHAVE=$(printf "$IT-$(date +%s)$i"|sha1sum |awk '{print $1}')
    #local PAIS=${PAISES[$(($RANDOM%$PAISESCT))]}
    #echo "add key $CHAVE: $PAIS $(printf "$IT-$(date +%s)$i"|shasum)"
    echo "add key $CHAVE: $(echo $FRASAO|cut -b1-$MAXFRASES)"
    #CHAVES[$chavescount]=$CHAVE
    #((chavescount++))
  done
}

function gentags()
{
  local QTD=$1
  local PRE=$2
  local i=0
  for((i=0;i<$QTD;i++)); do
    TAMTAG=$((10+RANDOM%24))
    local TAGNAME="$(printf "$PRE-$(date +%s)$i"|sha1sum | cut -b1-$TAMTAG|tr -d '\n')"
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

ITERACOES=900
addchaves 50000 $RANDOM $((1+RANDOM%10)) > /tmp/tt
echo 'add key ribas: diminuidor de performance' >> /tmp/tt
sort -t ' ' -k 3 -r /tmp/tt
#gentags 5000 $RANDOM
NDCT=0
HITCT=0
LASTTAG=0

for((k=0;k<ITERACOES;k++)); do
  printf "$k" >&2

  if (( NDCT < 2 )) && (( HITCT > 0 )) && (( RANDOM%100 > 90 )); then
    echo "show tagcontent #$LASTTAG"
  fi
  if (( NDCT >= 2 )); then
    HITCT=0
    NDCT=0
  fi

  addchaves 500 $RANDOM $((1+RANDOM%300)) > /tmp/tt
  for((i=0;i<1;i++)); do
    ((UAU=RANDOM%100))
    if (( UAU >= 70 )); then
      ((NDCT++))
      echo new day
    fi
    if (( UAU <= 80 )); then
      LASTTAG=$RANDOM
      echo "tag hit #$LASTTAG ribas"
      ((HITCT++))
    fi
  done >> /tmp/tt
  sort -r -t ' ' -k 3 /tmp/tt
  echo '.' >&2
done

echo dump keys
echo dump tags
