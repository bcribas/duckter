#!/bin/bash

#Entrada de baixa memória, mas com muitas chaves e ordenações
POSSIBILIDADES=(q w e r t y u i o p a s d f g h j k l z x c v b n m Q W E R T Y U I O P A S D F G H J K L Z X C V B N M 1 2 3 4 5 6 7 8 9 0)
POSSIBILIDADESTAM=${#POSSIBILIDADES[@]}

for i in ${POSSIBILIDADES[@]}; do
  echo "add key $i: a"
  for j in ${POSSIBILIDADES[@]}; do
    echo "add key $i$j: a"
    for k in ${POSSIBILIDADES[@]}; do
      echo "add key $i$j$k: a"
    done
  done
done

for i in $(tr ' ' '\n' <<< "${POSSIBILIDADES[@]}"|sort -R); do
  for((c=0;c<100;c++)); do
    echo "tag hit #$i $i"
  done
  for j in  $(tr ' ' '\n' <<< "${POSSIBILIDADES[@]}"|sort -R); do
    for((c=0;c<100;c++)); do
      echo "tag hit #$i$j $i$j"
    done
  done
  echo "add key doido-$i$j: doidera"
done

for((i=1;i<50;i++)); do
  echo "dump tags"
  echo "list trending top $i"
done
