#!/bin/bash
export PFP_BATCH=/opt/POSTE/PFP_App/PFPbatchRendimenti/batch/
echo printenv ${PFP_BATCH}promSettings.sh
. ${PFP_BATCH}promSettings.sh

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

