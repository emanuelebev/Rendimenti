#!/bin/bash
cd /opt/POSTE/PFP_App/PFPbatchRendimenti/batch/

. promSettings.sh
export LOGFILE=${PATH_PFP_LOG}lGiornalieroRendimenti.log
. ${PFP_BATCH}promBatchPFPKettle.sh ${PATH_JOB_KETTLE}bGiornalieraRendimenti.kjb > ${LOGFILE} 2>&1
analizzaLog

