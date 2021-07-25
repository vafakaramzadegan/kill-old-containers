# kill-old-containers
By using this script, you can easily remove docker containers which have been running for more than a specific time.

The only option Docker provides is `$ docker container prune`. this just removes containers that are already stopped.
however, there are situations that you might want to remove an active container.

`kill-old-containers` is simply a bash script that parses the output of `$ docker container ls` command and gets the list of active containers and how long they've been running for.

consequently, the script `kill`s the ones that have been running over a certain amount of time.

## Usage
Simply invoke the script through terminal or inside your script. you can even set a cron job to automate the process:

```
$ ./kill-old-containers.sh [number of seconds]
```
This kills containers that have been running for over an hour:
```
$ ./kill-old-containers.sh 3600
```
