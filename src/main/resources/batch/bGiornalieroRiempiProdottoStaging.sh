#!/bin/bash
cd /opt/POSTE/PFP_App/PFPbatchRendimenti/batch/
export DATE_TODAY=`date +'%Y%m%d'`

. promSettings.sh
export LOGFILE=${PATH_PFP_LOG}lGiornalieroRiempiProdottoStaging.log
echo Start check Flussi > $LOGFILE
. ${PFP_BATCH}bCheckFlussi.sh

status=$?
if [ $status -ne 0 ]; then
	echo FAILED!  bCheckFlussi.sh returned $status
	return $status
fi

echo Check Flussi OK - avvio staging>> $LOGFILE
. ${PFP_BATCH}promBatchPFPNoAmbiente.sh ${PATH_FASI_XML}bGiornalieroRiempiProdottoStaging.xml > ${LOGFILE}
analizzaLog
