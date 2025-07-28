#!/bin/bash
trap 'echo Terminazione forzata del processo;exit 255' 1 2 3 6 15
# ------------------------------------------------
# SHELL RICHIAMATA DA ALTRA SHELL
# Batch Pfp - passare come parametro i nomi dei
# file xml da eseguire, con percorso completo
# ------------------------------------------------
. ${PFP_BATCH}promSettings.sh
cd ${PFP_CONF_HOME}
. ${PFP_BATCH}promClasspathPFP.sh
echo classpath: ${PFP_CLASSPATH}

export GC_LOGFILE="gc.log"
if [[ -z "${LOGFILE}" ]]
then
    export GC_LOGFILE="gc.log"
else
    export GC_LOGFILE="${LOGFILE}.gc.log"
fi

echo "printenv"
printenv
echo "writing GC info to $GC_LOGFILE"
echo "JAVA_OPS $JAVA_OPS"
echo ${JAVA_HOME}java ${JAVA_OPS} -Duser.language=en -Duser.region=US -Xmx7000M -classpath ${PFP_CLASSPATH} -DEXTRACT_START=$2 -DEXTRACT_END=$3  -DGARANTE_FILENAME_PREFIX=$4 -DACTUAL_HM=$5 it.prometeia.pfpweb.batch.ExecuteJobsRendNoAmbiente $1 -ini ${PFP_INI}
${JAVA_HOME}java ${JAVA_OPS} -Duser.language=en -Duser.region=US -Xmx7000M -classpath ${PFP_CLASSPATH} -DEXTRACT_START=$2 -DEXTRACT_END=$3  -DGARANTE_FILENAME_PREFIX=$4 -DACTUAL_HM=$5 it.prometeia.pfpweb.batch.ExecuteJobsRendNoAmbiente $1 -ini ${PFP_INI}