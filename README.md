# kill-old-containers
Using this script, you can easily remove docker containers running for longer than a specific time.

The only option Docker provides is `$ docker container prune` that only removes containers that are already stopped but are not automatically removed.
however, there are situations where you might want to remove an active container.

`kill-old-containers` is simply a bash script that parses the output of the `$ docker container ls` command and gets the list of all active containers and how long they have been running.

Consequently, the script `kill`s the ones running over a certain amount of time.

## Usage
Simply invoke the script through the terminal. you can even set up a cron job to automate the process:

```
$ ./kill-old-containers.sh [number of seconds]
```

Case in point: This kills containers that have been running for over an hour:
```
$ ./kill-old-containers.sh 3600
```
