FROM ubuntu:latest
USER root

RUN apt-get update && apt-get install curl -y

#Install HELM
RUN curl https://raw.githubusercontent.com/helm/helm/master/scripts/get > get_helm.sh
RUN chmod 700 get_helm.sh
RUN ./get_helm.sh
RUN helm init --client-only

#Install Apache web server
RUN apt-get update && apt-get install apache2 apache2-utils -y

RUN apt-get install git -y

COPY helm.conf /helm.conf
COPY server.crt /etc/apache2/ssl/server.crt
COPY server.key /etc/apache2/ssl/server.key

RUN apt-get install inotify-tools -y

COPY init.sh /init.sh
RUN chmod 777 /init.sh
ENTRYPOINT [ "sh", "-c", "/init.sh" ]