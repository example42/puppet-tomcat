# Define: tomcat::users
# NOTE: Work in progress. Has only been tested under Ubuntu 12.04
#
# Tomcat user instance
#
# == Parameters
#
# Standard class parameters
# Define the general class behaviour and customizations
#
# [*filemode*]
#
#
#
# Usage:
# With standard template:
# tomcat::users  { 'users':
#	source => 'puppet:///files/tomcat/users.xml'
# }
#
# Notes
# =====
#
# AJP proxy port - Used in server.xml-default template
# Note: YOU MUST explicitly define a template name in $serverxmltemplate to use one
# By default the script that creates an instance doesn't set the ajp port
#
define tomcat::users (
  $filemode               = '0640',
  $source		  ='',
  ) {

  require tomcat::params

  $tomcat_version = $tomcat::params::version


  file { "tomcat_users":
    ensure  => file,
    path    => "${tomcat::params::config_dir}/tomcat-users.xml",
    mode    => $filemode,
    source  => $source,
    owner   => $tomcat::params::config_file_owner,
    group   => $tomcat::params::config_file_group,
    require => Class['tomcat'],
  }

}
