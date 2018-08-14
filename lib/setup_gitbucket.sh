#! /bin/sh

set -x

gitbucket_install() {
  local version=4.27.0
  version=$1

  systemctl stop tomcat

  cd /opt

  if ! which wget > /dev/null 2>&1; then
    yum install -y wget
  fi
  
  if [ -d /opt/tomcat ]; then
    cd /opt/tomcat/webapps
  fi
  
  if [ -d /usr/share/tomcat ]; then
    cd /usr/share/tomcat/webapps
  fi

  #https://github.com/gitbucket/gitbucket/releases/download/4.27.0/gitbucket.war
  #wget -P /opt/tomcat/webapps/ https://github.com/gitbucket/gitbucket/releases/download/${version}/gitbucket.war
  curl -OL https://github.com/gitbucket/gitbucket/releases/download/${version}/gitbucket.war
  
  if ! [ -d /opt/gitbucket ]; then
    mkdir /opt/gitbucket
  fi
  
  chown tomcat:tomcat /opt/gitbucket
  
  cat << '_EOF_' >> /etc/sysconfig/tomcat

GITBUCKET_HOME=/opt/gitbucket
_EOF_

#  systemctl start tomcat
}

gitbucket_setup() {

  local db_url=$1
  local db_user=$2
  local db_pswd=$3
  
#  expect -c "
#  spawn sudo -u postgres LANG=C psql -U ${db_user} -W -c \\"create database gitbucket WITH template template0 encoding 'utf8' lc_collate 'ja_JP.UTF-8' lc_ctype 'ja_JP.UTF-8';\\"
#  expect \"Password for user password:\"
#  send -- \"${db_pswd}\"
#  expect \"]$ \"
#  "

  sudo -u postgres psql -c "create database gitbucket WITH template template0 encoding 'utf8' lc_collate 'ja_JP.UTF-8' lc_ctype 'ja_JP.UTF-8';"

  touch /opt/gitbucket/database.conf
  echo "db {" >> /opt/gitbucket/database.conf
  echo "  url = \"$db_url\"" >> /opt/gitbucket/database.conf
  echo "  user = \"$db_user\"" >> /opt/gitbucket/database.conf
  echo "  password = \"$db_pswd\"" >> /opt/gitbucket/database.conf
  echo "}" >> /opt/gitbucket/database.conf

  chown tomcat:tomcat /opt/gitbucket/database.conf
}

gitbucket_plugins() {

  mkdir /opt/gitbucket/plugins
  chown tomcat:tomcat /opt/gitbucket/plugins
  
  cd /opt/gitbucket/plugins
  curl -OL https://github.com/gitbucket/gitbucket-gist-plugin/releases/download/4.15.0/gitbucket-gist-plugin-gitbucket_4.25.0-4.15.0.jar
  
  curl -OL https://github.com/yoshiyoshifujii/gitbucket-commitgraphs-plugin/releases/download/4.23.1/gitbucket-commitgraphs-plugin_2.12-4.23.1.jar
  
  curl -OL https://github.com/gitbucket/gitbucket-pages-plugin/releases/download/1.7.1/gitbucket-pages-plugin_2.12-1.7.1.jar
  
  curl -OL https://github.com/mrkm4ntr/gitbucket-network-plugin/releases/download/1.6.1/gitbucket-network-plugin_2.12-1.6.1.jar
  
  curl -OL https://github.com/YoshinoriN/gitbucket-monitoring-plugin/releases/download/v3.1.0/gitbucket-monitorting-plugin_2.12-3.1.0.jar
  
  curl -OL https://github.com/takezoe/gitbucket-ci-plugin/releases/download/1.6.0/gitbucket-ci-plugin-assembly-1.6.0.jar
  
  curl -OL https://github.com/takezoe/gitbucket-maven-repository-plugin/releases/download/1.3.1/gitbucket-maven-repository-plugin-assembly-1.3.1.jar
  
}


VERSION=4.27.0
DBURL='jdbc:h2:${DatabaseHome};MVCC=true'
DBUSER=sa
DBPSWD=sa

while getopts v:d:u:p: OPT
do
  case $OPT in
    "v" )
      VERSION="$OPTARG"
      ;;
    "d" )
      DBURL="$OPTARG"
      ;;
    "u" )
      DBUSER="$OPTARG"
      ;;
    "p" )
      DBPSWD="$OPTARG"
      ;;
  esac
done

gitbucket_install $VERSION
gitbucket_setup $DBURL $DBUSER $DBPSWD
gitbucket_plugins

systemctl start tomcat

