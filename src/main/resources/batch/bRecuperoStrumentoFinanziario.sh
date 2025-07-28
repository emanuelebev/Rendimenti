#!/bin/bash
cd /opt/POSTE/PFP_App/PFPbatch/batch/

. promSettings.sh
export LOGFILE=${PATH_PFP_LOG}lRecuperoStrumentoFinanziario.log
. ${PFP_BATCH}promBatchPFPNoAmbiente.sh ${PATH_FASI_XML}bRecuperoStrumentoFinanziario.xml > ${LOGFILE}
analizzaLog
