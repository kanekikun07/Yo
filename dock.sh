#!/bin/bash

# Download proxy.py script and generate proxies.txt
wget https://raw.githubusercontent.com/kanekikun07/Yo/refs/heads/main/proxy.py
pip install requests
python proxy.py

# Read proxies into array
mapfile -t proxies < proxies.txt
total=${#proxies[@]}

if [ $total -lt 100 ]; then
  echo "Error: Need at least 100 proxies, found $total"
  exit 1
fi

# Shuffle proxies for random assignment
shuffled=($(shuf -e "${proxies[@]}"))

for i in $(seq 1 100); do
  proxy_url=${shuffled[$((i-1))]}

  proto=$(echo "$proxy_url" | sed -E 's#^(.*)://.*#\1#')
  hostport=$(echo "$proxy_url" | sed -E 's#.*://(.*)#\1#')
  host=$(echo "$hostport" | cut -d':' -f1)
  port=$(echo "$hostport" | cut -d':' -f2)

  # Create proxychains config file for this proxy
  config_file="proxychains_${i}.conf"
  cat > "$config_file" <<EOF
strict_chain
proxy_dns

[ProxyList]
$proto $host $port
EOF

  echo "Starting container $i with proxy $proxy_url"

  docker run -d \
    -v "$PWD/$config_file":/etc/proxychains.conf:ro \
    --name proxychains_container_$i \
    proxychains-image \
    curl -s https://ifconfig.me

  # Optional: remove config file after starting container
  # rm "$config_file"
done
