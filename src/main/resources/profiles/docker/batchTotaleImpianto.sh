#!/bin/bash
export PFP_BATCH=/opt/POSTE/PFP_App/PFPbatchRendimenti/batch/
echo printenv ${PFP_BATCH}promSettings.sh
. ${PFP_BATCH}promSettings.sh
#----------------Importazione----------------
echo ----------------------------------------- ${PFP_BATCH}bStagingImpianto.sh
. ${PFP_BATCH}bStagingImpianto.sh

echo ----------------------------------------- ${PFP_BATCH}bStrumentoFin.sh
. ${PFP_BATCH}bStrumentoFin.sh

#echo ----------------------------------------- ${PFP_BATCH}bCrypt.sh
#. ${PFP_BATCH}bCrypt.sh

echo ----------------------------------------- ${PFP_BATCH}bRiempiProdotto.sh
. ${PFP_BATCH}bRiempiProdotto.sh

echo ----------------------------------------- ${PFP_BATCH}bImpiantoRendimenti.sh
. ${PFP_BATCH}bImpiantoRendimenti.sh

echo ----------------------------------------- ${PFP_BATCH}bSquadrature.sh
. ${PFP_BATCH}bSquadrature.sh

echo ----------------------------------------- . /opt/POSTE/PFP_App/PFPbatchCostiRendiconto/batch/bCostiImplicitiPolizze.sh
. /opt/POSTE/PFP_App/PFPbatchCostiRendiconto/batch/bCostiImplicitiPolizze.sh

