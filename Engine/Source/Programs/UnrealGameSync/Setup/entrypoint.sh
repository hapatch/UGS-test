#!/bin/bash

# Forward signals to the child process for clean `docker stop`
trap 'kill $(jobs -p) 2>/dev/null; wait' SIGTERM SIGINT

p4d -r "$P4ROOT" -p 1666 &

wait
