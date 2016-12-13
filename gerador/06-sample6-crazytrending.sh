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

source gerador-functions.sh

addchaves 1000 A 20
gentags 2000 A
taghit 3000
for((i=5;i<=70;i+=5)); do
  echo "list trending top $i"
  echo "list trending bottom $i"
done
echo dump keys
echo dump tags
