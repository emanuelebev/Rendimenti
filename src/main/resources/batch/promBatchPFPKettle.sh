#!/bin/bash
trap 'echo Terminazione forzata del processo;exit 255' 1 2 3 6 15
# ------------------------------------------------
# SHELL RICHIAMATA DA ALTRA SHELL
# Batch Pfp - passare come parametro i nomi dei 
# file xml da eseguire, con percorso completo
# ------------------------------------------------
. ${PFP_BATCH}promSettings.sh
cd ${PFP_CONF_HOME}
. ${PFP_BATCH}promClasspathPFPKettle.sh
echo classpath: ${PFP_CLASSPATH}

${JAVA_HOME}java -Duser.language=en -Duser.region=US -Xmx7000M -classpath ${PFP_CLASSPATH} it.prometeia.kettle.ExecuteKettle $1 ${PFP_INI}pfp.ini

