# kill-old-containers
Using this script, you can easily remove old Docker containers.

Docker provides methods to remove orphan containers or the ones that are already stuck. however, you may want to remove active and healthy containers only because they've been running for more than a specific amount of time.

`kill-old-containers` does the job for you!

## Usage
Simply invoke the script in the terminal. you can even set up a cron job to automate the process:

```
$ ./kill-old-containers.sh -t | --time [number of seconds]
```
You can also search for certain containers. for instance, this kills containers older than 2 minutes with their titles containing "nginx":
```
$ ./kill-old-containers.sh --time 120 --search nginx
```
