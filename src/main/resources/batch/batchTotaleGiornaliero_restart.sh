#!/bin/bash
export PFP_BATCH=/opt/POSTE/PFP_App/PFPbatchRendimenti/batch/
echo printenv ${PFP_BATCH}promSettings.sh
. ${PFP_BATCH}promSettings.sh

# --------------------------------------Giornaliero Restart ----------------------------------------


echo ----------------------------------------- ${PFP_BATCH}bReuseAndFiltro.sh
. ${PFP_BATCH}bReuseAndFiltro.sh
status=$?
if [ $status -ne 0 ]; then
	echo FAILED!  bReuseAndFiltro.sh returned $status
	exit $status
fi


echo ----------------------------------------- ${PFP_BATCH}bGiornalieroRendimenti.sh
. ${PFP_BATCH}bGiornalieroRendimenti.sh
status=$?
if [ $status -ne 0 ]; then
	echo FAILED!  bGiornalieroRendimenti.sh returned $status
	exit $status
fi
