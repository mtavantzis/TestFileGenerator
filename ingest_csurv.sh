manifestBucket=$(cat $1 | awk -F'/' '{print $3}' | sort | uniq)
manifestPath=$(cat $1 | awk -F'/' '{$1=$2=$3=$NF=""; print $0}' | sort | uniq | awk ' { sub (/^ [ ]+/, ""); print }' | awk -F: '{ gsub(/ /, "/", $1); print $1 }')

for i in `cat $1 | awk -F'/' '{print $(NF)}' | tr -d '\r'`; do s3cmd put output/Enron_LDIF_CSurv/$i s3://$manifestBucket/$manifestPath; done;

s3cmd put $1 s3://$manifestBucket/$2; echo "$manifestBucket $2" > tempManifestlocation;

cp participantPermissionsMap.json ../../resources/datajetway/
cp participantPropertyMapping.json ../../resources/datajetway/ 

curl -v -k -u admin:1234 -H 'Content-Type: application/json' -XPUT -d "@dataRoles.json" http://core5-3.dev.digitalreasoning.com:8922/api/admin/data-roles/bulk
curl -v -k -u admin:1234 -H 'Content-Type: application/json' -XPUT -d "@userInformation.json" http://core5-3.dev.digitalreasoning.com:8922/api/admin/users/bulk
cd ..
cd ..
./bin/synth jet pipelines/s3EmlToHdfsPipeline.groovy -f config/s3EmlToHdfsPipeline.yaml -DkgName=$4 -DmanifestBucket=$manifestBucket -DmanifestPath=$2 -Doutput=$3 -DenableAudit=false -DwaitOnCreate=false -DremovePipelineAfterFinish=true
echo "./bin/synth jet pipelines/s3EmlToHdfsPipeline.groovy -f config/s3EmlToHdfsPipeline.yaml -DkgName=$4 -DmanifestBucket=$manifestBucket -DmanifestPath=$2 -Doutput=$3 -DenableAudit=false -DwaitOnCreate=false -DremovePipelineAfterFinish=true"
output="_output";
complianceEmlPipeline_output=$3$output;

./bin/synth jet pipelines/complianceEmlPipeline.groovy -f config/complianceEmlPipeline.yaml -DkgName=$4 -Dinput=$3 -Doutput=$complianceEmlPipeline_output -DenableAudit=false -DwaitOnCreate=false -DremovePipelineAfterFinish=true
echo "./bin/synth jet pipelines/complianceEmlPipeline.groovy -f config/complianceEmlPipeline.yaml -DkgName=$4 -Dinput=$3 -Doutput=$complianceEmlPipeline_output -DenableAudit=false -DwaitOnCreate=false -DremovePipelineAfterFinish=true"

curl -X POST -u admin:1234 -H 'Content-Type: application/json' -d "{\"kb\": \"$4\", \"processType\": \"oozie\", \"application\":\"conduct-surveillance-workflow\", \"invocationConfig\": {\"input_rawText\": \"$complianceEmlPipeline_output\", \"shouldRunReconciliation\": \"false\",\"shouldRunProfiles\": \"false\",\"shouldRunDedup\": \"false\"}}" http://core5-3.dev.digitalreasoning.com:8922/synic/api/process


#curl -X POST -u admin:1234 -H 'Content-Type: application/json' -d "{\"kb\": \"$4\", \"processType\": \"oozie\", \"application\":\"conduct-surveillance-workflow\", \"invocationConfig\": {\"input_rawText\": \"$complianceEmlPipeline_output\", \"shouldRunReconciliation\": \"false\"},\"shouldRunProfiles\": \"false\"},\"shouldRunDedup\": \"false\"}}" http://core5-3.dev.digitalreasoning.com:8922/synic/api/process
#python synth-executor.py startingestion --kg $4 --hdfsrawdata $complianceEmlPipeline_output;

