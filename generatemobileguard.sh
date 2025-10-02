cd "/mnt/c/Users/michaelj.tavantzis/OneDrive - Smarsh, Inc/TestFileGenerator_abridged"; start_date=$(date -d '1 day ago' +"%F %T"); end_date=$(date +"%F %T")
#myrowline="rowCount=$emylastnum"
#echo $myrowline > /store/testdata/TestFileGenerator-0.7.3/rowline
#cat /store/testdata/TestFileGenerator-0.7.3/configs/examples/eml-perf_1.config /store/testdata/TestFileGenerator-0.7.3/rowline /store/testdata/TestFileGenerator-0.7.3/configs/examples/eml-perf_2.config > /store/testdata/TestFileGenerator-0.7.3/configs/examples/eml-perf.config


bash datagen.sh -params "date_start=$start_date;date_end=$end_date;" -c examples/MobileGuard

outputpath=`grep "outputPath" configs/examples/MobileGuard.config | awk -F'=' '{print $2}'`
#myoutputpath=$(eval $outputpath)

fulloutputpath="output/"$outputpath
echo $fulloutputpath
curlcmd="curl -v --location 'https://app.mobileguard.com/api/ATTMessageService/Archive' --header 'Content-Type: text/plain' --header 'Authorization: Basic U21hcnNoLUFUVC1NRy1BUFA6NXRTOEo5SDl0WHBI' --data '"
nowdate=`date +%s`
echo $nowdate

for i in `ls $fulloutputpath`; do echo -n $curlcmd >> curloutput-$nowdate; echo "@$fulloutputpath/$i'" >> curloutput-$nowdate; echo sleep 1 >> curloutput-$nowdate; done;
sleep 1
