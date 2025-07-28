#!/bin/bash
cd /opt/POSTE/PFP_App/PFPbatchRendimenti/batch/

. promSettings.sh
export LOGFILE=${PATH_PFP_LOG}lReuse.log
. ${PFP_BATCH}promBatchPFPKettle.sh ${PATH_JOB_KETTLE}reuse.kjb > ${LOGFILE}
analizzaLog

