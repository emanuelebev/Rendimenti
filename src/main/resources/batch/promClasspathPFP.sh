#!/bin/bash
export PFP_BATCH=/opt/POSTE/PFP_App/PFPbatchRendimenti/batch/
. ${PFP_BATCH}promSettings.sh
# add all jars in Classpath
PFP_CLASSPATH=""
for lib in `ls ${PFP_LIB}*.jar`
 do 
   export PFP_CLASSPATH="$lib:${PFP_CLASSPATH}"
 done

export PFP_CLASSPATH
echo $PFP_CLASSPATH > computed_classpath.txt
