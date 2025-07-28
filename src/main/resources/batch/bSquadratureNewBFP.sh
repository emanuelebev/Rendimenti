#!/bin/bash
cd /opt/POSTE/PFP_App/PFPbatchRendimenti/batch/

. promSettings.sh
export LOGFILE=${PATH_PFP_LOG}lSquadratureBFPNew.log

export DATA_INIZIO=20171231

. ${PFP_BATCH}promBatchPFPAmbiente.sh ${PATH_FASI_XML}bCalcolaSquadratureBFPMulti.xml > ${LOGFILE} 2>&1
analizzaLog
