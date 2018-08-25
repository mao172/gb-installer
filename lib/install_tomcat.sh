#! /bin/sh

set -x

tarball_base_uri=http://archive.apache.org/dist/tomcat

java_install() {

  yum install -y java-1.8.0-openjdk-devel
}

create_tomcat_user() {

  if ! cat /etc/passwd | grep tomcat; then
    useradd -s /sbin/nologin tomcat
  fi
}

tomcat_install() {

  local version=$1
  local file_name=apache-tomcat-${version}.tar.gz

  create_tomcat_user

  if ! which java > /dev/null 2>&1; then
    java_install
  fi

  cd ${opt_dir}

  if ! which wget > /dev/null 2>&1; then
    yum install -y wget
  fi
  
  if [ -f ${file_name} ]; then
    if [ -f ${file_name}.sha512 ]; then
      rm ${file_name}.sha512
    fi
    
    wget -P ${opt_dir} ${tarball_base_uri}/tomcat-${version%%.*}/v${version}/bin/${file_name}.sha512
    
    sha512sum -c ${file_name}.sha512
    if ! [ $? -eq 0 ]; then
      rm ${file_name}
    fi
  fi

  if ! [ -f ${file_name} ]; then
    #curl -OL ${tarball_base_uri}/tomcat-${version%.*}/v${version}/bin/${file_name}
    wget -P ${opt_dir} ${tarball_base_uri}/tomcat-${version%%.*}/v${version}/bin/${file_name}
  fi
  
  tar -xzvf ./${file_name}
  chown -R tomcat:tomcat ./apache-tomcat-${version}

  if [ -h tomcat ]; then
    ln -nfs ${opt_dir}/apache-tomcat-${version} ${opt_dir}/tomcat
  else
    if [ -d tomcat ]; then
      mv ./tomcat ./tomcat.old
    fi
    
    ln -s ${opt_dir}/apache-tomcat-${version} ${opt_dir}/tomcat
  fi
}

tomcat_setup() {

  local version=$1

  tomcat_install ${version}
  
  if ! [ -e /etc/sysconfig/tomcat ]; then
    
    cat << '_EOF_' > /etc/sysconfig/tomcat
# Where your java installation lives
#JAVA_HOME="/usr/lib/jvm/java"

# You can pass some parameters to java here if you wish to
#JAVA_OPTS="-Xminf0.1 -Xmaxf0.3"

# Use JAVA_OPTS to set java.library.path for libtcnative.so
#JAVA_OPTS="-Djava.library.path=/usr/lib"
JAVA_OPTS="-Djava.security.egd=file:/dev/./urandom"

_EOF_

  fi
  
  if ! [ -e /etc/systemd/system/tomcat.service ]; then

    cat << '_EOF_' > /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat 8
After=syslog.target network.target

[Service]
User=tomcat
Type=simple
PIDFile=/opt/tomcat/tomcat.pid
RemainAfterExit=yes

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh
EnvironmentFile=/etc/sysconfig/tomcat

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

if systemctl list-units --type=service | grep tomcat; then
  systemctl stop tomcat
  systemctl disable tomcat
fi

tomcat_setup $VERSION

cd /opt/tomcat/lib
curl -OL https://jdbc.postgresql.org/download/postgresql-42.2.4.jar

systemctl enable tomcat
systemctl start tomcat

