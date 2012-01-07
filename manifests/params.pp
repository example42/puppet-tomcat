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

  # Let's deal with versions madness
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

  $port = $::tomcat_port ? {
    ''      => '8080',                    # Default value
    default => $::tomcat_port,
  }

  $protocol = $::tomcat_protocol ? {
    ''      => 'tcp',                   # Default value
    default => $::tomcat_protocol,
  }


  ### General variables that affect module's behaviour
  # They can be set at top scope level or in a ENC

  $my_class = $::tomcat_my_class ? {
    ''      => '',                      # Default value
    default => $::tomcat_my_class,
  }

  $source = $::tomcat_source ? {
    ''      => '',                      # Default value
    default => $::tomcat_source,
  }

  $source_dir = $::tomcat_source_dir ? {
    ''      => '',                      # Default value
    default => $::tomcat_source_dir,
  }

  $source_dir_purge = $::tomcat_source_dir_purge ? {
    ''      => false,                   # Default value
    default => $::tomcat_source_dir_purge,
  }

  $template = $::tomcat_template ? {
    ''      => '',                      # Default value
    default => $::tomcat_template,
  }

  $options = $::tomcat_options ? {
    ''      => '',                      # Default value
    default => $::tomcat_options,
  }

  $absent = $::tomcat_absent ? {
    ''      => false,                   # Default value
    default => $::tomcat_absent,
  }

  $disable = $::tomcat_disable ? {
    ''      => false,                   # Default value
    default => $::tomcat_disable,
  }

  $disableboot = $::tomcat_disableboot ? {
    ''      => false,                   # Default value
    default => $::tomcat_disableboot,
  }


  ### General module variables that can have a site or per module default
  # They can be set at top scope level or in a ENC

  $monitor = $::tomcat_monitor ? {
    ''      => $::monitor ? {
      ''      => false,                # Default value
      default => $::monitor,
    },
    default => $::tomcat_monitor,
  }

  $monitor_tool = $::tomcat_monitor_tool ? {
    ''      => $::monitor_tool ? {
      ''      => '',                   # Default value
      default => $::monitor_tool,
    },
    default => $::tomcat_monitor_tool,
  }

  $monitor_target = $::tomcat_monitor_target ? {
    ''      => $::monitor_target ? {
      ''      => $::ipaddress,         # Default value
      default => $::monitor_target,
    },
    default => $::tomcat_monitor_target,
  }

  $firewall = $::tomcat_firewall ? {
    ''      => $::firewall ? {
      ''      => false,                # Default value
      default => $::firewall,
    },
    default => $::tomcat_firewall,
  }

  $firewall_tool = $::tomcat_firewall_tool ? {
    ''      => $::firewall_tool ? {
      ''      => '',                   # Default value
      default => $::firewall_tool,
    },
    default => $::tomcat_firewall_tool,
  }

  $firewall_src = $::tomcat_firewall_src ? {
    ''      => $::firewall_src ? {
      ''      => '0.0.0.0/0',          # Default value
      default => $::firewall_src,
    },
    default => $::tomcat_firewall_src,
  }

  $firewall_dst = $::tomcat_firewall_dst ? {
    ''      => $::firewall_dst ? {
      ''      => $::ip_address,        # Default value
      default => $::firewall_dst,
    },
    default => $::tomcat_firewall_dst,
  }

  $puppi = $::tomcat_puppi ? {
    ''      => $::puppi ? {
      ''      => false,                # Default value
      default => $::puppi,
    },
    default => $::tomcat_puppi,
  }

  $puppi_helper = $::tomcat_puppi_helper ? {
    ''      => $::puppi_helper ? {
      ''      => 'standard',           # Default value
      default => $::puppi_helper,
    },
    default => $::tomcat_puppi_helper,
  }

  $debug = $::tomcat_debug ? {
    ''      => $::debug ? {
      ''      => false,                # Default value
      default => $::debug,
    },
    default => $::tomcat_debug,
  }

  $audit_only = $::tomcat_audit_only ? {
    ''      => $::audit_only ? {
      ''      => false,                # Default value
      default => $::audit_only,
    },
    default => $::tomcat_audit_only,
  }

}
