#! /bin/sh

set -x

script_root=$(cd $(dirname $0) && pwd)

repo_root=https://raw.githubusercontent.com/mao172/gb-installer
branch_nm=master

db_setup() {
  local version=10
  local db_user=dbadmin
  local db_pswd=dbpswd

  version=$1
  db_user=$2
  db_pswd=$3
  
  if [ -f ${script_root}/lib/setup_db.sh ]; then
    cat ${script_root}/lib/setup_db.sh | bash -s -- -v ${version} -u ${db_user} -p ${db_pswd}
  else
    curl -L ${repo_root}/${branch_nm}/lib/setup_db.sh | bash -s -- -v ${version} -u ${db_user} -p ${db_pswd}
  fi
  
}

tomcat_install() {

  local version=$1

  if [ -f ${script_root}/lib/install_tomcat.sh ]; then
    cat ${script_root}/lib/install_tomcat.sh | bash -s -- -v ${version}
  else
    curl -L ${repo_root}/${branch_nm}/lib/install_tomcat.sh | bash -s -- -v ${version}
  fi
}

gitbucket_install() {

  local version=$1
  local db_url=$2
  local db_user=$3
  local db_pswd=$4

  if [ -f ${script_root}/lib/setup_gitbucket.sh ]; then
    cat ${script_root}/lib/setup_gitbucket.sh | bash -s -- -v ${version} -d ${db_url} -u ${db_user} -p ${db_pswd}
  else
    curl -L ${repo_root}/${branch_nm}/lib/setup_gitbucket.sh | bash -s -- -v ${version} -d ${db_url} -u ${db_user} -p ${db_pswd}
  fi
}

httpd_setup () {

  if [ -f ${script_root}/lib/setup_httpd.sh ]; then
    cat ${script_root}/lib/setup_httpd.sh | bash -s --
  else
    curl -L ${repo_root}/${branch_nm}/lib/setup_httpd.sh | bash -s --
  fi
}

pg_version=10
db_url="jdbc:postgresql://localhost/gitbucket"
db_user="gitbucket"
db_pswd="password"

export script_root

db_setup $pg_version $db_user $db_pswd

tomcat_install 8.5.32

gitbucket_install 4.27.0 $db_url $db_user $db_pswd

httpd_setup

