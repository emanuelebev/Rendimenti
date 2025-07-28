#!/bin/bash
export PFP_BATCH=./
echo printenv ${PFP_BATCH}promSettings.sh
. ${PFP_BATCH}promSettings.sh

echo ----------------------------------------- ${PFP_BATCH}chiamante.sh
. ${PFP_BATCH}chiamato1.sh
status=$?
if [ $status -ne 0 ]; then
	echo FAILED! chiamato1.sh return $status
	exit $status
fi

echo ----------------------------------------- ${PFP_BATCH}chiamante.sh
. ${PFP_BATCH}chiamato2.sh
status=$?
if [ $status -ne 0 ]; then
	echo FAILED! chiamato2.sh return $status
	exit $status
fi

