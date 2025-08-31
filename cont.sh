#!/bin/bash

PROXIES_FILE="proxies.txt"
IMAGE_NAME="proxychains-image"
CONTAINER_BASE_NAME="proxychains-container"

# Build the Docker image
docker build -t $IMAGE_NAME .

count=1
while IFS= read -r proxy_line; do
    # Skip empty lines
    [[ -z "$proxy_line" ]] && continue

    # Parse protocol, host, port from proxy URL
    proto=$(echo "$proxy_line" | sed -E 's#^(.*)://.*#\1#')
    hostport=$(echo "$proxy_line" | sed -E 's#.*://(.*)#\1#')
    host=$(echo "$hostport" | cut -d':' -f1)
    port=$(echo "$hostport" | cut -d':' -f2)

    # Create a temporary proxychains config file for this proxy
    tmp_conf=$(mktemp)
    cat > "$tmp_conf" <<EOF
strict_chain
proxy_dns

[ProxyList]
$proto $host $port
EOF

    echo "Starting container $count with proxy $proxy_line"

    # Run container with mounted proxychains config and run a test command (curl)
    docker run --rm \
        -v "$tmp_conf":/etc/proxychains.conf:ro \
        --name "${CONTAINER_BASE_NAME}_${count}" \
        $IMAGE_NAME curl -s https://ifconfig.me

    rm "$tmp_conf"
    ((count++))
done < "$PROXIES_FILE"
