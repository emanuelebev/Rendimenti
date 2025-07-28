#!/bin/bash
cd /opt/POSTE/PFP_App/PFPbatchRendimenti/batch/

. promSettings.sh
export LOGFILE=${PATH_PFP_LOG}lSquadrature2018.log
. ${PFP_BATCH}promBatchPFPKettle.sh ${PATH_JOB_KETTLE}squadrature2018.kjb > ${LOGFILE} 2>&1
analizzaLog
