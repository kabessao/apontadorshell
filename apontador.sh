#!/bin/bash
show_help () {
echo "Comandos:
	-d Forçar mensagem de diferença do arquivo com o timeout;
	-D Modo debug;
	-e Forçar ou não mostrar a mensagem de falta do arquivo jar (1 para sim e 0 para não)
	-E Forçar ou não mostrar a mensagem de falta do arquivo xml (1 para sim e 0 para não)
	-f Não pergunta se deseja gravar, já grava de uma vez"
exit 1

}
#pegar as opções 
while getopts de:E:Df o; do
	case $o in
		(D) Debug="1";;
		(d) Diferenca=1;;
		(e) ExisteJar=$OPTARG;;
		(E) ExisteXml=$OPTARG;;
		(f) Force=1;;
		(*) show_help;;
	esac
done

Titulo="Apontador"
ApontadorJar="/home/henrique/Documentos/Apontador/apontador.jar"
ApontadorXls="/home/henrique/Documentos/Apontador/apontador.xls"
Comando="java -jar $ApontadorJar $ApontadorXls"
#Comando="./for.sh"

timeOut=1

#Modo para debug
if [[ "$Debug" == "1" ]]
then
	PS4='Line ${LINENO}: ' 
	set -x 
fi

#checa se o apontador.jar existe na pasta
if [[ "$ExisteJar" != "1" ]] ; then
if [[ -a $ApontadorJar ]] 
then
	echo "encontrado $ApontadorJar"
else 
	zenity --warning --title="$Titulo"  --text="$ApontadorJar não encontrado. Verifique se ele está na mesma pasta que o script ou com um nome diferente"
	echo "$ApontadorJar não encontrado"
	exit 1
fi
fi

 

#
#checa se o apontador.xls existe na pasta
if [[  "$ExisteXml" != "1" ]] ; then 
if [[ -a "$ApontadorXls" ]]
then
	echo "encontrado $ApontadorXls"
else 
	zenity --warning --title="$Titulo"  --text="$ApontadorXls não encontrado. Verifique se ele está na mesma pasta que o script ou com um nome diferente"
	echo "$ApontadorXls não encontrado"
	exit 1
fi
fi
echo $Comando $ApontadorJar $ApontadorXls

# testa quanto tempo faz que o arquivo foi modificado. (teste em horas).
Hora=$(date +%k:%m)
ModificadoTotal=$(stat $ApontadorXls --format=%y)
ModificadoTotal=${ModificadoTotal:0:16}
Diferenca=$(($(($(date "+%s") - $(date -d "$ModificadoTotal" "+%s"))) / 3600))
echo "diferença $Diferenca, timeout: $timeOut"

if [[ "$Diferenca" != "1" ]] ; then
if [ "$Diferenca" -lt "$timeOut" ] 
then
	echo "Apontador atualizado recentemente"
else 
	echo "Apontador desatualizado. Diferença $Diferenca"
	zenity --warning --title="$Titulo" --text="Foi detectado que a planilha não foi atualizada recentemente.
		Salve a planilha e tente novamente"
	exit 1
fi
fi

echo "checando se é force"
if [[ "$Force" != "1" ]]; then
	zenity --title="$Titulo" --text="Tem certeza que quer executar o Apontador?" --question
	resposta=$?
else
	resposta=0
fi

if [[ "$resposta" == "0" ]] 
then
	echo "------------------------------
------------------------------" >> ~/ApontadorLog.txt
	($Comando | while read line 
	do
		((linha++))
		echo "# Status linha $linha: $line";
		echo $line >> ~/ApontadorLog.txt
		
	done)| zenity --progress --title=Gravando --pulsate --auto-kill
 else 
	echo "Ação cancelada pelo usuario"
	exit
fi
