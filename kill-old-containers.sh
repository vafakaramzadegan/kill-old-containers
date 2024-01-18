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
    OUTPUT=($(docker ps --format "{{.ID}} {{.Names}} {{.Image}}" | grep "${2}"))
    # change IFS to its initial value
    IFS=$INITIAL_IFS
    
    printf "Killing containers"
    if [ -n "${1}" ]; then
        printf " older than ${1} seconds"
    fi
    if [ -n "${2}" ]; then
        if [ -n "${1}" ]; then
            printf " and contains name ${2}"
        else
            printf " contains name ${2}"
        fi
    fi
    printf ":\n\n"

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
        if [[ $(uname) == "Darwin" ]]; then
            # oh... macOS!
            # extracts, processes, and formats a date string obtained from Docker container metadata.
            # it transforms the date string into a Unix timestamp using the macOS-specific date command
            # options -jf "%Y-%m-%d %H:%M:%S". The intermediate steps involve cutting the string to the
            # first 19 characters, replacing 'T' with a space, and passing it as an argument to the date
            # command via xargs. any contributions to simplify this are welcome! :)
            CONT_TIMESTAMP=$(docker inspect --format="{{.State.StartedAt}}" $CONT_ID | cut -c1-19 | tr 'T' ' ' | xargs -I{} date -jf "%Y-%m-%d %H:%M:%S" "{}" "+%s")
        elif [[ $(uname) == "Linux" ]]; then
            # Linux
            CONT_TIMESTAMP=$(docker inspect --format="{{.State.StartedAt}}" $CONT_ID | xargs date +%s -d)
        fi

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
        printf "\nkilled $NUM_KILLED containers.\n\n"
    fi
}

# check if Docker is installed
if [ ! -x "$(command -v docker)" ]; then
    echo "Error: You don't even have Docker installed on your machine! :/"
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
                echo "Error: Invalid time format: $time_arg"
                exit 1
            fi;;
        * )
            echo "Error: Invalid argument: $1"
            exit 1;;
    esac
    shift
done

if [ -z "$TIME" ] && [ -z "$SEARCH" ]; then
    echo "Error: Both TIME and SEARCH parameters are empty. At least one should be provided."
    exit 1
fi

kill_old_containers "$TIME" "$SEARCH"
