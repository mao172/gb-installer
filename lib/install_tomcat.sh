#! /bin/sh

set -x

java_install() {

  yum install -y java-1.8.0-openjdk-devel
}

create_tomcat_user() {
  useradd -s /sbin/nologin tomcat
}

tomcat_install() {

  local version=8.5.32
  version=$1

  create_tomcat_user

  java_install

  cd ${opt_dir}

  #http://ftp.yz.yamagata-u.ac.jp/pub/network/apache/tomcat/tomcat-8/v8.5.32/bin/apache-tomcat-8.5.32.tar.gz
  curl -OL http://ftp.yz.yamagata-u.ac.jp/pub/network/apache/tomcat/tomcat-8/v${version}/bin/apache-tomcat-${version}.tar.gz

  tar -xzvf ./apache-tomcat-${version}.tar.gz
  chown -R tomcat:tomcat ./apache-tomcat-${version}

  ln -s ${opt_dir}/apache-tomcat-${version} ${opt_dir}/tomcat
}

tomcat_setup() {

  tomcat_install 8.5.32
  
  if ! [ -e /etc/systemd/system/tomcat.service ]; then

    cat << '_EOF_' > /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat 8
After=syslog.target network.target

[Service]
User=tomcat
Group=tomcat
Type=oneshot
PIDFile=/opt/tomcat/tomcat.pid
RemainAfterExit=yes

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh
ExecReStart=/opt/tomcat/bin/shutdown.sh;/opt/tomcat/bin/startup.sh

[Install]
WantedBy=multi-user.target
_EOF_

  fi

  chmod 755 /etc/systemd/system/tomcat.service

} 


VERSION=8.5.32

opt_dir=/opt

while getopts v: OPT
do
  case $OPT in
    "v" )
      VERSION="$OPTARG"
      ;;
  esac
done

tomcat_setup $VERSION

systemctl start tomcat

