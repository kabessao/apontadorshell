#!/bin/bash

#parametros: tipo de mensagem, titulo, mensagem, 
Mensagem() {

if [ -n "$return"]; then
	echo $return;
fi

}

if [["$1" == "teste"]]; then 
	mensagem info teste testando
fi


Titulo="Anti Burro Apontador"
ApontadorJar="/home/henrique/Documentos/Apontador/apontador.jar"
ApontadorXls="/home/henrique/Documentos/Apontador/apontador.xls"
Comando="java -jar "
timeOut=1

#Modo para debug
if [[ "$1" == "debug" ]]
then
	PS4='Line ${LINENO}: ' 
	set -x 
fi

#checa se o apontador.jar existe na pasta
if [[ -a $ApontadorJar ]] && [[ "$1" != "existe1" ]]
then
	echo "encontrado $ApontadorJar"
else 
	zenity --warning --title="$Titulo"  --text="$ApontadorJar não encontrado. Verifique se ele está na mesma pasta que o script ou com um nome diferente"
	echo "$ApontadorJar não encontrado"
	exit 1
fi

 

#
#checa se o apontador.xls existe na pasta
if [[ -a "$ApontadorXls" ]] && [[  "$1" != "existe2" ]]
then
	echo "encontrado $ApontadorXls"
else 
	zenity --warning --title="$Titulo"  --text="$ApontadorXls não encontrado. Verifique se ele está na mesma pasta que o script ou com um nome diferente"
	echo "$ApontadorXls não encontrado"
	exit 1
fi
echo $Comando $ApontadorJar $ApontadorXls

# testa quanto tempo faz que o arquivo foi modificado. (teste em horas).
Hora=$(date +%k:%m)
ModificadoTotal=$(stat $ApontadorXls --format=%y)
ModificadoTotal=${ModificadoTotal:0:16}
Diferenca=$(($(($(date "+%s") - $(date -d "$ModificadoTotal" "+%s"))) / 3600))
echo "diferença $Diferenca, timeout: $timeOut"

if [ "$Diferenca" -lt "$timeOut" ] 
then
	echo "Apontador atualizado recentemente"
else 
	echo "Apontador desatualizado. Diferença $Diferenca"
	zenity --warning --title="$Titulo" --text="Foi detectado que a planilha não foi atualizada recentemente. Salve a planilha e tente novamente"
	exit 1
fi

if zenity --title="$Titulo" --text="Tem certeza que quer executar o Apontador?" --question
then
	#java -jar apontador.jar apontador.xls
	gravado=$($Comando $ApontadorJar $ApontadorXls| grep "Gravado"  | wc -l)
 else 
	echo "Ação cancelada pelo usuario"
	exit
fi
zenity --title="Finalizado" --text="foram gravados $gravado registros" --info 
