#!/bin/bash

echo "Hello, World bigzero, v2" > index.html
nohup busybox httpd -f -p ${server_port} &