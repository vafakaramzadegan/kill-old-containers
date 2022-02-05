#!/bin/bash

YELLOW='\033[1;33m'
LIGHT_CYAN='\033[1;36m'
# no color
NC='\033[0m'

function kill_old_containers(){
	# changing IFS to newline helps converting "$(docker ps)" output
	# to array items
	IFS=$'\n'
	# docker ps output: [CONTAINER ID] [CONTAINER NAME]
	OUTPUT=($(docker ps --format "{{.ID}} {{.Names}}" | grep "${2}"))
	printf "Killing containers older than ${1} seconds:\n\n"
	CONT_COUNT=${#OUTPUT[@]}
	if [ $CONT_COUNT == 0 ]; then
		echo "No containers found."
		exit 0
	fi
	NUM_KILLED=0
	for (( 0; i<$CONT_COUNT; i++ ))
	do
		REC=${OUTPUT[$i]}
		# split content of each record by whitespace
		CONT_ID=$(echo $REC | cut -d' ' -f1)
		CONT_NAME=$(echo $REC | cut -d' ' -f2)
		# convert the time the container started to unix timestamp
		CONT_TIMESTAMP=$(docker inspect --format=\"{{.State.StartedAt}}\" $CONT_ID | xargs date +%s -d)
		CURRENT_TIMESTAMP=$(date +%s)
		DIFF=$(expr $CURRENT_TIMESTAMP - $CONT_TIMESTAMP)
		if [[ $DIFF -ge $1 ]]
		then
			echo -e "${YELLOW}$CONT_ID${NC}($CONT_NAME): ${LIGHT_CYAN}$DIFF${NC} seconds ago"
			KILL_CMD="docker kill ${CONT_ID}"
			# invoke docker kill command in the background to prevent
			# possible freezing
			#eval "${KILL_CMD}" &>/dev/null & disown
			let "NUM_KILLED+=1"
		fi
	done
	if [[ $NUM_KILLED -gt 0 ]]; then
		printf "\nkilled $NUM_KILLED containers."
	fi
}

# check if Docker is installed
if [ ! -x "$(command -v docker)" ]; then
	echo "You don't even have Docker installed on your machine! :/"
	exit 0
fi

SEARCH=""
while [ "$1" != "" ]; do
    case $1 in
        -s | --search )
			shift
			SEARCH="$1";;
		-t | --time )
			shift
			TIME=$1
    esac
    shift
done

if [[ "$TIME" -eq "$TIME" ]] 2>/dev/null ; then
	if [[ $TIME -gt 0 ]]; then
		echo "$(kill_old_containers $TIME $SEARCH)"
	else
		echo "Invalid value for the number of seconds!"
		exit 0
	fi
else
	echo "Invalid value for the number of seconds!"
	exit 0
fi
