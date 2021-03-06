#! /bin/sh

set -x

script_root=$(cd $(dirname $0) && pwd)

repo_root=https://raw.githubusercontent.com/mao172/gb-installer
branch_nm=master

set_locale() {

  local def_lang=$1
  
  if [ -f ${script_root}/lib/set_locale.sh ]; then
    cat ${script_root}/lib/set_locale.sh | bash -s -- -l ${def_lang}
  else
    curl -L ${repo_root}/${branch_nm}/lib/set_locale.sh | bash -s -- -l ${def_lang}
  fi

}

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
tomcat_version=8.5.33

db_url="jdbc:postgresql://localhost/gitbucket"
db_user="gitbucket"
db_pswd="password"

while getopts b:p:t: OPT
do
  case $OPT in
    "b" )
      branch_nm="$OPTARG"
      ;;
    "p" )
      pg_version="$OPTARG"
      ;;
    "t" )
      tomcat_version="$OPTARG"
      ;;
  esac
done

export script_root
export repo_root
export branch_nm

set_locale ja_JP.UTF-8

timedatectl set-timezone Asia/Tokyo

db_setup $pg_version $db_user $db_pswd

tomcat_install ${tomcat_version}

gitbucket_install 4.27.0 $db_url $db_user $db_pswd ja_JP.UTF-8

httpd_setup

