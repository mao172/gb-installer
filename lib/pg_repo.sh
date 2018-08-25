#! /bin/sh

repo() {
  local version=$1

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

repodata=$(curl -s -L https://www.postgresql.org/download/js/yum.js | grep "var repodata" | sed -e "s/^var repodata = \(.*\);$/\1/")

platform_v=${platform,,}-${platform_version%%.*}

pinfo=$(echo ${repodata} | jq -c '.["platforms"]["'${platform_v}'"]')
pinfo_p=$(echo ${pinfo} | jq -r '.["p"]')
pinfo_f=$(echo ${pinfo} | jq -r '.["f"]')
arch_n=$(echo ${repodata} | jq -r '.["reporpms"]["'${version}'"]["'${platform_v}'"]["'${hw_platform}'"]')

#ver + '/' + pinfo['p'] + '-' + arch + '/pgdg-' + pinfo['f'] + shortver + '-' + ver + '-' + repodata['reporpms'][ver][plat][arch] + '.noarch.rpm'
echo 'http://yum.postgresql.org/'${version}'/'${pinfo_p}'-'${hw_platform}'/pgdg-'${pinfo_f}${version/./}'-'${version}'-'${arch_n}'.noarch.rpm'

}

VERSION=9.4

while getopts v: OPT
do
  case $OPT in
    "v" ) VERSION="$OPTARG";;
  esac
done

repo ${VERSION}
