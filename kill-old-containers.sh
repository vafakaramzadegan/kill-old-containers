#!/bin/bash

YELLOW='\033[1;33m'
LIGHT_CYAN='\033[1;36m'
# no color
NC='\033[0m'

function kill_old_containers(){
    # changing IFS to newline helps converting "$(docker ps)" output
    # to array items
    INITIAL_IFS=$IFS
    IFS=$'\n'
    # docker ps output: [CONTAINER ID] [CONTAINER NAME]
    OUTPUT=($(docker ps --format "{{.ID}} {{.Names}}" | grep "${2}"))
    # change IFS to its initial value
    IFS=$INITIAL_IFS
    printf "Killing containers older than ${1} seconds:\n\n"
    CONT_COUNT=${#OUTPUT[@]}
    if [ $CONT_COUNT == 0 ]; then
        echo "No containers found."
        exit 0
    fi
    NUM_KILLED=0
    for (( i=0; i<$CONT_COUNT; i++ ))
    do
        REC=${OUTPUT[$i]}
        # split content of each record by whitespace
        CONT_ID=$(echo $REC | cut -d' ' -f1)
        CONT_NAME=$(echo $REC | cut -d' ' -f2)
        # convert the time the container started to unix timestamp
        CONT_TIMESTAMP=$(docker inspect --format="{{.State.StartedAt}}" $CONT_ID | xargs date +%s -d)
        CURRENT_TIMESTAMP=$(date +%s)
        DIFF=$(expr $CURRENT_TIMESTAMP - $CONT_TIMESTAMP)
        if [[ $DIFF -ge $1 ]]
        then
            echo -e "${YELLOW}$CONT_ID${NC}($CONT_NAME): started ${LIGHT_CYAN}$DIFF${NC} secs ago."
            KILL_CMD="docker kill ${CONT_ID}"
            # invoke docker kill command in the background to prevent
            # possible freezing
            eval "${KILL_CMD}" &>/dev/null & disown
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
            time_arg="$1"
            if [[ $time_arg =~ ^[0-9]+$ ]]; then
                TIME="${time_arg}"
            elif [[ $time_arg =~ ^[0-9]+s$ ]]; then
                TIME="$(expr ${time_arg%?})"
            elif [[ $time_arg =~ ^[0-9]+m$ ]]; then
                TIME="$(expr ${time_arg%?} \* 60)"
            elif [[ $time_arg =~ ^[0-9]+h$ ]]; then
                TIME="$(expr ${time_arg%?} \* 60 \* 60)"
            elif [[ $time_arg =~ ^[0-9]+d$ ]]; then
                TIME="$(expr ${time_arg%?} \* 24 \* 60 \* 60)"
            else
                echo "Invalid time format: $time_arg"
                exit 1
            fi;;
        * )
            echo "Invalid argument: $1"
            exit 1;;
    esac
    shift
done

kill_old_containers "$TIME" "$SEARCH"
