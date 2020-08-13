issuedetails="$1"
deploymentconfig="$2"
token="$3"
smstoken="$4"
adotoken="$5"
mobilenumber="$6"



        echo "Creating Ticket in Azure DevOps"
        cmd=`curl -X POST 'https://dev.azure.com/i2devops/i2devops/_apis/wit/workitems/$Task?api-version=5.1' -H 'Content-Type: application/json-patch+json' -H "authorization: Basic $adotoken" -d '[{"op": "add",    "path": "/fields/System.Title",    "from": "default",    "value": "$issuedetails"  },  {    "op": "add",    "path": "/fields/System.AssignedTo",    "value": "Jins Thomas"  },  {    "op": "add",    "path": "/fields/System.Tags",    "value": "i2devops"  }]'`
        ticketid=`echo $cmd | jq .id`
        echo "Created Ticket $ticketid"

        echo "Executing OC Commands"
        ./oc login --token=Ns9Q0zEUDSvDs-Guyp60uUIoEvNXUmOBMHeQv1IpSAE --server=https://c100-e.eu-gb.containers.cloud.ibm.com:30450

        ./oc project i2devops
        output=`./oc rollout undo dc/$deploymentconfig`

        #sleep for 1 minute for pod to restart
        sleep 1

        currentmemory=`./oc adm top pods i-2-devops-sprint-result-ui-4-4cwsd | awk '/i-2-devops-sprint-result-ui-4-4cwsd/ {print $3}' | sed -e "s/Mi//g"`
        echo "Current Memory : $currentmemory"

        if [ $(($currentmemory)) < 50 ]
        then
                        echo "Closing Ticket $1"
                        cmd=`curl -X PATCH 'https://dev.azure.com/i2devops/i2devops/_apis/wit/workitems/$ticketid?api-version=5.1' -H 'Content-Type: application/json-patch+json' -H 'authorization: Basic OjRub3lyb2F4NGhnaWZoYWdmbWl4Y28yNmxoajRmdDczYmRpZms3M2RyM3puaGxneTI1YmE=' -d '[{"op": "add",    "path": "/fields/System.State",    "from": "default",    "value": "Done" }]'`

                        echo "Sending the Update to Slack"
                        curl -X POST -H 'Content-type: application/json' --data '{"text":"Ticket $ticketid Remediated Successfully"}'  https://hooks.slack.com/services/T018BGFM3M4/B01964QPZJM/$token
                else
                        echo "Issue Not Resolved. Update Slack"
                        curl -X POST -H 'Content-type: application/json' --data '{"text":"Ticket $ticketid Couldnt be Remediated."}'  https://hooks.slack.com/services/T018BGFM3M4/B01964QPZJM/$token

                        echo "Notifying the End User on Configured Mobile Numbers"
			curl -X POST https://www.fast2sms.com/dev/bulk -H 'authorization: $smstoken' -d "sender_id=FSTSMS&message=i2devops ALERT: Ticket $ticketid Couldnt be Remediated&language=english&route=p&numbers=$mobilenumber"
