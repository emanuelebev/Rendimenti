#!/bin/bash
cd /opt/POSTE/PFP_App/PFPbatchRendimenti/batch/
. promSettings.sh
export LOGFILE=${PATH_PFP_LOG}lStrumentoFinanziarioGiornaliero.log

. ${PFP_BATCH}promBatchPFPNoAmbiente.sh ${PATH_FASI_XML}bSaveStrumentoFinanziario.xml > ${LOGFILE}
analizzaLog
RESULT=$?
if [ $RESULT -gt 10 ];then
echo '########## Error in Creating Backup - Stop Execution ##########' >> $LOGFILE
return $RESULT
fi

echo '########## Backup STRUMENTO FINANZIARIO Created' >> $LOGFILE

. ${PFP_BATCH}promBatchPFPNoAmbiente.sh ${PATH_FASI_XML}bStrumentoFinanziarioGiornaliero.xml >> ${LOGFILE}

echo 'Check FILE ANAG_RUNCOM' >> $LOGFILE
checkFile $LAST_ANAG_UPDATE

RESULT=$?

if [ $RESULT = 0 ];then
	echo 'FILE ANAGRAFICA ANAG_RUNCOM PRESENTE' >> $LOGFILE
	checkDataFile $LAST_ANAG_UPDATE
	RESULTDATA=$?
	if [ $RESULTDATA = 1 ];then
		echo 'KO_ANAG_RUNCOM_FILE_NOT_UPDATED'  >> $LOGFILE
	fi
fi

if [ $RESULT = 1 ];then
	echo 'KO_ANAG_RUNCOM_NULL'  >> $LOGFILE
fi
if [ $RESULT = 2 ];then
	echo 'KO_ANAG_RUNCOM_EMPTY'  >> $LOGFILE
fi


analizzaLog
RESULT=$?
if [ $RESULT = 11 ]  || [ $RESULT = 12 ] || [ $RESULT = 13 ];then
	export LOGFILE=${PATH_PFP_LOG}lRecuperoStrumentoFinanziarioGiornaliero.log
	. ${PFP_BATCH}bRecuperoStrumentoFinanziario.sh > ${LOGFILE}
	RESULTRESTORE=$?
	export LOGFILE=${PATH_PFP_LOG}lStrumentoFinanziarioGiornaliero.log
	if [ $RESULTRESTORE = 0 ];then
		echo '########## Backup Restored ##########' >> $LOGFILE
	else
		echo '########## Backup Restore FAILED ##########' >> $LOGFILE
	fi
fi
return $RESULT
