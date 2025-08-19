cd /own/docker/storage

cp /etc/letsencrypt/live/hostunit.net/fullchain.pem   nginx/certs/hostunit.net/
cp /etc/letsencrypt/live/hostunit.net/privkey.pem     nginx/certs/hostunit.net/
cp /etc/letsencrypt/live/alteratom.com/fullchain.pem  nginx/certs/alteratom.com/
cp /etc/letsencrypt/live/alteratom.com/privkey.pem    nginx/certs/alteratom.com/

echo "Copied!"
