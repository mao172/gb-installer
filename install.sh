#! /bin/sh

set -x

script_root=$(cd $(dirname $0) && pwd)

db_setup() {
  local version=10
  local db_user=dbadmin
  local db_pswd=dbpswd

  version=$1
  db_user=$2
  db_pswd=$3
  
  cat ${script_root}/lib/setup_db.sh | bash -s -- -v ${version} -u ${db_user} -p ${db_pswd}
}

tomcat_install() {

  local version=$1

  cat ${script_root}/lib/install_tomcat.sh | bash -s -- -v ${version}
}

gitbucket_install() {

  local version=$1
  local db_url=$2
  local db_user=$3
  local db_pswd=$4

  cat ${script_root}/lib/setup_gitbucket.sh | bash -s -- -v ${version} -d ${db_url} -u ${db_user} -p ${db_pswd}
}

httpd_setup () {

  cat ${script_root}/lib/setup_httpd.sh | bash -s --
}

pg_version=10
db_url="jdbc:postgresql://localhost/gitbucket"
db_user="gitbucket"
db_pswd="password"

export script_root

db_setup $pg_version $db_user $db_pswd

tomcat_install 8.5.32

gitbucket_install 4.27.0 $db_url $db_user $db_pswd

#httpd_setup
