#Duckter

Este repositório reflete o trabalho feito para a disciplina de Algoritmos e
Estrutura de Dados I em 2016/2 na UTFPR - Campus Pato Branco.

A especificação do trabalho pode ser vista no diretório html/ deste
repositório ou a versão compilada em:
  http://brunoribas.com.br/aed1/2016-2/trabalho1

##Implementações de Referência

Para poder definir os limiares do trabalho foram criadas 3 implementações de
referência, e são elas:

- sols/ribastree.cpp: Solução implementada em C++ utilizado MAP para
  representação das tags e chaves

- sols/ribas-fair.cpp: Solução que contempla o Simples e o Super Simples,
  implementada em C.

A implementação ribas-fair possui várias definições que alteram o
funcionamento do código. Alguns exemplo são:

- __SUPERSIMPLES: Ativa o modo SuperSimples
- __DUMPPIVOT: Faz uma escolha ruim de pivot no quicksort
- __RPIVOT: Escolhe um elemento aleatório como pivot
- __DUMBTRENDING: Sempre ordena o vetor inteiro para gerar a lista de
  trendings

Para compilar todas as variações basta entrar no diretório sols/ e executar:

```
make
```

##Executando experimentos de Exemplo

O diretório samples/ possui um conjunto de entradas que foram os exemplos
fornecidos aos alunos.

Se você desejar executar todas soluções compiladas no diretório sols/, basta
executar:

```
cd sols
make run-samples
```

Com isso todos exemplo do diretório samples/ serão executados

##Executando outros arquivos de entrada

Os scripts executam binários com extensão *.O0 .O2 .O3 .e .epp*. O
significado são:
- .O0 : binários compilados sem otimização. O Super Simples é compilado
  assim
- .O2 : binários com otimização O2. O Simples e todas as outras
  implementações são compiladas com essa flag
- .O3 : binários com otimização O3. Feito para alguns testes
- .e : binários gerados a partir dos códigos em C dos alunos
- .epp: binários gerados a partir dos códigos em C++ de alguns alunos

Para gerar a tabela comparativa das soluções basta colocar os binários em um
diretório, exemplo sols, e executar:

```
cd sols
bash run-tests.sh ../corretor/entradas/2016-11-06.in
```

##O diretório entrega/

Este diretório possui o daemon entregad.sh que é o script que fará o contato
com os alunos.

Em comunicação com este daemon você poderá enviar uma nova submissão e
consultar a tabela de execuções do dia e resumo.

Leia o arquivo 'lista-consultas.txt' no diretório para entender como
funciona.

O script rodar possui o comando de execução do daemon com um tcpserver.

*CUIDADO*, o script pode não ser muito seguro. Execute em um ambiente
isolado.

##O Diretório corretor/

Este diretório contém os scripts e arquivos de entrada necessários para a
execução automatizada das soluções entregues pelos alunos.

###corretord.sh

Este script faz pull do servidor com as submissões dos alunos em um
intervalo entre 30m e 3h30 e executa as novas versões para a entrada do dia

Na última execução do dia ele compacta a entrada e disponibiliza na página
web da disciplina.

Para você usar esse script terá que fazer diversas modificações.

###gera-resumo.sh

Este script gera o resumo de execuções de todas entradas para as soluções
dos alunos.

##O Diretório html/

Neste diretório existe o arquivo enunciado.t2t. Este arquivo é o arquivo a
descrição do enunciado do trabalho.


