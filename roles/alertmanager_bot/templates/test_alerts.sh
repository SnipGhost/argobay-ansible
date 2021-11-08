#!/bin/sh

if [ "$#" -lt "1" ]; then
	SEVERITY="critical"
else
	SEVERITY="$1"
fi

DATE_STARTS=$(date -d '-2 hour' -Is)
DATE_ENDS=$(date -d '-1 hour' -Is)

ALERTMANAGER_HOST="{{ alertmanager_host }}"
ALERTMANAGER_PORT="{{ alertmanager_port }}"

ALERTMANAGER_BOT_HOST="{{ alertmanager_bot_host }}"
ALERTMANAGER_BOT_PORT="{{ alertmanager_bot_port }}"

put_message_to_bot() {
	LEVEL=$1
	STATUS=$2
	if [ "$#" -eq "3" ]; then
		ADD_ENV="\"env\":\"${3}\","
	else
		ADD_ENV=""
	fi
	ALERT_TEMPLATE="{
		\"receiver\":\"telegram\",
		\"status\":\"${STATUS}\",
		\"alerts\":[
			{
				\"status\":\"${STATUS}\",
				\"labels\":{
					${ADD_ENV}
					\"alertname\":\"TestAlert\",
					\"severity\":\"${LEVEL}\"
				},
				\"annotations\":{
					\"message\":\"Something is on fire\"
				},
				\"startsAt\":\"${DATE_STARTS}\",
				\"endsAt\":\"${DATE_ENDS}\",
				\"generatorURL\":\"http://localhost:9090/graph?g0.expr=vector%28666%29\u0026g0.tab=1\"
			}
		],
		\"groupLabels\":{
			\"alertname\":\"TestAlert\"
		},
		\"commonLabels\":{
			${ADD_ENV}
			\"alertname\":\"TestAlert\",
			\"severity\":\"${LEVEL}\"
		},
		\"commonAnnotations\":{
			\"message\":\"Something is on fire\"
		},
		\"externalURL\":\"http://${ALERTMANAGER_HOST}:${ALERTMANAGER_PORT}\",
		\"version\":\"4\",
		\"groupKey\":\"{}:{alertname=\\\"TestAlert\\\"}\"
	}"
	curl --request POST --data "$ALERT_TEMPLATE" "${ALERTMANAGER_BOT_HOST}:${ALERTMANAGER_BOT_PORT}"
}

# Function         SEVERITY  TYPE   ENV 
put_message_to_bot $SEVERITY firing prod
put_message_to_bot $SEVERITY firing dev
put_message_to_bot $SEVERITY firing omega
put_message_to_bot $SEVERITY firing

put_message_to_bot $SEVERITY resolved prod
put_message_to_bot $SEVERITY resolved dev
put_message_to_bot $SEVERITY resolved omega
put_message_to_bot $SEVERITY resolved
