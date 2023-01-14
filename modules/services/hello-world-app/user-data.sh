#!/bin/bash

# shell 을 외부화 하면 unit test 를 할 수 있다.
# export db_address=xxxx 

cat > index.html <<EOF
<h1>Hello, World, bigzero</h1>
<p>DB Address: ${db_address}</p>
<p>DB Port: ${db_port}</p>
EOF

nohup busybox httpd -f -p ${server_port} &
