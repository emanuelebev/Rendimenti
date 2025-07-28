#!/bin/bash
. promSettings.sh
export LOGFILE=${PATH_PFP_LOG}log2.log
echo 'ERROR' > ${LOGFILE}
#echo 'ORA-' >> ${LOGFILE}
echo 'BATCH executed in 1' >> ${LOGFILE}
analizzaLog
