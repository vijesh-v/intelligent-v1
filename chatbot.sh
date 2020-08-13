./oc login --token=Ns9Q0zEUDSvDs-Guyp60uUIoEvNXUmOBMHeQv1IpSAE --server=https://c100-e.eu-gb.containers.cloud.ibm.com:30450

./oc project i2devops
output=`./oc get pods | awk '/Running/ {print}'`

curl -X POST -H 'Content-type: application/json' --data "{\"text\": \"$output\"}" https://hooks.slack.com/services/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
