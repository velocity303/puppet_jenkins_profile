class profile::jenkins (
  $jenkins_version = 'latest',
  $tomcat_major_version = '8',
  $catalina_base = '/opt/apache-tomcat',
  $catalina_home = '/opt/apache-tomcat',
) {
  class { 'java':
    distribution => 'jre'
  }
  case $tomcat_major_version {
    '6': { $tomcat_version = '6.0.41' }
    '7': { $tomcat_version = '7.0.56' }
    '8': { $tomcat_version = '8.0.14' }
  }
  class { 'tomcat':}
  firewall { '100 allow tomcat access':
    port   => [8080],
    proto  => tcp,
    action => accept,
  }
  tomcat::instance{ 'default':
    install_from_source => true,
    source_url          => "http://www.us.apache.org/dist/tomcat/tomcat-${tomcat_major_version}/v${tomcat_version}/bin/apache-tomcat-${tomcat_version}.tar.gz",
    catalina_base       => $catalina_base,
    catalina_home       => $catalina_home,
  }->
  tomcat::setenv::entry { 'JENKINS_HOME':
    value               => "\"-DJENKINS_HOME=${catalina_base}/webapps/jenkins\"",
    param               => 'CATALINA_OPTS',
  }->
  tomcat::war { 'jenkins.war' :
    war_source    => "http://mirrors.jenkins-ci.org/war/${jenkins_version}/jenkins.war",
    catalina_base => $catalina_base,
  }->
  tomcat::service { 'jenkins':
    catalina_base => $catalina_base,
    catalina_home => $catalina_home,
  }
}
