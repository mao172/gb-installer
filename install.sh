#! /bin/sh

set -x

script_root=$(cd $(dirname $0) && pwd)

db_setup() {
  local db_user=dbadmin
  local db_pswd=dbpswd

  db_user=$1
  db_pswd=$2

  cat ${script_root}/lib/setup_db.sh | bash -s -- -u ${db_user} -p ${db_pswd}
}

tomcat_install() {
  cat ${script_root}/lib/install_tomcat.sh | bash -s --
}

db_user="gitbucket"
db_pswd="password"

db_setup $db_user $db_pswd

tomcat_install

gitbucket_install 4.27.0

httpd_setup
