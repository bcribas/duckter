#!/bin/bash

exec 2>&1

function addkey()
{
  local KEY="$1"
  local TXT="$2"
  if ! grep -q "add key $KEY:" log; then
    echo "add key ${KEY}: $TXT" >> log
  fi
}

function taghit()
{
  local TAG="$1"
  local HIT="$2"
  echo "tag hit $TAG $HIT" >> log
}

function slowstrprint()
{
  local STR="$1"
  local SPEED="$2"
  local TAM=${#STR}
  for((i=0;i<TAM;i++)); do
    printf "${STR:$i:1}"
    sleep $SPEED
  done
}

function printprogresso()
{
  local STR="$1"
  local ESPERA="$2"
  local CURSOR="|/-\\"

  AGORA=$(date +%s)
  INICIO=$(date +%s)
  i=0
  while (( AGORA - INICIO <= ESPERA)); do
    printf "\r$STR ${CURSOR:$i:1}"
    sleep 0.2
    ((i= (i+1)%4))
    AGORA=$(date +%s)
  done
  echo
}


function lerarquivo()
{
  local TEMP=$1
  ulimit -f 20
  timeout 10 cat - > $TEMP
  return $?
}

function cancelar()
{
  MOTIVO="$1"
  MD5MOTIVO="$(echo "$MOTIVO"|md5sum|awk '{print $1}')"
  addkey "$MD5MOTIVO" "$MOTIVO"
  taghit "#ERRO-$CONEXAOID" "$MD5MOTIVO"
  taghit "#$MD5MOTIVO" "$MD5MOTIVO"

  echo "$MOTIVO"
  printprogresso "**Verifique o email de instrucoes para saber como proceder.**" 3
  echo "Cancelando Operacao"
  rm $ARQ
  exit 1
}

# Log
touch log
INICIOCONEXAO="$(date +%s)"
DATECONEXAO="$(date --date=@$INICIOCONEXAO)"
CONEXAOID="$(echo "$TCPREMOTEIP $INICIOCONEXAO $RANDOM"|sha1sum|awk '{print $1}')"
HOJE="$(date +"%Y-%m-%d")"

#criar uma chave por dia
addkey "$HOJE" "Hoje $(date --date="today 00:00:00")"
addkey "entrega-$HOJE" "Entrega com sucesso em $HOJE"
addkey "entrega" "Entrega com sucesso"

#cada conexao faz um tag hit no dia
taghit "#$HOJE" "$HOJE"

#hit do IP em hoje
taghit "#$TCPREMOTEIP-$HOJE" "$HOJE"

#gravar log do inicio da conexao
addkey "$CONEXAOID" "$TCPREMOTEIP em $DATECONEXAO"
taghit "#$CONEXAOID" "$CONEXAOID"



STR="
  _____  _    _  _____ _  _________ ______ _____  
 |  __ \| |  | |/ ____| |/ /__   __|  ____|  __ \ 
 | |  | | |  | | |    | ' /   | |  | |__  | |__) |
 | |  | | |  | | |    |  <    | |  |  __| |  _  / 
 | |__| | |__| | |____| . \   | |  | |____| | \ \ 
 |_____/ \____/ \_____|_|\_\  |_|  |______|_|  \_\ 
                 Um produto AED22CP
"

slowstrprint "$STR" "0.01"


printprogresso "Recebendo Arquivo" 1

ARQ=$(mktemp)
VCX=$(lerarquivo $ARQ)
RET=$?

if [[ "$RET" != "0" ]]; then
  if (( RET == 124 )); then
    cancelar "Nenhum Arquivo Recebido."
  fi
  cancelar "Erro $RET"
fi

printprogresso "Verificando codigo" 1

if ! grep -q 'define AUTHKEY' $ARQ; then
  cancelar "AUTHKEY não encontrada"
fi

AUTHKEY="$(grep 'define AUTHKEY' $ARQ |head -n1|cut -d'"' -f2)"

if ! grep -q ":$AUTHKEY:" passwd; then
  cancelar "AUTHKEY INVALIDA"
fi

GRUPO="$(grep ":$AUTHKEY:" passwd|cut -d':' -f3)"
USERKEY="$(grep ":$AUTHKEY:" passwd|cut -d':' -f1)"

addkey "$USERKEY" "$GRUPO"
taghit "#dono-$CONEXAOID" "$USERKEY"

if grep -q 'define CONSULTA' $ARQ; then
  addkey "consulta" "Pedido de relatorio"
  addkey "consulta-$HOJE" "Relatorio $HOJE"
  taghit "#$CONEXAOID" "consulta"
  taghit "#consulta-$USERKEY" "consulta"
  taghit "#consulta-$HOJE-$USERKEY" "consulta-$HOJE"
  CONSULTA="$(grep 'define CONSULTA' $ARQ|head -n1| cut -d '"' -f2)"
  slowstrprint "show tag content $CONSULTA" 0.05
  echo
  case "$CONSULTA" in
    "status")
      cat results/status.txt
      ;;
    "nextround")
      cat results/nextround.txt
      ;;
    "currenttable")
      if [[ ! -e "results/tabelas-$HOJE.t2t" ]]; then
        echo "NULL"
      else
        while read l; do
          BOLD=""
          if grep -q "$GRUPO" <<< "$l"; then
            BOLD="$(tput setaf 3)$(tput bold)"
          fi
          slowstrprint "$BOLD$l" 0.01
          echo
        done < results/tabelas-$HOJE.t2t
	tput bold
	tput setaf 3
	slowstrprint "Nao esqueca de verificar a nova consulta possivel" 0.05
	printf "$(tput sgr 0)\n"
      fi
      echo
      ;;
    "alltable")
      if [[ ! -e "results/tabelas-consolidadas.t2t" ]]; then
        echo "NULL"
      else
        #cat results/tabelas-consolidadas.t2t
        sed -e "s/^=/$(tput bold)$(tput setaf 3)$(tput setab 4)                                                 /g" -e "s/=$/                                                  $(tput sgr 0)/g" results/tabelas-consolidadas.t2t
      fi
      ;;
    "resumo")
      if [[ ! -e "results/tabelas-resumo.t2t" ]]; then
        echo "NULL"
      else
        sed -e "s/^=/$(tput bold)$(tput setaf 3)$(tput setab 4)                                                 /g" -e "s/=$/                                                  $(tput sgr 0)/g" results/tabelas-resumo.t2t
      fi
      ;;
    "help")
      cat lista-consultas.txt
      ;;
    *)
      if grep -q "^$CONSULTA " results/entradas-hash; then
        BASE="$(grep "^$CONSULTA " results/entradas-hash|awk '{print $NF}')"
        addkey "$CONSULTA" "www.brunoribas.com.br/aed1/2016-2/trabalho1/entradas/$BASE.in.xz"
        taghit "#download-$BASE" "$CONSULTA"
        echo "show tagcontent $BASE"
        echo "Baixe executando o seguinte comando:"
        echo "wget www.brunoribas.com.br/aed1/2016-2/trabalho1/entradas/$BASE.in.xz"
      else
        cancelar "Consulta '$CONSULTA' invalida"
      fi
      ;;
  esac
  addkey "$CONSULTA" "Consulta do tipo $CONSULTA"
  taghit "#$CONSULTA-$USERKEY" "$CONSULTA"
  taghit "#$CONSULTA" "$CONSULTA"
  rm $ARQ
  exit 0
fi

if [[ "$HOJE" == "2016-12-13" ]]; then
  slowstrprint "Prazo de submissão encerrado" 0.2
  echo
  cancelar "O período de submissão foi encerrado. Aguarde a sua nota"
fi

if ! grep -q "idle" results/status.txt; then
  slowstrprint "Submissões desabilitadas durante processamento de periodo" 0.05
  echo
  cancelar "O sistema esta processando um novo ROUND"
fi

taghit "#$USERKEY-mais-submissoes" "$USERKEY"
taghit "#$USERKEY-submit" "entrega"
taghit "#$USERKEY-submit-$HOJE" "entrega-$HOJE"
taghit "#TotalSubmit" "entrega"
taghit "#TotalSubmit-$HOJE" "entrega-$HOJE"

STR="Um TAG HIT para voce $GRUPO"
slowstrprint "$STR" 0.01
echo

mkdir -p submissions submissions-history

if [[ "$USERKEY" == "7b5d086c" ]]; then
  cp "$ARQ" submissions-history/"${USERKEY}-${INICIOCONEXAO}.cpp"
  cp $ARQ "submissions/${USERKEY}.cpp"
else
  cp "$ARQ" submissions-history/"${USERKEY}-${INICIOCONEXAO}.c"
  cp $ARQ "submissions/${USERKEY}.c"
fi
rm $ARQ

exit 0

