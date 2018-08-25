#! /bin/sh

set -x

hw_platform=$(uname -i)

if [ -f /etc/redhat-release ]; then
  platform_family="rhel"
  platform=$(cat /etc/redhat-release | awk '{print $1}')
  platform_version=$(cat /etc/redhat-release | awk '{print $3}')
  if [ "${platform_version}" = "release" ]; then
    platform_version=$(cat /etc/redhat-release | awk '{print $4}')
  fi
fi

os_name=${platform,,}

ge() {
  ret=$(echo $1 $2 | awk '{printf ("%d", $1>=$2)}')
  test ${ret} -eq 1
  return $?
}

package() {
  if which yum > /dev/null 2>&1; then
    pkm_cmd=yum
  fi
  
  if which dnf > /dev/null 2>&1; then
    pkm_cmd=dnf
  fi
  
  ${pkm_cmd} $@
}

set_locale() {
  local def_lang=$1
  local lang_tag=$(echo ${def_lang} | sed -e 's/^\(.*\)\..*/\1/')
  local primary_tag=$(echo ${lang_tag} | sed -e 's/^\(.*\)_.*/\1/')
  
  localectl list-locales | grep -i ${lang_tag}
  if ! [ $? -eq 0 ]; then
    lang_pack=$(package list glibc-lang\* | grep -i ${primary_tag} | awk '{print $1}')
    if [ -n "${lang_pack}" ]; then
      package install -y ${lang_pack}
    else
      package reinstall -y glibc-common
    fi
  fi

  localectl set-locale LANG=${def_lang}
  source /etc/locale.conf
}

DEF_LANG=ja_JP.UTF-8

while getopts l: OPT
do
  case $OPT in
    "l" )
      DEF_LANG="$OPTARG"
      ;;
  esac
done


set_locale ${DEF_LANG}
