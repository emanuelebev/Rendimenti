#!/bin/bash
cd /opt/POSTE/PFP_App/PFPbatchRendimenti/batch/
export DATE_TODAY=`date +'%Y%m%d'`

. promSettings.sh
export LOGFILE=${PATH_PFP_LOG}lImpiantoRiempiProdottoStaging.log
. ${PFP_BATCH}promBatchPFPNoAmbiente.sh ${PATH_FASI_XML}bImpiantoRiempiProdottoStaging.xml > ${LOGFILE}
analizzaLog
