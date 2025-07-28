#!/bin/bash

cd /opt/POSTE/PFP_App/PFPbatchRendimenti/batch/
. promSettings.sh

export LOGFILE=${PATH_PFP_LOG}lExportFlussiGarantePDR.log
export APPO_PATH=/opt/POSTE/appo_file/exportFlussiGarante
export GARANTE_FILENAME_PREFIX=Gar_AP-00564_PK-01461
export ACTUAL_HM=`date +'%H%M'`

if [ -z $STARTDATE ] && [ -z $ENDDATE ];
then
	echo "Shell chiamata singolarmente inizio controllo parametri di estrazione" > $LOGFILE
	manageEstrazione $PFP_FLUSSI_PROFONDITA_RICERCA_GIORNALIERA $1 $2 >> $LOGFILE
	RESULT=$?
	echo "Ritorno manageEstrazione:" $RESULT >> $LOGFILE
	if [ $RESULT -gt 0 ];
	then
		echo "Errore - Esportazione flussi interrotta" >> $LOGFILE
		exit $RESULT
	fi
else
	echo "Shell richiamata con range: " $STARTDATE " - " $ENDDATE > $LOGFILE 	
fi

. ${PFP_BATCH}promBatchExtractLogGarante.sh ${PATH_FASI_XML}bExportFlussiGarantePDR.xml $STARTDATE $ENDDATE $GARANTE_FILENAME_PREFIX $ACTUAL_HM >> $LOGFILE

analizzaLog
RESULT=$?
if [ $RESULT -gt 10 ];then
echo '########## Error Export flussi garante - Stop Execution ##########' >> $LOGFILE
exit $RESULT
fi

export EXPORTGARANTE_FILE=`ls -Atr $APPO_PATH/$GARANTE_FILENAME_PREFIX* | tail -n 1`
export EXPORTGARANTE_FILE_CODA=$APPO_PATH/Gar_AP_coda.txt

echo '##########  EXPORTGARANTE_FILE: '$EXPORTGARANTE_FILE  >> $LOGFILE
echo '##########  EXPORTGARANTE_FILE_CODA: '$EXPORTGARANTE_FILE_CODA  >> $LOGFILE

logPrivacyOp
RESULT_LOGPRIVACY_OP=$?
if [ $RESULT_LOGPRIVACY_OP -gt 0 ];then
        echo '##########  Error during CONCATENATING FILES: ' $RESULT_LOGPRIVACY_OP >> $LOGFILE
        exit $RESULT_LOGPRIVACY_OP
fi
echo '##########  CONCATENATING RESULT: ' $RESULT_LOGPRIVACY_OP  >> $LOGFILE

export EXPORTGARANTE_FILE=`ls -Atr $APPO_PATH/$GARANTE_FILENAME_PREFIX_* | tail -n 1`
export EXPORTGARANTE_FILE_FINAL=$PATH_EXPORT_GARANTE/`basename "$EXPORTGARANTE_FILE"`

mv $EXPORTGARANTE_FILE $EXPORTGARANTE_FILE_FINAL
MOVING=$?
if [ $MOVING -gt 0 ];then
        echo '##########  Error during MOVING TO END PATH PRODUCED FILE: return code ' $MOVING >> $LOGFILE
        exit $MOVING
fi
echo '##########  MOVING TO END PATH RESULT: ' $MOVING  >> $LOGFILE


echo "##########  FTP Send file: " $EXPORTGARANTE_FILE_FINAL >> $LOGFILE

lftp sftp://st_mifid3001:@$IP_SEND_GARANTE_LOG -p 2222 -e "set net:reconnect-interval-base 5; set net:max-retries 2; cd /PerNemesi_Kepler; put $EXPORTGARANTE_FILE_FINAL; bye" >> $LOGFILE 2>&1
RESULT=$?
if [ $RESULT -gt 0 ];then
        echo '##########  Error during FTP: return code' $RESULT >> $LOGFILE
        exit $RESULT
fi
echo '##########  FTP RESULT:' $RESULT  >> $LOGFILE

rm $EXPORTGARANTE_FILE_FINAL
REMOVED=$?
if [ $REMOVED -gt 0 ];then
	echo '##########  Error during REMOVING FILE '$EXPORTGARANTE_FILE_FINAL': return code ' $REMOVED >> $LOGFILE
	exit $REMOVED
fi
echo '##########  FILE '$EXPORTGARANTE_FILE_FINAL' REMOVED CORRECTLY: ' $REMOVED >> $LOGFILE