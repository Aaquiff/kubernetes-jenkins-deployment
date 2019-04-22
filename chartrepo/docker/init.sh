mkdir index && helm fetch stable/mysql -d index/
helm repo index index/ --url https://helm.example.repo.com/charts
mkdir index/charts && mv index/mysql-*.tgz index/charts/
rm /etc/apache2/sites-available/*
rm /etc/apache2/sites-enabled/000-default.conf
echo "127.0.0.1       helm.example.repo.com" >> /etc/hosts
a2enmod ssl
htpasswd -c -b /etc/apache2/.htpasswd admin admin
cp /helm.conf /etc/apache2/sites-available/helm.conf
a2ensite helm.conf
mv index /var/www/
/etc/init.d/apache2 start
# helm repo add private-repo https://helm.example.repo.com --username admin --password admin --ca-file /etc/apache2/ssl/server.crt
# helm search mysql | grep mysql
# helm fetch private-repo/mysql

git clone https://github.com/Aaquiff/kubernetes-ei-cd
helm package kubernetes-ei-cd/scalable-integrator

inotifywait -m /var/www/index/charts -e create -e moved_to |
    while read path action file; do
        echo "The file '$file' appeared in directory '$path' via '$action'" >> /webhook.log
        message=`base64 $path/$file`
        curl -X POST --header "Content-Type: application/json" --request POST --data '{"artifacts": [ {"type": "embedded/base64","name": "scalable-integrator-6.3.0-2.tgz","reference": "$message" }]}"' http://35.226.115.157:8084/webhooks/webhook/chart
        # do something with the file
    done

while [ 1 ]
do
    sleep 600
done