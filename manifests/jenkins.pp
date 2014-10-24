class profile::jenkins ( 
$version = 'latest',
$catalina_base = '/var/lib/tomcat7',
$catalina_home = '/usr/share/tomcat7',
$tomcat_package = 'tomcat7',
$tomcat_service = 'tomcat7',
) {
  class { 'tomcat':
    catalina_home => $catalina_home,
  }
  tomcat::instance{ 'jenkins':
    package_ensure      => present,
    install_from_source => false,
    package_name        => $tomcat_package,
    catalina_base       => $catalina_base,
    catalina_home       => $catalina_home,
  }->
  tomcat::setenv::entry { 'JENKINS_HOME':
    value  => "\"-DJENKINS_HOME=${catalina_base}/webapps/jenkins\"",
    param  => 'CATALINA_OPTS'
  }->
  tomcat::war { 'jenkins.war' :
    catalina_base => $catalina_base,
    war_source    => "http://mirrors.jenkins-ci.org/war/${version}/jenkins.war"
    notify        => Service [ $tomcat_service ],
  }
  tomcat::service { 'jenkins': 
    use_jsvc     => false,
    use_init     => true,
    service_name => $tomcat_service,
  }
}
