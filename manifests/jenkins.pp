class profile::jenkins (
  $version = 'latest',
  $catalina_base = '/opt/apache-tomcat',
  $catalina_home = '/opt/apache-tomcat',
) {
  class { 'java':
    distribution => 'jre'
  }
  class { 'tomcat':}
  firewall { '100 allow tomcat access':
    port   => [8080],
    proto  => tcp,
    action => accept,
  }
  tomcat::instance{ 'default':
    install_from_source => true,
    source_url          => "http://mirror.symnds.com/software/Apache/tomcat/tomcat-7/v7.0.56/bin/apache-tomcat-7.0.56.tar.gz",
    catalina_base       => $catalina_base,
    catalina_home => $catalina_home,
  }->
  tomcat::setenv::entry { 'JENKINS_HOME':
    value               => "\"-DJENKINS_HOME=${catalina_base}/webapps/jenkins\"",
    param               => 'CATALINA_OPTS',
  }->
  tomcat::war { 'jenkins.war' :
    war_source    => "http://mirrors.jenkins-ci.org/war/${version}/jenkins.war",
    catalina_base => $catalina_base,
  }->
  tomcat::service { 'jenkins':
    catalina_base => $catalina_base,
    catalina_home => $catalina_home,
  }
}
