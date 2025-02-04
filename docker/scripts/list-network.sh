for n in `docker network ls | awk '!/NETWORK/ {print $1}'`; do docker network inspect $n; done | grep '\"Subnet\": \"172.16.' | sort
