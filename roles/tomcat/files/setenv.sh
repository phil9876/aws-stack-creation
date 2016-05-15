TOMCAT_USER=tomcat
NOW=$(date +"%Y%m%d%H%M%S")

CATALINA_HOME=/var/tomcat
CATALINA_BASE=/var/tomcat
#export JAVA_HOME=/usr/java/jdk1.7.0_51
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.91-0.b14.el7_2.x86_64/jre

CATALINA_TMPDIR=/var/tomcat/temp
JAVA_OPTS="${JAVA_OPTS} -Djavax.net.ssl.keyStore=${CATALINA_BASE}/conf/localdevTomcatIdentityKeystore.jks"
JAVA_OPTS="${JAVA_OPTS} -Djavax.net.ssl.keyStorePassword=123456"
#JAVA_OPTS="${JAVA_OPTS} -Djavax.net.ssl.trustStore=${CATALINA_BASE}/conf/CapitalOneTrustKeystore.jks"
#JAVA_OPTS="${JAVA_OPTS} -Djavax.net.ssl.trustStorePassword=123456"


if [[ "start" == $1 ]]
then
  #JAVA_OPTS="${JAVA_OPTS} -Dfile.encoding=UTF-8"
  #JAVA_OPTS="${JAVA_OPTS} -Xms2g"
  #JAVA_OPTS="${JAVA_OPTS} -Xmx2g"
  #JAVA_OPTS="${JAVA_OPTS} -XX:PermSize=1g"
  #JAVA_OPTS="${JAVA_OPTS} -XX:MaxPermSize=1g"
  #JAVA_OPTS="${JAVA_OPTS} -XX:+CMSClassUnloadingEnabled"
  #JAVA_OPTS="${JAVA_OPTS} -XX:+UseConcMarkSweepGC"


  mkdir -p ${CATALINA_BASE}/logs/old
  pushd ${CATALINA_BASE}/logs
  touch backup.${NOW}
  FILES=$(file * | grep -e empty -e ASCII | cut -d: -f1 )
  tar cf old/${NOW}.tar ${FILES}
  rm -f ${FILES}
  find old -type f -mtime +30 -exec rm -f {} \;
  popd
fi
