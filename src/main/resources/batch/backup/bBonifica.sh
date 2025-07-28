#!/bin/bash
cd /opt/POSTE/PFP_App/PFPbatchRendimenti/batch/

. promSettings.sh
export LOGFILE=${PATH_PFP_LOG}lBonifica.log
. ${PFP_BATCH}promBatchPFPNoAmbiente.sh ${PATH_FASI_XML}bBonifica.xml > ${LOGFILE}
analizzaLog
