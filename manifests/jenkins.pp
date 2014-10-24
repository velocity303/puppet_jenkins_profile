class profile::jenkins (
    $version = 'latest',
    $catalina_base = '/usr/share/tomcat',
    $catalina_home = '/usr/share/tomcat',
    $tomcat_package = 'tomcat6',
    $tomcat_service = 'tomcat6',
    ) {
  class { 'java':
    distribution => 'jre'
  }
  class { 'tomcat':}
  tomcat::instance{ 'default':
    install_from_source => true,
    source_url => "http://mirror.symnds.com/software/Apache/tomcat/tomcat-7/v7.0.56/bin/apache-tomcat-7.0.56.tar.gz",
  }->
  tomcat::setenv::entry { 'JENKINS_HOME':
    value       => "\"-DJENKINS_HOME=/opt/jenkins\"",
    param       => 'CATALINA_OPTS',
  }->
  tomcat::war { 'jenkins.war' :
    war_source    => "http://mirrors.jenkins-ci.org/war/${version}/jenkins.war",
  }->
  tomcat::service { 'jenkins': }
}
