#!/bin/bash
cd /opt/POSTE/PFP_App/PFPbatchRendimenti/batch/

. promSettings.sh
export LOGFILE=${PATH_PFP_LOG}lTruncateOut.log
. ${PFP_BATCH}promBatchPFPNoAmbiente.sh ${PATH_FASI_XML}bTruncateOut.xml > ${LOGFILE}
analizzaLog
