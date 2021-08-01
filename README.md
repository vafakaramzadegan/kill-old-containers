# kill-old-containers
Using this script, you can easily remove docker containers running for more than a specific time.

The only option Docker provides is `$ docker container prune`. this just removes containers that are already stopped, but not automatically removed.
however, there are situations that you might want to remove an active container.

`kill-old-containers` is simply a bash script that parses the output of `$ docker container ls` command and gets the list of all active containers and how long they've been running for.

consequently, the script `kill`s the ones running over a certain amount of time.

## Usage
Simply invoke the script through terminal. you can even set a cron job to automate the process:

```
$ ./kill-old-containers.sh [number of seconds]
```

Case in point: This kills containers that have been running for over an hour:
```
$ ./kill-old-containers.sh 3600
```
