#!/bin/bash

source gerador-functions.sh

addchaves 50 A
gentags 150 A
taghit 100
echo dump keys
buscatags 50
echo list trending top 15
