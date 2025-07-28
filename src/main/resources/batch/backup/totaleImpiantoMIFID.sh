#!/bin/bash
export PFP_BATCH=/opt/POSTE/PFP_App/PFPbatchRendimenti/batch/
echo printenv ${PFP_BATCH}promSettings.sh
. ${PFP_BATCH}promSettings.sh

echo ----------------------------------------- ${PFP_BATCH}bImpiantoRiempiProdottoStaging.sh
. ${PFP_BATCH}bImpiantoRiempiProdottoStaging.sh

echo ----------------------------------------- ${PFP_BATCH}bStrumentoFin.sh
. ${PFP_BATCH}bStrumentoFin.sh

echo ----------------------------------------- ${PFP_BATCH}bCrypt.sh
. ${PFP_BATCH}bCrypt.sh

echo ----------------------------------------- ${PFP_BATCH}bRiempiProdotto.sh
. ${PFP_BATCH}bRiempiProdotto.sh

echo ----------------------------------------- ${PFP_BATCH}bRecuperoImpiantoRiempiProdotto.sh
. ${PFP_BATCH}bRecuperoImpiantoRiempiProdotto.sh


echo ----------------------------------------- ${PFP_BATCH}bGiornalieroRiempiProdottoStaging.sh
. ${PFP_BATCH}bGiornalieroRiempiProdottoStaging.sh

echo ----------------------------------------- ${PFP_BATCH}bStrumentoFinanziarioGiornaliero.sh
. ${PFP_BATCH}bStrumentoFinanziarioGiornaliero.sh

echo ----------------------------------------- ${PFP_BATCH}bCrypt.sh
. ${PFP_BATCH}bCrypt.sh

echo ----------------------------------------- ${PFP_BATCH}bRiempiProdottoGiornaliero.sh
. ${PFP_BATCH}bRiempiProdottoGiornaliero.sh