#! /bin/sh

set -x

if [ -z $script_root ]; then
  script_root=$(cd $(dirname $0)/../ && pwd)
fi

if [ -z $repo_root ]; then
  repo_root=https://raw.githubusercontent.com/mao172/gb-installer
  branch_nm=master
fi

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

download() {
  if which wget > /dev/null 2>&1; then
    cmd="wget -q $1"
  else
    cmd="curl -sS -OL $1"
  fi
  
  ${cmd}
}

VERSION=$1

gb_repo() {
  cat ${script_root}/lib//repodata.json | \
  jq -r '.["gitbucket"]| .["r"] as $repo | .["releases"] | map(select(.f != null)) | map(select(contains({"v":"'${VERSION}'"}))) | max_by(.v) | {v,f,r:$repo}' | \
  jq -r 'select(.f != null) | [.["r"], "releases/download", .["v"], .["f"]] | join("/")'
}

gb_plugins() {
  cat ${script_root}/lib//repodata.json | \
  jq  '.["plugins"][] | .["r"] as $repo |  .["releases"][] | {v, t, f, r: $repo} | [select(contains({"t":["'${VERSION}'"]}) or contains({"t":"'${VERSION}'"}))]' | \
  jq -s add | \
  jq -r 'group_by(.r) | .[] | max_by(.v) | select(.f != null) | [.["r"], "releases/download", .["v"], .["f"]] | join("/")'
}

download $(gb_repo)

mkdir -p /opt/gitbucket
chown tomcat:tomcat /opt/gitbucket

mkdir -p /opt/gitbucket/plugins
chown tomcat:tomcat /opt/gitbucket/plugins
cd /opt/gitbucket/plugins

for repo in $(gb_plugins)
do
  download $repo
done

#https://plugins.gitbucket-community.org/releases/gitbucket-pages-plugin/gitbucket-pages-plugin-gitbucket_4.26.0-1.7.1.jar
