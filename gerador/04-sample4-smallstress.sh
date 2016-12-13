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

addchaves 50 A
gentags 150 A
taghit 100
echo dump keys
buscatags 10
echo list trending top 15
addchaves 50 B
gentags 150 B
taghit 100
echo list trending top 15
echo dump keys
echo dump tags
