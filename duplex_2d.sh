#! /bin/bash

export JAVA_HOME="/usr/java/jre1.8.0_91"
export CLASSPATH="$JAVA_HOME/lib"
export PATH="$PATH:$JAVA_HOME/bin"

dir=$(pwd)
cd /home/wangjian/server/ContextFold
java -cp bin contextFold.app.Predict in:${1}
cd ${dir}
