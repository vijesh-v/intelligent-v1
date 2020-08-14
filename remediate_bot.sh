issuedetails="$1"
deploymentconfig="$2"
slacktoken="$3"
smstoken="$4"
adotoken="$5"
mobileno="$6"



        echo "Creating Ticket in Azure DevOps"
        cmd=`curl -X POST 'https://dev.azure.com/i2devops/i2devops/_apis/wit/workitems/$Task?api-version=5.1' -H 'Content-Type: application/json-patch+json' -H "authorization: Basic $adotoken" -d "[{\"op\": \"add\",    \"path\": \"/fields/System.Title\",    \"from\": \"default\",    \"value\": \"$issuedetails\"  },  {    \"op\": \"add\",    \"path\": \"/fields/System.AssignedTo\",    \"value\": \"Jins Thomas\"  },  {    \"op\": \"add\",    \"path\": \"/fields/System.Tags\",    \"value\": \"i2devops\"  }]"`
        ticketid=`echo $cmd | jq .id`
        echo "Created Ticket $ticketid"

        echo "Executing OC Commands"
        ./oc login --token=Ns9Q0zEUDSvDs-Guyp60uUIoEvNXUmOBMHeQv1IpSAE --server=https://c100-e.eu-gb.containers.cloud.ibm.com:30450

        ./oc project i2devops
        output=`./oc rollout undo dc/$deploymentconfig`
        echo "Getting new pod details ...."

        #sleep for 1 minute for pod to restart
        sleep 30

        newpodid=`./oc get pods | grep "i-2-devops-sprint-result-ui" | grep "Running" | awk '{print $1;}'`
        echo " new pod id $newpodid"
        ret=1
  
        testone=0
         #currentmemory=`./oc adm top pods $newpodid | grep $newpodid | awk '{print $3}' | sed -e "s/Mi//g" | head -n 1`
	 
        while [ $ret -ne 0 ]
        do
        ./oc adm top pods $newpodid
        ret=$?
        echo "Waiting for the Metrics to be available. Current Status : $ret "
        test=`expr $testone + 1`
        if [ $testone -eq 15 ]
        then
                echo "Timeout Reached. Exiting"
                break
        fi
        sleep 10
        done
        currentmemory=`./oc adm top pods $newpodid | grep $newpodid | awk '{print $3}' | sed -e "s/Mi//g" | head -n 1`

        echo "Current Memory : $currentmemory "

        a=`expr $currentmemory - 0`
        echo " the updated value $a "   
        if [ $a -lt 50 ]
        then
                        echo "Closing Ticket $1"
                        cmd=`curl -X PATCH "https://dev.azure.com/i2devops/i2devops/_apis/wit/workitems/$ticketid?api-version=5.1" -H 'Content-Type: application/json-patch+json' -H "authorization: Basic $adotoken" -d '[{"op": "add",    "path": "/fields/System.State",    "from": "default",    "value": "Done" }]'`

                        echo "Sending the Update to Slack"
                        curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"Ticket <https://dev.azure.com/i2devops/i2devops/_workitems/edit/$ticketid|$ticketid>  Remediated Successfully\"}"  "https://hooks.slack.com/services/T018BGFM3M4/B01964QPZJM/$slacktoken"
        else
                        echo "Issue Not Resolved. Update Slack"
                        curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"Ticket $ticketid Couldnt be Remediated.\"}"  "https://hooks.slack.com/services/T018BGFM3M4/B01964QPZJM/$slacktoken"

                        echo "Notifying the End User on Configured Mobile Numbers"
                        curl -X POST https://www.fast2sms.com/dev/bulk -H "authorization: $smstoken" -d "sender_id=FSTSMS&message=i2devops ALERT: Ticket $ticketid Couldnt be Remediated&language=english&route=p&numbers=$mobileno"

        fi
