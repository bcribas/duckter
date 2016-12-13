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

#Entrada de baixa memória, mas com muitas chaves e ordenações
POSSIBILIDADES=(q w e r t y u i o p a s d f g h j k l z x c v b n m Q W E R T Y U I O P A S D F G H J K L Z X C V B N M 1 2 3 4 5 6 7 8 9 0)
POSSIBILIDADESTAM=${#POSSIBILIDADES[@]}
FRASAO=
for((i=0;i<1000;i++)); do
  FRASAO+=${POSSIBILIDADES[$((RANDOM%62))]}
done

echo "add key info: Esta entrada vai testar a insercao de chaves ordenadas reversamente"
for i in ${POSSIBILIDADES[@]}; do
  echo "add key $i: $(cut -b1-$((RANDOM%100+1)) <<< "$FRASAO")"
  for j in ${POSSIBILIDADES[@]}; do
    echo "add key $i$j: $(cut -b1-$((RANDOM%500+1)) <<< "$FRASAO")"
    for k in ${POSSIBILIDADES[@]}; do
      echo "add key $i$j$k: $(cut -b1-$((RANDOM%1000+1)) <<< "$FRASAO")"
    done
  done
done|sort -r

for i in $(tr ' ' '\n' <<< "${POSSIBILIDADES[@]}"|sort -R); do
  ((MAX=10+RANDOM%100))
  for((c=0;c<MAX;c++)); do
    echo "tag hit #$i $i"
  done
  for j in  $(tr ' ' '\n' <<< "${POSSIBILIDADES[@]}"|sort -R); do
    ((MAX=10+RANDOM%100))
    for((c=0;c<MAX;c++)); do
      echo "tag hit #$i$j $i$j"
    done
  done| sort -R
  echo "add key doido-$i$j: doidera"
  echo "show tagcontent #$i"
done

for((i=1;i<50;i++)); do
  echo "dump tags"
  echo "list trending bottom $i"
done

echo dump keys
