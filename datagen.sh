#!/bin/sh
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export CLASSPATH="lib/*:*"
$JAVA_HOME/bin/java -cp $CLASSPATH microfocus.datagen.command.CommandLineInterface "$@"
