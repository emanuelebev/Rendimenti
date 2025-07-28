#!/bin/bash

cd /opt/POSTE/PFP_App/PFPbatchRendimenti/batch/
. promSettings.sh

export LOGFILETOTAL=${PATH_PFP_LOG}lExportFlussiGarante.log

echo "Shell chiamata singolarmente inizio controllo parametri di estrazione" > $LOGFILETOTAL

manageEstrazione $PFP_FLUSSI_PROFONDITA_RICERCA_GIORNALIERA $1 $2 >> $LOGFILETOTAL
RESULT=$?
echo "Ritorno manageEstrazione:" $RESULT >> $LOGFILETOTAL
if [ $RESULT -gt 0 ];
then
	echo "Errore - Esportazione flussi interrotta" >> $LOGFILETOTAL
	exit $RESULT
fi

# -------------------------------------- EXPORT GARANTE PDR ----------------------------------------

echo ----------------------------------------- ${PFP_BATCH}bExportFlussiGarantePDR.sh >> $LOGFILETOTAL
. ${PFP_BATCH}bExportFlussiGarantePDR.sh

# -------------------------------------- EXPORT GARANTE CDM ----------------------------------------

echo ----------------------------------------- ${PFP_BATCH}bExportFlussiGaranteCDM.sh >> $LOGFILETOTAL
. ${PFP_BATCH}bExportFlussiGaranteCDM.sh