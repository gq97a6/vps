cp /etc/letsencrypt/live/hostunit.net/fullchain.pem /own/docker/storage/nginx/certs/hostunit.net/fullchain.pem
cp /etc/letsencrypt/live/hostunit.net/privkey.pem /own/docker/storage/nginx/certs/hostunit.net/privkey.pem

cp /etc/letsencrypt/live/alteratom.com/fullchain.pem /own/docker/storage/nginx/certs/alteratom.com/fullchain.pem
cp /etc/letsencrypt/live/alteratom.com/privkey.pem /own/docker/storage/nginx/certs/alteratom.com/privkey.pem

echo "Copied!"