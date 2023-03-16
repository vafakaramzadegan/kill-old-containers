# kill-old-containers
This Bash script provides an easy and efficient way to clean up old Docker containers based on their start time and/or name. Unlike Docker's built-in --timeout parameter, which terminates a container after a certain period of inactivity, this script allows you to specify a specific time interval after which containers are terminated regardless of activity.

## Usage
The script has the following command line arguments:
```
-s | --search [name]: filter containers by name. (optional)
-t | --time [time]: time in seconds, minutes (m), hours (h), or days (d). This argument is required.
```

## Examples
Kill all containers older than 1 hour:
```
$ ./kill-old-containers.sh -t 1h
```
Kill all containers older than 5 minutes and whose name contains "myapp":
```
$ ./kill-old-containers.sh -t 5m -s myapp
```
