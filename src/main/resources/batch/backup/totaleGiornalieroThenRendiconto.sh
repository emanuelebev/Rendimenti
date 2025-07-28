#!/bin/bash
uname -a
echo "whoami"
whoami
echo "printenv"
printenv

#BATCH GIORNALIERO
#if [ -r /opt/POSTE/PFP_App/PFPbatchRendimenti/batch/batchTotaleGiornaliero.sh ]
#then
#    echo "----------------------------------------- batchTotaleGiornaliero.sh"
#    . /opt/POSTE/PFP_App/PFPbatchRendimenti/batch/batchTotaleGiornaliero.sh
#fi


#BATCH RENDIMENTO MASSIVO
if [ -r /opt/POSTE/PFP_App/RendicontoMassivo/batch/bRendimentoMifid2.sh ]
then
    echo "----------------------------------------- bRendimentoMifid2.sh"
    . /opt/POSTE/PFP_App/RendicontoMassivo/batch/bRendimentoMifid2.sh
fi

#BATCH SALDORENDREDUCED
#if [ -r /opt/POSTE/PFP_App/RendicontoMassivo/batch/bPricingSaldoRendReduced.sh ]
#then
#    echo "----------------------------------------- bPricingSaldoRendReduced.sh"
#    . /opt/POSTE/PFP_App/RendicontoMassivo/batch/bPricingSaldoRendReduced.sh
#fi

#BATCH STORICIZZAZIONE
if [ -r /opt/POSTE/PFP_App/RendicontoMassivo/batch/bStoricizzazione.sh ]
then
    echo "----------------------------------------- bStoricizzazione.sh"
    . /opt/POSTE/PFP_App/RendicontoMassivo/batch/bStoricizzazione.sh
fi


#mkdir -p /opt/POSTE/PFP_App/RendicontoMassivo/batch/logprimorun/
#cp /opt/POSTE/PFP_App/RendicontoMassivo/batch/*.log /opt/POSTE/PFP_App/RendicontoMassivo/batch/logprimorun/


#BATCH RENDIMENTO MASSIVO
#if [ -r /opt/POSTE/PFP_App/RendicontoMassivo/batch/bRendimentoMifid2.sh ]
#then
#    echo "----------------------------------------- bRendimentoMifid2.sh"
#    . /opt/POSTE/PFP_App/RendicontoMassivo/batch/bRendimentoMifid2.sh
#fi

#BATCH SALDORENDREDUCED
#if [ -r /opt/POSTE/PFP_App/RendicontoMassivo/batch/bPricingSaldoRendReduced.sh ]
#then
#    echo "----------------------------------------- bPricingSaldoRendReduced.sh"
#    . /opt/POSTE/PFP_App/RendicontoMassivo/batch/bPricingSaldoRendReduced.sh
#fi

#BATCH STORICIZZAZIONE
#if [ -r /opt/POSTE/PFP_App/RendicontoMassivo/batch/bStoricizzazione.sh ]
#then
#    echo "----------------------------------------- bStoricizzazione.sh"
#    . /opt/POSTE/PFP_App/RendicontoMassivo/batch/bStoricizzazione.sh
#fi
