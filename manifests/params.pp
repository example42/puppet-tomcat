# Class: tomcat::params
#
# This class defines default parameters used by the main module class tomcat
# Operating Systems differences in names and paths are addressed here
#
# == Variables
#
# Refer to tomcat class for the variables defined here.
#
# == Usage
#
# This class is not intended to be used directly.
# It may be imported or inherited by other classes
#
class tomcat::params {

  ### Application related parameters

  # Let's deal with versions madness
  $pkgver = $::operatingsystem ? {
    ubuntu                          => 'tomcat6',
    debian                          => $stdlib42::osver ? {
      5       => 'tomcat5.5',
      6       => 'tomcat6',
      default => 'tomcat6',
    },
    /(?i:CentOS|RedHat|Scientific)/ => $stdlib42::osver ? {
      5       => 'tomcat5',
      6       => 'tomcat6',
      default => 'tomcat6',
    },
    default                         => 'tomcat',
  }

  ### Application related parameters

  $package = $tomcat::params::pkgver

  $service = $tomcat::params::pkgver

  $service_status = $::operatingsystem ? {
    default => true,
  }

  $process = $::operatingsystem ? {
    default => 'java',
  }

  $process_args = $::operatingsystem ? {
    default => $tomcat::params::pkgver,
  }

  $process_user = $::operatingsystem ? {
    default => 'tomcat',
  }

  $config_dir = $::operatingsystem ? {
    default => "/etc/$tomcat::params::pkgver",
  }

  $config_file = $::operatingsystem ? {
    default => "/etc/$tomcat::params::pkgver/server.xml",
  }

  $config_file_mode = $::operatingsystem ? {
    default => '0644',
  }

  $config_file_owner = $::operatingsystem ? {
    default => 'root',
  }

  $config_file_group = $::operatingsystem ? {
    default => 'root',
  }

  $config_file_init = $::operatingsystem ? {
    /(?i:Debian|Ubuntu|Mint)/ => "/etc/default/$tomcat::params::pkgver",
    default                   => "/etc/sysconfig/$tomcat::params::pkgver",
  }

  $pid_file = $::operatingsystem ? {
    default => "/var/run/$tomcat::params::pkgver.pid",
  }

  $data_dir = $::operatingsystem ? {
    default => "/var/lib/$tomcat::params::pkgver/webapps",
  }

  $log_dir = $::operatingsystem ? {
    default => "/var/log/$tomcat::params::pkgver",
  }

  $log_file = $::operatingsystem ? {
    default => "/var/log/$tomcat::params::pkgver/catalina.out",
  }

  $port = '8080'
  $protocol = 'tcp'

  # General Settings
  $my_class = ''
  $source = ''
  $source_dir = ''
  $source_dir_purge = false
  $template = ''
  $options = ''
  $service_autorestart = true
  $absent = false
  $disable = false
  $disableboot = false

  ### General module variables that can have a site or per module default
  $monitor = false
  $monitor_tool = ''
  $monitor_target = $::ipaddress
  $firewall = false
  $firewall_tool = ''
  $firewall_src = '0.0.0.0/0'
  $firewall_dst = $::ipaddress
  $puppi = false
  $puppi_helper = 'standard'
  $debug = false
  $audit_only = false

}
