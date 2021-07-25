#!/bin/bash


function convert_time_ago(){
	# convert "time ago" values to seconds.
	# example:
	# 5 minutes ago => 300
	# 2 hours ago => 7200
	# 1 day ago => 86400
	REGEX="([0-9]+) +([a-z]+)"
	if [[ $1 =~ $REGEX ]]
	then
		VAL=${BASH_REMATCH[1]}
		UNIT=${BASH_REMATCH[2]}
	fi
	case "$UNIT" in
		"seconds" )
			echo $VAL
			;;
		"minutes" )
			echo $(($VAL*60))
			;;
		"hours" )
			echo $(($VAL*3600))
			;;
		"days" )
			echo $(($VAL*86400))
			;;
	esac
}

function kill_old_containers(){
	# regex to parse `$ docker containers list` output.
	# ----------------------------------------------------
	# | CONTAINER ID | ... |   CREATED     | ... | NAMES | 
	# ----------------------------------------------------
	# | ............ | ... | ([0-9]+.+ago) | ... | (.+)  |
	# ----------------------------------------------------
    CONTAINER_REGEX=" +([0-9]+.+ago).+ +(.+)"
    # get containers information.
	# we need to change the internal field separator to newline (\n)
	# this helps converting each line of `$ docker container ls` output
	# to an array item.
    INITIAL_IFS=$IFS
    IFS=$'\n'
	echo "Fetching the list of running containers..."
    OUTPUT=($(docker container ls))
    IFS=$INITIAL_IFS

	echo "Terminating containers older than ${1} seconds:"
    for (( 0; i<${#OUTPUT[@]}; i++ ))
    do
		REC="${OUTPUT[$i]}"
		if [[ $REC =~ $CONTAINER_REGEX ]]
		then
			# BASH_REMATCH[1] contains a string with 3 segments:
			# [integer number] [string (seconds, minutes, hours, days, ...)] ago
			CREATED_TS=$(convert_time_ago ${BASH_REMATCH[1]})
			CONT_NAME="${BASH_REMATCH[2]}"
			# check if container is created before the requested
			# number of seconds.
			if [[ $CREATED_TS -ge $1 ]]
			then
				echo "Terminating ${CONT_NAME}..."
				KILL_CMD="docker kill ${CONT_NAME}"
				# invoke docker kill command in the background to prevent
				# possible freezing.
				eval "${KILL_CMD}" &>/dev/null & disown
			fi
		fi
	done
}


# check if Docker is installed
if [ ! -x "$(command -v docker)" ]; then
	echo "You don't even have Docker installed on your machine! :/"
	exit 0
fi

echo "$(kill_old_containers $1)"
