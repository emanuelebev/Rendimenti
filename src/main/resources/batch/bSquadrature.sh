#!/bin/bash
cd /opt/POSTE/PFP_App/PFPbatchRendimenti/batch/

. promSettings.sh
export LOGFILE=${PATH_PFP_LOG}lSquadrature.log
. ${PFP_BATCH}promBatchPFPKettle.sh ${PATH_JOB_KETTLE}squadrature.kjb > ${LOGFILE} 2>&1
analizzaLog
