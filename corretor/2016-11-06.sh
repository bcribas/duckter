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
