#!/bin/bash
. promSettings.sh
export LOGFILE=${PATH_PFP_LOG}log1.log
echo 'BATCH executed in' > ${LOGFILE}
analizzaLog
