#! /bin/sh

set -x

if [ -z $script_root ]; then
  script_root=$(cd $(dirname $0)/../ && pwd)
fi

if [ -z $repo_root ]; then
  repo_root=https://raw.githubusercontent.com/mao172/gb-installer
  branch_nm=master
fi

postgresql_install() {
  local version=9.4
  version=$1

  if [ -f ${script_root}/lib/install_postgresql.sh ]; then
    cat ${script_root}/lib/install_postgresql.sh | bash -s -- -v ${version}
  else
    curl -L ${repo_root}/${branch_nm}/lib/install_postgresql.sh | bash -s -- -v ${version}
  fi

  export PATH=$PATH:/usr/pgsql-${version}/bin
}

create_db_user() {
  local db_user=$1
  local db_pswd=$2

  if ! which expect > /dev/null 2>&1; then
    yum install -y expect
  fi

  expect -c "
  spawn sudo -u postgres LANG=C createuser --createdb --encrypted --pwprompt ${db_user}
  expect \"Enter password for new role:\"
  send -- \"${db_pswd}\n\"
  expect \"Enter it again:\"
  send -- \"${db_pswd}\n\"
  expect \"]$ \"
  "
  
  sudo -u postgres LANG=C psql -c "grant ${db_user} to postgres;"
  
}

VERSION=9.4
DBUSR=admin
DBPSWD=password

while getopts v:u:p: OPT
do
  case $OPT in
    "v" )
      VERSION="$OPTARG"
      ;;
    "u" )
      DBUSR="$OPTARG"
      ;;
    "p" )
      DBPSWD="$OPTARG"
      ;;
  esac
done

if ! cat /etc/passwd | grep postgres; then
  postgresql_install $VERSION
fi

if ! which psql > /dev/null 2>&1; then
  postgresql_install $VERSION
fi

create_db_user $DBUSR $DBPSWD
