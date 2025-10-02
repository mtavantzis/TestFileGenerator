@echo off
rem SET JRE_HOME=C:\java\jdk1.8.0_65\jre
rem SET PATH=%PATH%;%JRE_HOME%\bin
java -cp %0\..\*;%0\..\lib\* microfocus.datagen.command.CommandLineInterface %*