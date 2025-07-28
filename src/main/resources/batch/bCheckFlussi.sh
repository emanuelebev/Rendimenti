. promSettings.sh


export FLUSSO_CLIENTE=$PFP_FLUSSI/MIFID_Cliente.txt
export FLUSSO_PRODOTTI=$PFP_FLUSSI/MIFID_AnagraficaProdotti.txt
export FLUSSO_PROFILO=$PFP_FLUSSI/MIFID_Profilo.txt
export FLUSSO_RAPPORTO=$PFP_FLUSSI/MIFID_Rapporto.txt
export FLUSSO_SALDO=$PFP_FLUSSI/MIFID_Saldi.txt
export FLUSSO_STRUTTURA=$PFP_FLUSSI/MIFID_Struttura.txt

export FLUSSO_CLIENTE_LAST=$PFP_FLUSSI/MIFID_Cliente_LAST.txt
export FLUSSO_PRODOTTI_LAST=$PFP_FLUSSI/MIFID_AnagraficaProdotti_LAST.txt
export FLUSSO_PROFILO_LAST=$PFP_FLUSSI/MIFID_Profilo_LAST.txt
export FLUSSO_RAPPORTO_LAST=$PFP_FLUSSI/MIFID_Rapporto_LAST.txt
export FLUSSO_SALDO_LAST=$PFP_FLUSSI/MIFID_Saldi_LAST.txt
export FLUSSO_STRUTTURA_LAST=$PFP_FLUSSI/MIFID_Struttura_LAST.txt


if [ -f $FLUSSO_CLIENTE ]; then	
	mv -f $FLUSSO_CLIENTE $FLUSSO_CLIENTE_LAST
fi

if [ -f $FLUSSO_PRODOTTI ]; then	
	mv -f $FLUSSO_PRODOTTI $FLUSSO_PRODOTTI_LAST
fi

if [ -f $FLUSSO_PROFILO ]; then	
	mv -f $FLUSSO_PROFILO $FLUSSO_PROFILO_LAST 
fi

if [ -f $FLUSSO_RAPPORTO ]; then	
	mv -f $FLUSSO_RAPPORTO $FLUSSO_RAPPORTO_LAST
fi

if [ -f $FLUSSO_SALDO ]; then	 
	mv -f $FLUSSO_SALDO $FLUSSO_SALDO_LAST
fi

if [ -f $FLUSSO_STRUTTURA ]; then	
	mv -f $FLUSSO_STRUTTURA $FLUSSO_STRUTTURA_LAST
fi 



export CHECK_CLIENTE=$(tail -n1 $FLUSSO_CLIENTE_LAST)
export CHECK_PRODOTTI=$(tail -n1 $FLUSSO_PRODOTTI_LAST)
export CHECK_PROFILO=$(tail -n1 $FLUSSO_PROFILO_LAST)
export CHECK_RAPPORTO=$(tail -n1 $FLUSSO_RAPPORTO_LAST)
export CHECK_SALDO=$(tail -n1 $FLUSSO_SALDO_LAST)
export CHECK_STRUTTURA=$(tail -n1 $FLUSSO_STRUTTURA_LAST)

if [[ $CHECK_CLIENTE = *"<CODA>"* ]] && [[ $CHECK_PRODOTTI = *"<CODA>"* ]] && [[ $CHECK_PROFILO = *"<CODA>"* ]] && [[ $CHECK_RAPPORTO = *"<CODA>"* ]] && [[ $CHECK_SALDO = *"<CODA>"* ]] && [[ $CHECK_STRUTTURA = *"<CODA>"* ]]; then
  echo FLUSSI COMPLETI >> $LOGFILE
else
  echo ERROR FLUSSI NON COMPLETI: Cliente:$CHECK_CLIENTE, Prodotti:$CHECK_PRODOTTI, Profilo:$CHECK_PROFILO, Rapporti:$CHECK_RAPPORTO, Struttura:$CHECK_STRUTTURA, Saldi:$CHECK_SALDO >> $LOGFILE
  echo return code 6 >> $LOGFILE
  return 6
fi



export CLIENTE=$(head -n1 $FLUSSO_CLIENTE_LAST | cut -d'"' -f 2)
export PRODOTTI=$(head -n1 $FLUSSO_PRODOTTI_LAST | cut -d'"' -f 2)
export PROFILO=$(head -n1 $FLUSSO_PROFILO_LAST | cut -d'"' -f 2)
export RAPPORTO=$(head -n1 $FLUSSO_RAPPORTO_LAST | cut -d'"' -f 2)
export SALDO=$(head -n1 $FLUSSO_SALDO_LAST | cut -d'"' -f 2)
export STRUTTURA=$(head -n1 $FLUSSO_STRUTTURA_LAST | cut -d'"' -f 2)


if [ $CLIENTE = $PRODOTTI ]  && [ $PRODOTTI = $PROFILO ] && [ $PROFILO = $RAPPORTO ] && [ $RAPPORTO = $STRUTTURA ] && [ $STRUTTURA = $SALDO ];then
	echo DATE UGUALI: $CLIENTE >> $LOGFILE
else
	echo ERROR DATE FLUSSI DIVERSE: Cliente:$CLIENTE, Prodotti:$PRODOTTI, Profilo:$PROFILO, Rapporti:$RAPPORTO, Struttura:$STRUTTURA, Saldi:$SALDO >> $LOGFILE
	echo return code 7 >> $LOGFILE
	return 7
fi


rm -f $PFP_FLUSSI/Cru_Gest_gerarchia_gestore_up.csv
export LAST_CRU_GEST_UPDATE=`ls -Atr $PFP_FLUSSI/Cru_Gest_gerarchia_gestore_up_* | tail -n 1`
cp -f $LAST_CRU_GEST_UPDATE $PFP_FLUSSI/Cru_Gest_gerarchia_gestore_up.csv


return 0

