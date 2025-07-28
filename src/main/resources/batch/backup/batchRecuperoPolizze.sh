#!/bin/bash
export PFP_BATCH=/opt/POSTE/PFP_App/PFPbatchRendimenti/batch/
echo printenv ${PFP_BATCH}promSettings.sh
. ${PFP_BATCH}promSettings.sh

echo ----------------------------------------- ${PFP_BATCH}bRecuperoSaldiPolizzeStaging.sh
. ${PFP_BATCH}bRecuperoSaldiPolizzeStaging.sh
status=$?
if [ $status -ne 0 ]; then
	echo FAILED!  bRecuperoSaldiPolizzeStaging.sh return $status
	exit $status
fi

echo ----------------------------------------- ${PFP_BATCH}bRecuperoSaldiPolizze.sh
. ${PFP_BATCH}bRecuperoSaldiPolizze.sh
status=$?
if [ $status -ne 0 ]; then
	echo FAILED!  bRecuperoSaldiPolizze.sh return $status
	exit $status
fi

