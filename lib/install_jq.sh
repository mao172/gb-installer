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

package list jq | grep -i jq
if ! [ $? -eq 0 ]; then
  package list epel-release | grep -i epel-release
  if [ $? -eq 0 ]; then
    package install -y epel-release
  else
    package install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
  fi
fi

package list jq | grep -i jq
if [ $? -eq 0 ]; then
  package install -y jq
else
  curl -o /usr/bin/jq -L https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 && sudo chmod +x /usr/bin/jq
fi

jq --version