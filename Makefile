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
	cat /tmp/access.log| alp json -m "/api/player/player/[0-9a-z]*,/api/player/competition/[0-9a-z]*/,/api/organizer/competition/[0-9a-z]*/score,/api/organizer/competition/[0-9a-z]*/finish,/api/organizer/player/[0-9a-z]*/disqualified" --sort=sum -r
