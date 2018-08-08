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

  #https://github.com/gitbucket/gitbucket/releases/download/4.27.0/gitbucket.war
  wget -P /opt/tomcat/webapps/ https://github.com/gitbucket/gitbucket/releases/download/${version}/gitbucket.war

  systemctl start tomcat
}

gitbucket_setup() {

  local db_user=gitbucket
  local db_pswd=gitbucket

}


VERSION=4.27.0

gitbucket_install $VERSION
gitbucket_setup 
