command="$1"

echo "Executing Command : $command"

if [[ "$command" -eq "get pods"" ]]
then
        ./oc login --token=Ns9Q0zEUDSvDs-Guyp60uUIoEvNXUmOBMHeQv1IpSAE --server=https://c100-e.eu-gb.containers.cloud.ibm.com:30450

        ./oc project i2devops
        output=`./oc get pods | awk '/Running/ {print}' | awk 'BEGIN {printf("%-10s %-10s %-10s %-10s %-20s\n" ,"AGE", "READY", "STATUS", "RESTARTS", "NAME")} {printf("%-10s %-10s %-10s %-10s %-20s\n", $5, $2, $3, $4, $1)}''`

        echo $output

        curl -X POST -H 'Content-type: application/json' --data "{\"text\": \"$output\"}" https://hooks.slack.com/services/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
fi


