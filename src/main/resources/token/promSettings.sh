#!/bin/sh
# Configurazione macchina test
export PFP_CONF_HOME=@TOKEN_BATCH_HOME@/
export PFP_INI=${PFP_CONF_HOME}ini/
export PATH_FASI_XML=${PFP_INI}dataIntegration/
export PATH_JOB_KETTLE=${PFP_CONF_HOME}jobs/
export PFP_BATCH=${PFP_CONF_HOME}batch/
export PFP_LIB=${PFP_CONF_HOME}libBatch/
export PFP_LIB_KETTLE=${PFP_CONF_HOME}libKettle/
export JAVA_HOME=@TOKEN_JAVA_HOME@
export ENABLE_JACOCOAGENT=@TOKEN_ENABLE_JACOCOAGENT@
export PATH_PFP_LOG=${PFP_CONF_HOME}/batch/
export PFP_FLUSSI=@TOKEN_PATH_FLUSSI@
export PFP_FLUSSI_PROFONDITA_RICERCA_SETT=7
export PFP_FLUSSI_PROFONDITA_RICERCA_GIORNALIERA=1
export PATH_EXPORT_GARANTE=@TOKEN_OUTPUT_REND_GARANTE@
export IP_SEND_GARANTE_LOG=@TOKEN_IP_SEND_GARANTE_LOG@

analizzaLog() {
	if [ -z $LOGFILE ]
	then
        echo analizzaLog variable LOGFILE is not set
        return 13
	fi
	if [ ! -f $LOGFILE ]
	then
        echo analizzaLog $LOGFILE does not exist
        return 13
	fi
	echo analizzaLog start
	date >> $LOGFILE
	if grep -qiE "ERROR.*Exception" $LOGFILE
	then
	   echo analizzaLog return code 11 >> $LOGFILE
	   return 11
	elif  grep -qiE "KO_ANAG_RUNCOM_NULL|KO_ANAG_RUNCOM_EMPTY" $LOGFILE
	then
	   echo analizzaLog return code 14 >> $LOGFILE
	   return 14
	elif  grep -qiE "KO_ANAG_RUNCOM_FILE_NOT_UPDATED" $LOGFILE
	then
	   echo analizzaLog return code 15 >> $LOGFILE
	   return 15
	elif  grep -qE "ORA-[0-9]{5}" $LOGFILE
	then
	   echo analizzaLog return code 16 >> $LOGFILE
	   return 16
	elif  grep -qE "^ERROR" $LOGFILE
	then
	   echo analizzaLog return code 17 >> $LOGFILE
	   return 17
	else
	        if grep -qi "BATCH executed in"  $LOGFILE
	        then
	                echo analizzaLog return code 0 >> $LOGFILE
	                return 0
	        else
	                echo analizzaLog return code 12 >> $LOGFILE
	                return 12
	        fi
	fi
}


checkFile() {

 	for ARG in "$@"
    do
	    if [ ! -f $ARG ]
		then
	    	echo file $1 does not exist
	    	return 11
		fi

		if [ ! -s $ARG ]
		then
	      echo file $1 is empty
	      return 12
		fi
    done
    return 0
}

checkTodayFile() {
 	if [ ! -f $1 ]
	then
    	echo file $1 does not exist
    	echo "File $1 NOT exists"
    	return 11
	fi

	if [[ $(find "$1" -daystart -mtime 0 -print) ]]; then
 	    echo "File $1 exists and is updated"
		return 0
	fi
	echo "File $1 exists and is NOT updated"
    return 11
}

checkDataFile() {
 	for ARG in "$@"
    do
		if [[ $(find "$ARG" -mtime +1 -print) ]]; then
 			 echo "File $ARG exists and is older than 1 days"
 			 return 11
		fi
    done
    return 0
}

manageEstrazione() {

	export EXPORTYPE=""

	if [ $# -gt 1 ]; then
        echo "Shell chiamata con range estrazione: "$2 $3

        if [ "$2" != "" ]; then
            echo "Parametro Start - STARDATE:"$2
            export STARTDATE=$2
        else
            echo "Errore - Parametro Start vuoto"
            return 11
        fi

        if [ "$3" != "" ]; then
            echo "Parametro End - ENDDATE:"$3
            export ENDDATE=$3
        else
            echo "Errore - Parametro End vuoto"
            return 11
        fi  
        
		if [ ! -z "${STARTDATE##*[!0-9]*}" ]; then

			 echo "STARTDATE is a number"

		else
 			echo "Errore - STARTDATE is NOT a number"
 			return 11
 
		fi         
		
		if [ ! -z "${ENDDATE##*[!0-9]*}" ]; 
		then

			 echo "ENDDATE is a number"

		else
 			echo "Errore - ENDDATE is NOT a number"
 			return 11
 
		fi  
		
		if [[ $STARTDATE =~ ^[0-9]{8}$ ]];
			then

			 echo "STARTDATE as valid format"

		else
 			echo "Errore - STARTDATE has NOT a valid format yyyymmgg"
 			return 11
 
		fi 	

		if [[ $ENDDATE =~ ^[0-9]{8}$ ]];
			then

			 echo "ENDDATE as valid format"

		else
 			echo "Errore - ENDDATE has NOT a valid format yyyymmgg"
 			return 11
 
		fi 

		
		if [ "$STARTDATE" -gt "$ENDDATE" ]; then
    		echo "Errore -  STARTDATE e ENDDATE non ordinate"
   		 	return 11
		fi
		EXPORTYPE="_RANGE_${STARTDATE}_${ENDDATE}"
				    
	else
    	echo "Shell chiamata senza range estrazione - utilizzo profondita di ricerca DEFAULT: "$1

		export ENDDATE=$(date '+%Y%m%d')
		export date_diff=$1
		export STARTDATE=$(date --date="${mydate} -${date_diff} day" +%Y%m%d)
		
	fi


	echo "Inizio data estrazione STARTDATE:" $STARTDATE
	echo "Fine data estrazione ENDDATE:" $ENDDATE
	return 0

}

logPrivacyOp() {
        if [ ! -f "$EXPORTGARANTE_FILE" ];
        then
                echo "$EXPORTGARANTE_FILE not exists." >> $LOGFILE
                rm $EXPORTGARANTE_FILE_CODA
                return 11
        fi
        if [ ! -f "$EXPORTGARANTE_FILE_CODA" ];
        then
        	echo "$EXPORTGARANTE_FILE_CODA not exists." >> $LOGFILE
        	if [ -f "$EXPORTGARANTE_FILE" ];
                then
                echo "$EXPORTGARANTE_FILE exists. Removing" >> $LOGFILE
                rm $EXPORTGARANTE_FILE
            fi
            return 11
        fi
        
        cat $EXPORTGARANTE_FILE_CODA >> $EXPORTGARANTE_FILE
        RESULT_CAT=$?
        if [ $RESULT_CAT -gt 0 ];
        then
                echo "ERROR CONCATENATING DETAIL FILE $EXPORTGARANTE_FILE WITH FOOTER FILE $EXPORTGARANTE_FILE_CODA" >> ${LOGFILE}
                rm $EXPORTGARANTE_FILE
                rm $EXPORTGARANTE_FILE_CODA
                return 11
        fi

        rm $EXPORTGARANTE_FILE_CODA

    return 0
}
