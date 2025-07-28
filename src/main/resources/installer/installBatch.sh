#!/bin/bash
export LOGFILE=/opt/POSTE/install/Rendimenti/log/installRendimentiBatch.log

uname -a
echo "whoami"
whoami
echo "printenv"
printenv
#########FUNZIONE CHECK OPERAZIONI

analizzaReturnCodeCommand() {
	if [ $1 == 0 ]
		then
			echo "##### - " $2 " eseguito correttamente - ####"
	else
		echo "##### - ERROR: " $2 " - ####"
		exit 1
	fi
}

#########FUNZIONE CHECK OPERAZIONI





#########CREAZIONE LOG INSTALL BACKUP E FTP 

mkdir -p /opt/POSTE/install/Rendimenti/log
mkdir -p /opt/POSTE/PFP_App/Rendimenti/Bakup
mkdir -p /opt/POSTE/PFP_App/ftpFiles

#########CREAZIONE LOG INSTALL BACKUP E FTP 





#########CHECK PACCHETTO INSTALLAZIONE

if [ ! -e /opt/POSTE/install/Rendimenti/PFPbatchRendimenti-batch.zip ]; then
 echo "ERROR: Pacchetto di installazione batch mancante" >> ${LOGFILE} 2>&1
 exit 1
fi

#########CHECK PACCHETTO INSTALLAZIONE





#########BACKUP ATTUALE

if [ -d /opt/POSTE/PFP_App/Rendimenti/Bakup/batchBKP ]; then
 rm -rf /opt/POSTE/PFP_App/Rendimenti/Bakup/batchBKP
fi

if [ -d /opt/POSTE/PFP_App/PFPbatchRendimenti ]; then
 cd /opt/POSTE/PFP_App/PFPbatchRendimenti && zip -r /opt/POSTE/PFP_App/Rendimenti/Bakup/batchBKP_`date +"%Y%m%d%H%M%S"`.zip . -x "log/*" "batch/*.log" >> ${LOGFILE} 2>&1
 
 analizzaReturnCodeCommand $? "Creazione zip di backup"

 cd /opt/POSTE/PFP_App/PFPbatchRendimenti/log && zip -r /opt/POSTE/PFP_App/Rendimenti/Bakup/batchLogBKP_`date +"%Y%m%d%H%M%S"`.zip . -i "*.log" >> ${LOGFILE} 2>&1
 
 analizzaReturnCodeCommand $? "Creazione zip di backup dei log"
  
 mv /opt/POSTE/PFP_App/PFPbatchRendimenti /opt/POSTE/PFP_App/Rendimenti/Bakup/batchBKP

 analizzaReturnCodeCommand $? "Creazione cartella di batch"
fi

#########BACKUP ATTUALE





#########UNZIP NUOVO PACCHETTO

unzip -o /opt/POSTE/install/Rendimenti/PFPbatchRendimenti-batch.zip -d /opt/POSTE/PFP_App >> ${LOGFILE} 2>&1
analizzaReturnCodeCommand $? "Unzip nuovo pacchetto batch"

mkdir -p /opt/POSTE/PFP_App/PFPbatchRendimenti/log

chmod -R 775 /opt/POSTE/PFP_App/PFPbatchRendimenti
analizzaReturnCodeCommand $? "Definizione permessi cartella batch"

#########UNZIP NUOVO PACCHETTO




#########CONFIGURAZIONE NUOVO PACCHETTO

if [ -e /opt/POSTE/install/Rendimenti/installerBatch.env ]; then
 source /opt/POSTE/install/Rendimenti/installerBatch.env
fi


TO_REPLACE_URL="@TOKEN_DB_JDBC_URL@"
TO_REPLACE_USER="@TOKEN_DB_USERNAME@"
TO_REPLACE_PWD="DB_PWD=@TOKEN_DB_PWD@"
TO_REPLACE_PATH="@TOKEN_PATH_FLUSSI@"
TO_REPLACE_JAVA_HOME="@TOKEN_JAVA_HOME@"


if [ "$TOKEN_JAVA_HOME" = "" ]; then 
	read -p "Inserire il path bin di java lasciare vuoto se gia' settata in ambiente: " JAVA_HOME
	
	if [ "$JAVA_HOME" != "" ]; then 
		JAVA_HOME_REP=$JAVA_HOME/
	fi
fi

sed -i "s|$TO_REPLACE_JAVA_HOME|$JAVA_HOME_REP|g" /opt/POSTE/PFP_App/PFPbatchRendimenti/batch/promSettings.sh >> ${LOGFILE} 2>&1
analizzaReturnCodeCommand $? "set java home"


##CREA URL CONNESIONE DA INPUT O LO PRENDE DA ENV

if [ "$TOKEN_DB_JDBC_URL" = "" ]; then 
		read -p "Database Host: " HOST_DB
		read -p "Database Service Name: " SERVICE_DB
		read -p "Database PORT: " PORT_DB
		DB_URL=jdbc:oracle:thin:@//$HOST_DB:$PORT_DB/$SERVICE_DB
		
	else
		DB_URL=$TOKEN_DB_JDBC_URL
fi

sed -i "s|$TO_REPLACE_URL|$DB_URL|g" /opt/POSTE/PFP_App/PFPbatchRendimenti/ini/pfp.ini >> ${LOGFILE} 2>&1
analizzaReturnCodeCommand $? "set url DB"



##INIT USER DB DA INPUT O PRESO DA ENV

if [ "$TOKEN_DB_USERNAME" = "" ]; then 
	read -p "Database user: " USER_DB
	else
		USER_DB=$TOKEN_DB_USERNAME
fi


sed -i "s|$TO_REPLACE_USER|$USER_DB|g" /opt/POSTE/PFP_App/PFPbatchRendimenti/ini/pfp.ini >> ${LOGFILE} 2>&1
analizzaReturnCodeCommand $? "set user DB"


##INIT PWD DB DA INPUT O PRESO DA ENV
if [ "$TOKEN_DB_PWD" = "" ]; then 
	read -s -p "Database password: " PWD_DB
	else
		TO_REPLACE_PWD="DB_PWD="$TOKEN_DB_PWD
		PWD_DB=$TOKEN_DB_PWD
fi

echo ''

PWD=`/opt/POSTE/PFP_App/PFPbatchRendimenti/batch/bCryptPasswordInstall.sh $PWD_DB`
analizzaReturnCodeCommand $? "DB pswd encrypting"

PWD="DB_PWD="$PWD

sed -i "s|$TO_REPLACE_PWD|$PWD|g" /opt/POSTE/PFP_App/PFPbatchRendimenti/ini/pfp.ini >> ${LOGFILE} 2>&1
analizzaReturnCodeCommand $? "set pwd DB"


##TEST CONNESSIONE DB

/opt/POSTE/PFP_App/PFPbatchRendimenti/batch/bTestConnection.sh >> ${LOGFILE} 2>&1
analizzaReturnCodeCommand $? "test connessione DB"


#########CONFIGURAZIONE NUOVO PACCHETTO


analizzaReturnCodeCommand 0 "Installazione Batch TERMINATA"
