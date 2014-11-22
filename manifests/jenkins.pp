class profile::jenkins (
  $jenkins_version = 'latest',
  $tomcat_major_version = '7',
  $catalina_base = "/opt/apache-tomcat",
  $catalina_home = "${catalina_base}",
) {
 class { 'java':
    distribution => 'jre'
  }
  case $tomcat_major_version {
    '6': { $tomcat_version = '6.0.41' }
    '7': { $tomcat_version = '7.0.57' }
    '8': { $tomcat_version = '8.0.15' }
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
    source_strip_first_dir => false,
    catalina_base       => "${catalina_base}",
    catalina_home       => "${catalina_home}",
    notify              => Tomcat::Setenv::Entry [ 'JENKINS_HOME' ],
    before              => Tomcat::Setenv::Entry [ 'JENKINS_HOME' ],
  }
  tomcat::setenv::entry { 'JENKINS_HOME':
    value               => "\"-DJENKINS_HOME=${catalina_base}/webapps/jenkins\"",
    param               => 'CATALINA_OPTS',
    before              => Tomcat::War [ "jenkins-${jenkins_version}.war" ],
    notify              => Tomcat::War [ "jenkins-${jenkins_version}.war" ],
  }
  tomcat::war { "jenkins-${jenkins_version}.war" :
    war_source    => "http://mirrors.jenkins-ci.org/war/${jenkins_version}/jenkins.war",
    notify        => File [ "${catalina_base}/webapps/jenkins" ],
  }
  file { "${catalina_base}/webapps/jenkins":
    ensure => 'link',
    target => "${catalina_base}/webapps/jenkins-${jenkins_version}",
    before              => Tomcat::War [ "jenkins.war" ],
  }
  tomcat::war { "jenkins.war" :
    war_source    => "http://mirrors.jenkins-ci.org/war/${jenkins_version}/jenkins.war",
    catalina_base => "${catalina_base}",
    war_name      => "jenkins.war",
    notify        => Tomcat::Service [ "jenkins" ],
    subscribe     => Tomcat::Instance  [ 'default' ],
  }
  tomcat::service { "jenkins":
    catalina_base => "${catalina_base}",
    catalina_home => "${catalina_home}",
    service_name  => "jenkins",
    subscribe     => File [ "${catalina_base}/webapps/jenkins" ],
  }
}
