all: app

ADDR := 52.69.211.251

app:
	cd webapp/go; GOOS=linux GOARCH=amd64 go build -o isupipe

deploy-app: app nginx-log-rotate
	ssh isucon@$(ADDR) rm /home/isucon/webapp/go/isupipe
	scp -r webapp/go isucon@$(ADDR):/home/isucon/webapp/
	ssh isucon@$(ADDR) sudo systemctl restart isupipe-go.service

deploy-mysql-only: mysql-log-rotate
	scp -r etc/mysql isucon@$(ADDR):/tmp
	ssh isucon@$(ADDR) 'sudo cp -rT /tmp/mysql /etc/mysql ; sudo systemctl restart mysql'

mysql-log-rotate:
	ssh isucon@$(ADDR) "sudo rm /var/log/mysql/mysql-slow.log ; sudo systemctl restart mysql"

get-mysql-log:
	ssh isucon@$(ADDR) 'sudo chmod 644 /var/log/mysql/mysql-slow.log'
	scp isucon@$(ADDR):/var/log/mysql/mysql-slow.log /tmp

pt-query-digest:
	pt-query-digest /tmp/mysql-slow.log | tee /tmp/digest_$(date +%Y%m%d-%H%M%S).txt

deploy-nginx-only: nginx-log-rotate
	scp -r etc/nginx isucon@$(ADDR):/tmp
	ssh isucon@$(ADDR) 'sudo cp -rT /tmp/nginx /etc/nginx ; sudo systemctl restart nginx'

nginx-log-rotate:
	ssh isucon@$(ADDR) "sudo mv /var/log/nginx/access.log /var/log/nginx/access.log.`date +%Y%m%d-%H%M%S` ; sudo systemctl restart nginx"

get-nginx-log:
	scp isucon@$(ADDR):/var/log/nginx/access.log /tmp

alp:
	cat /tmp/access.log| alp json -m "/api/user/[0-9a-zA-Z]*/statistics,/api/livestream/[0-9a-zA-Z]*/livecomment,/api/livestream/[0-9a-zA-Z]*/reaction,/api/livestream/[0-9a-zA-Z]*/moderate,/api/livestream/[0-9a-zA-Z]*/statistics,/api/livestream/[0-9a-zA-Z]*/report,/api/livestream/[0-9a-zA-Z]*/enter,/api/livestream/[0-9a-zA-Z]*/ngwords,/api/livestream/[0-9a-zA-Z]*/exit,/api/user/[0-9a-zA-Z]*/icon,/api/user/[0-9a-zA-Z]*/theme,/api/livestream/[0-9a-zA-Z]*/livecomment/[0-9a-zA-Z]*/report" --sort=sum -r
