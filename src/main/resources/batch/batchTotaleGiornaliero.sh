#!/bin/bash
export PFP_BATCH=/opt/POSTE/PFP_App/PFPbatchRendimenti/batch/
echo printenv ${PFP_BATCH}promSettings.sh
. ${PFP_BATCH}promSettings.sh

#Check semaphore file
FILE_SEM=${PFP_CONF_HOME}file_sem_batch.txt

if [ -f $FILE_SEM ]
then
	echo "Semaphore file exist, previous run failed !!!"
	exit 1
else
	echo "Semaphore file doesn't exist, batch can start"
fi

touch $FILE_SEM
status=$?
if [ $status -ne 0 ]; then
        echo FAILED!  touch semaphore file returned $status
        exit $status
fi

# --------------------------------------Giornaliero ----------------------------------------

echo ----------------------------------------- ${PFP_BATCH}bTruncateOut.sh
. ${PFP_BATCH}bTruncate.sh
status=$?
if [ $status -ne 0 ]; then
	echo FAILED!  bTruncateOut.sh return $status
	exit $((200 + $status))
fi

echo ----------------------------------------- ${PFP_BATCH}bGiornalieroRiempiProdottoStaging.sh
. ${PFP_BATCH}bGiornalieroRiempiProdottoStaging.sh
status=$?

if [ $status -ne 0 ]; then
	echo FAILED!  bGiornalieroRiempiProdottoStaging.sh returned $status
elif [ $status -eq 0 ]; then
	echo ----------------------------------------- ${PFP_BATCH}bStrumentoFinanziarioGiornaliero.sh
	. ${PFP_BATCH}bStrumentoFinanziarioGiornaliero.sh
	status=$?
	if [ $status -ne 0 ]; then
		echo FAILED!  bStrumentoFinanziarioGiornaliero.sh returned $status
		exit $status
	fi
	
	echo ----------------------------------------- ${PFP_BATCH}bRiempiProdottoGiornaliero.sh
	. ${PFP_BATCH}bRiempiProdottoGiornaliero.sh
	status=$?
	if [ $status -ne 0 ]; then
		echo FAILED!  bRiempiProdottoGiornaliero.sh returned $status
		exit $status
	fi
fi


echo ----------------------------------------- ${PFP_BATCH}bGestioneFlussiImport.sh
. ${PFP_BATCH}bGestioneFlussiImport.sh
status=$?
if [ $status -ne 0 ]; then
	echo FAILED!  bGestioneFlussiImport.sh returned $status
	exit $((100 + $status))
fi

echo ----------------------------------------- ${PFP_BATCH}bStagingGiornaliero.sh
. ${PFP_BATCH}bStagingGiornaliero.sh
status=$?
if [ $status -ne 0 ]; then
	echo FAILED!  bStagingGiornaliero.sh returned $status
	exit $status
fi

echo ----------------------------------------- ${PFP_BATCH}bReuseAndFiltro.sh
. ${PFP_BATCH}bReuseAndFiltro.sh
status=$?
if [ $status -ne 0 ]; then
	echo FAILED!  bReuseAndFiltro.sh returned $status
	exit $status
fi


echo ----------------------------------------- ${PFP_BATCH}bGiornalieroRendimenti.sh
. ${PFP_BATCH}bGiornalieroRendimenti.sh
status=$?
if [ $status -ne 0 ]; then
	echo FAILED!  bGiornalieroRendimenti.sh returned $status
	exit $status
fi

echo ----------------------------------------- ${PFP_BATCH}bSquadrature.sh
. ${PFP_BATCH}bSquadrature.sh
status=$?
if [ $status -ne 0 ]; then
	echo FAILED!  bSquadrature.sh returned $status
	exit $status
fi

# Remove semaphore file
rm $FILE_SEM
status=$?
if [ $status -ne 0 ]; then
        echo FAILED!  rm semaphore file returned $status
        exit $status
fi

