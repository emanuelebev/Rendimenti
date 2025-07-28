#!/bin/bash
cd /opt/POSTE/PFP_App/PFPbatchRendimenti/batch/

. promSettings.sh
export LOGFILE=${PATH_PFP_LOG}ltestConnection.log
. ${PFP_BATCH}promBatchPFPKettle.sh ${PATH_JOB_KETTLE}testConnection.kjb > ${LOGFILE}

. ${PFP_BATCH}promBatchPFPNoAmbiente.sh ${PATH_FASI_XML}bTestConnection.xml >> ${LOGFILE}
analizzaLog
