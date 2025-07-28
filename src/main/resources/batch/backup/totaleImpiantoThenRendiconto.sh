#!/bin/bash
uname -a
echo "whoami"
whoami
echo "printenv"
printenv

#BATCH IMPIANTO
if [ -r /opt/POSTE/PFP_App/PFPbatchRendimenti/batch/batchTotaleImpianto2019.sh ]
then
    echo "----------------------------------------- batchTotaleImpianto2019.sh"
    . /opt/POSTE/PFP_App/PFPbatchRendimenti/batch/batchTotaleImpianto2019.sh
fi


#BATCH COSTI IMPLICITI
if [ -r /opt/POSTE/PFP_App/PFPbatchCostiRendiconto/batch/batchTotaleCostiImpliciti.sh ]
then
    echo "----------------------------------------- batchTotaleCostiImpliciti.sh"
    . /opt/POSTE/PFP_App/PFPbatchCostiRendiconto/batch/batchTotaleCostiImpliciti.sh
fi


#BATCH RENDIMENTO MASSIVO
if [ -r /opt/POSTE/PFP_App/RendicontoMassivo/batch/bRendimentoMifid2.sh ]
then
    echo "----------------------------------------- bRendimentoMifid2.sh"
    . /opt/POSTE/PFP_App/RendicontoMassivo/batch/bRendimentoMifid2.sh
fi

#BATCH SALDORENDREDUCED
if [ -r /opt/POSTE/PFP_App/RendicontoMassivo/batch/bPricingSaldoRendReduced.sh ]
then
    echo "----------------------------------------- bPricingSaldoRendReduced.sh"
    . /opt/POSTE/PFP_App/RendicontoMassivo/batch/bPricingSaldoRendReduced.sh
fi

#BATCH STORICIZZAZIONE
if [ -r /opt/POSTE/PFP_App/RendicontoMassivo/batch/bStoricizzazione.sh ]
then
    echo "----------------------------------------- bStoricizzazione.sh"
    . /opt/POSTE/PFP_App/RendicontoMassivo/batch/bStoricizzazione.sh
fi
