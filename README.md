#Entrada das chaves para endereços
add key CHAVE: PAÍS texto

#Adicionando tags
tag hit #nomedatag CHAVE

#Buscar conteudo da tag
search tag content #nomedatag

#Listar Trending
list trending top 10
list trending bottom 10

#remocoes

rm key CHAVE
rm tag #tag

##verifica referencias quebradas de tag
rm brokentagref
    -> programa imprime quantos foram removidos

##busca chaves orfans, sem alguma tag referenciando
rm orphankey
    -> programa imprime quantos foram removidos

#novo dia
new day

##efeito

Inicia um dia e remove as tags sem hit no dia. e roda automaticamente o
del orphankey

Apos o new day o programa imprime quantas quais tags foram removidas e
quantas chaves foram removidas com o del orphankey

#DUMP

dump tag
 -> lista as tags, tem que imprimir a quantidade de hits do dia atual.

dump keys
 -> imprime lista de chaves

