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

export min_mem_param=""
export max_mem_param=""

#se le variabili sono popolate - impostiamo la mem per la JVM
if test -n "${min_mem}"
then
  min_mem_param=-Xms$min_mem
fi

if test -n "${max_mem}"
then
  max_mem_param=-Xmx$max_mem
fi

echo "Java Memory SET - min_mem: ${min_mem}, max_mem: ${max_mem}, min_mem_param: ${min_mem_param}, max_mem_param: ${max_mem_param}"

uname -a
echo "whoami"
whoami

export GC_LOGFILE="gc.log"
if [[ -z "${LOGFILE}" ]]
then
    export GC_LOGFILE="gc.log"
else
    export GC_LOGFILE="${LOGFILE}.gc.log"
fi

export JAVA_OPS=""
export JACOCOAGENT_OPS="-javaagent:${PFP_BATCH}/jacocoagent.jar=includes=*prometeia*,output=file,destfile=${LOGFILE}.jacoco.exec"
echo "JACOCOAGENT_OPS $JACOCOAGENT_OPS"

echo "ENABLE_JACOCOAGENT: $ENABLE_JACOCOAGENT == TRUE"
if [ "$ENABLE_JACOCOAGENT" = "TRUE" ]; then
  export JAVA_OPS="${JAVA_OPS} ${JACOCOAGENT_OPS}"
fi

echo "printenv"
printenv
echo "writing GC info to $GC_LOGFILE"
echo "JAVA_OPS $JAVA_OPS"
echo ${JAVA_HOME}java ${JAVA_OPS} $min_mem_param $max_mem_param -Duser.language=en -Duser.region=US -classpath ${PFP_CLASSPATH} it.prometeia.pfpweb.batch.ExecuteJobsRendAmbiente $1 $2 $3 $4 $5 $6 $7 $8 $9 -ini ${PFP_INI}
${JAVA_HOME}java ${JAVA_OPS} $min_mem_param $max_mem_param -Duser.language=en -Duser.region=US -DDATA_INIZIO=${DATA_INIZIO} -XX:+PrintGCDetails -XX:+PrintGCDateStamps -Xloggc:${GC_LOGFILE} -classpath ${PFP_CLASSPATH} it.prometeia.pfpweb.batch.ExecuteJobsRendAmbiente $1 $2 $3 $4 $5 $6 $7 $8 $9 -ini ${PFP_INI}
