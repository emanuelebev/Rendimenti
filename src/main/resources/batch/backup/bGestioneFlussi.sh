#!/bin/bash
cd /workSpaces/workspaceTestISP/PFPWeb18Rendimenti/RendimentiBatchGiornaliero/src/main/resources/batch/

. promSettings.sh
export LOGFILE=${PATH_PFP_LOG}lGestioneFlussi.log

. ${PFP_BATCH}promBatchPFPNoAmbiente.sh ${PATH_FASI_XML}bGestioneFlussi.xml > ${LOGFILE}
analizzaLog

