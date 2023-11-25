all: app

app:
	cd webapp/go; GOOS=linux GOARCH=amd64 go build


deploy-app: app nginx-log-rotate
	scp -r webapp/go isucon@52.69.211.251:/home/isucon/webapp/
	scp webapp/docker-compose-go.yml isucon@52.69.211.251:/home/isucon/webapp/
	ssh isucon@52.69.211.251 sudo systemctl restart isupipe-go.service

deploy-nginx-only: nginx-log-rotate
	scp -r etc/nginx isucon@52.69.211.251:/tmp
	ssh isucon@52.69.211.251 'sudo cp -rT /tmp/nginx /etc/nginx ; sudo systemctl restart nginx'

nginx-log-rotate:
	ssh isucon@52.69.211.251 "sudo mv /var/log/nginx/access.log /var/log/nginx/access.log.`date +%Y%m%d-%H%M%S` ; sudo systemctl restart nginx"

get-nginx-log:
	scp isucon@52.69.211.251:/var/log/nginx/access.log /tmp

alp:
	cat /tmp/access.log| alp json -m "/api/user/[0-9a-zA-Z]*/statistics,/api/livestream/[0-9a-zA-Z]*/livecomment,/api/livestream/[0-9a-zA-Z]*/reaction,/api/livestream/[0-9a-zA-Z]*/moderate,/api/livestream/[0-9a-zA-Z]*/statistics,/api/livestream/[0-9a-zA-Z]*/report,/api/livestream/[0-9a-zA-Z]*/enter,/api/livestream/[0-9a-zA-Z]*/ngwords,/api/livestream/[0-9a-zA-Z]*/exit,/api/user/[0-9a-zA-Z]*/icon,/api/user/[0-9a-zA-Z]*/theme,/api/livestream/[0-9a-zA-Z]*/livecomment/[0-9a-zA-Z]*/report" --sort=sum -r
