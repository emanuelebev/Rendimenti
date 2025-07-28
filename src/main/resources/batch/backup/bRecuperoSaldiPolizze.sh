#!/bin/bash
cd /opt/POSTE/PFP_App/PFPbatchRendimenti/batch/

. promSettings.sh
export LOGFILE=${PATH_PFP_LOG}lRecuperoSaldiPolizze.log
. ${PFP_BATCH}promBatchPFPKettle.sh ${PATH_JOB_KETTLE}bRecuperoSaldiPolizze.kjb > ${LOGFILE} 2>&1
analizzaLog
