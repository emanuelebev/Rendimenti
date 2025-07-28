#!/bin/bash
cd /opt/POSTE/PFP_App/PFPbatchRendimenti/batch/
export DATE_TODAY=`date +'%Y%m%d'`

. promSettings.sh
export LOGFILE=${PATH_PFP_LOG}lStagingGiornaliero.log
. promBatchPFPNoAmbiente.sh ${PATH_FASI_XML}bGiornalieraRendStaging.xml > ${LOGFILE}
analizzaLog
