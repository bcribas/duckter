#!/bin/bash

POSSIBILIDADES=(q w e r t y u i o p a s d f g h j k l z x c v b n m Q W E R T Y U I O P A S D F G H J K L Z X C V B N M 1 2 3 4 5 6 7 8 9 0)
POSSIBILIDADESTAM=${#POSSIBILIDADES[@]}

LG=
for((i=0;i<1000;i++)); do
  LG+=${POSSIBILIDADES[$((RANDOM%POSSIBILIDADESTAM))]}
done

for((i=0;i<100000;i++)); do
  hash=$(echo $i|md5sum|cut -b1-16)
  l="$(echo $LG|cut -b1-$((1+RANDOM%1000)))"
  echo "add key $hash: $l"
done
echo dump keys
