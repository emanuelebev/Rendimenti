#!/bin/bash
cd /opt/POSTE/PFP_App/PFPbatchRendimenti/batch/

. promSettings.sh
export LOGFILE=${PATH_PFP_LOG}lReuseAndFiltro.log
. ${PFP_BATCH}promBatchPFPKettle.sh ${PATH_JOB_KETTLE}bReuseAndFiltro.kjb > ${LOGFILE}
analizzaLog
