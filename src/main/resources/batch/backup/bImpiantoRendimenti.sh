#!/bin/bash
cd /opt/POSTE/PFP_App/PFPbatchRendimenti/batch/

. promSettings.sh
export LOGFILE=${PATH_PFP_LOG}lImpiantoRendimenti.log
. ${PFP_BATCH}promBatchPFPKettle.sh ${PATH_JOB_KETTLE}bImpiantoRendimenti.kjb > ${LOGFILE} 2>&1
analizzaLog
