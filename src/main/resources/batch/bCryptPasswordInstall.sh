#!/bin/bash

. /opt/POSTE/PFP_App/PFPbatchRendimenti/batch/promSettings.sh
. /opt/POSTE/PFP_App/PFPbatchRendimenti/batch/promClasspathPFP.sh

${JAVA_HOME}java -Duser.language=en -Duser.region=US -classpath ${PFP_CLASSPATH} it.prometeia.pfpweb.batch.Encrypt $1


