#!/bin/bash
cd /opt/POSTE/PFP_App/PFPbatchRendimenti/batch/

. promSettings.sh
export LOGFILE=${PATH_PFP_LOG}lRiempiProdottoGiornaliero.log
. ${PFP_BATCH}promBatchPFPKettle.sh ${PATH_JOB_KETTLE}bRiempiProdotto.kjb > ${LOGFILE}
analizzaLog
