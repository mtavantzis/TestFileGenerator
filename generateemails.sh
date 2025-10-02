mycommand="find /var/spool/smap/incoming/sec97las.DIGITALSAFE.NET | grep eml | wc -l"
test=$(eval $mycommand)
if(($test < 2000));then
mylastnum="cat /store/testdata/TestFileGenerator-0.7.3/mnum"
emylastnum=$(eval $mylastnum)
cd /store/testdata/TestFileGenerator-0.7.3; start_date=$(date -d '1 day ago' +"%F %T"); end_date=$(date +"%F %T")
#myrowline="rowCount=$emylastnum"
#echo $myrowline > /store/testdata/TestFileGenerator-0.7.3/rowline
#cat /store/testdata/TestFileGenerator-0.7.3/configs/examples/eml-perf_1.config /store/testdata/TestFileGenerator-0.7.3/rowline /store/testdata/TestFileGenerator-0.7.3/configs/examples/eml-perf_2.config > /store/testdata/TestFileGenerator-0.7.3/configs/examples/eml-perf.config
bash datagen.sh -params "date_start=$start_date;date_end=$end_date;" -c examples/eml-perf -rc $emylastnum > eml-perf_output.txt
perl send-messages -d /var/spool/smap/incoming -m sec97las.dom@sec97las.DIGITALSAFE.NET -r sec97las.dom@sec97las.DIGITALSAFE.NET -s output/examples-eml-perf/ > eml-perf_send_output.txt
rm -rf output/examples-eml-perf
bash datagen.sh -params "date_start=$start_date;date_end=$end_date;" -c examples/eml-perf-attach-pool > eml-perf-attach-pool_output.txt
perl send-messages -d /var/spool/smap/incoming -m sec97las.dom@sec97las.DIGITALSAFE.NET -r sec97las.dom@sec97las.DIGITALSAFE.NET -s output/examples-eml-perf-attach-pool/ > eml-perf-attach-pool_send_output.txt
rm -rf output/examples-eml-perf-attach-pool
if(($test > 0));then
mynewnum=$(expr $emylastnum - 2500)
else
mynewnum=$(expr $emylastnum + 2000)
fi
echo $mynewnum > /store/testdata/TestFileGenerator-0.7.3/mnum
else
printf "there are still messages waiting to be sent ($test)\n"
mylastnum="cat /store/testdata/TestFileGenerator-0.7.3/mnum"
emylastnum=$(eval $mylastnum)
mynewnum=$(expr $emylastnum - 5000)
if(($mynewnum < 1));then
mynewnum=1
fi
echo $mynewnum > /store/testdata/TestFileGenerator-0.7.3/mnum
fi
