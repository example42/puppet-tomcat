# Define: tomcat::instance
# NOTE: Work in progress. Has only been tested limited under Ubuntu 12.04
#
# Tomcat user instance
#
# == Parameters
#
# Standard class parameters
# Define the general class behaviour and customizations
#
# [*dirmode*]
#
# [*filemode*]
#
# [*owner*]
#
# [*group*]
#
# [*httpport*]
#
# [*controlport*]
#
# [*ajpport*]
#
# [*magicword*]
#
# [*backupsdir*]
#
# [*rundir*]
#
# [*logdir*]
#
# [*catalinaproperties*]
#
# [*inittemplate*]
#
# [*startupshtemplate*]
#
# [*shutdownshtemplate*]
#
# [*setenvshtemplate*]
#
# [*paramstemplate*]
#
# [*serverxmltemplate*]
#
# [*contextxmltemplate*]
#
# [*tomcatusersxmltemplate*]
#
# [*webxmltemplate*]
#
# [*tomcatuser*]
#
# [*tomcatpassword*]
#
# [*puppi*]
#
# [*monitor*]
#
# [*manager*]
#
# [*modjk_workers_file*]
# The path of the mod_jk workers file to be generated.
# Requires tomcat::mod_jk to be useful.
#
# Usage:
# With standard template:
# tomcat::instance  { "name": }
#
# Notes
# =====
#
# AJP proxy port - Used in server.xml-default template
# Note: YOU MUST explicitly define a template name in $serverxmltemplate to use one
# By default the script that creates an instance doesn't set the ajp port
#
define tomcat::instance (
  $dirmode                = '0755',
  $filemode               = '0644',
  $owner                  = '',
  $group                  = '',
  $httpport               = '8080',
  $controlport            = '8005',
  $ajpport                = '8009',
  $magicword              = 'SHUTDOWN',
  $backupsdir             = '',
  $rundir                 = '',
  $logdir                 = '',
  $catalinaproperties     = '',
  $inittemplate           = 'tomcat/init.erb',
  $startupshtemplate      = 'tomcat/startup.sh.erb',
  $shutdownshtemplate     = 'tomcat/shutdown.sh.erb',
  $setenvshtemplate       = 'tomcat/setenv.sh.erb',
  $paramstemplate         = 'tomcat/params.erb',
  $serverxmltemplate      = '',
  $contextxmltemplate     = '',
  $tomcatusersxmltemplate = '',
  $webxmltemplate         = '',
  $tomcatuser             = '',
  $tomcatpassword         = '',
  $puppi                  = true,
  $monitor                = true,
  $manager                = false,
  $modjk_workers_file     = '',
  ) {

  require tomcat::params

  $tomcat_version = $tomcat::params::version

  # Application name, required
  $instance_name = $name

  # Application owner, by default the same instance name
  $instance_owner = $owner ? {
    ''      => $name,
    default => $owner,
  }

  # Application group, by default the same instance name
  $instance_group = $group ? {
    ''      => $name,
    default => $group,
  }

  # CATALINA BASE
  $instance_path = "/var/lib/${tomcat::params::pkgver}-${instance_name}"

  # Backups dir
  $instance_backupsdir = $backupsdir ? {
    ''      => "${instance_path}/backups",
    default => $backupsdir,
  }

  # Run dir
  $instance_rundir = $rundir ? {
    ''      => "${instance_path}/run",
    default => $rundir,
  }

  # Log dir
  $instance_logdir = $logdir ? {
    ''      => "${instance_path}/logs",
    default => $logdir,
  }

  # Startup script
  $instance_startup = "${instance_path}/bin/startup.sh"

  # Shutdown script
  $instance_shutdown = "${instance_path}/bin/shutdown.sh"

  # Log Compressor script
  $instance_logCompressor = "${instance_path}/bin/logCompressor.sh"

  $instance_create_exec = $::operatingsystem ? {
    /(?i:Debian|Ubuntu)/           => $tomcat_version ? {
      '7'     => "/usr/bin/tomcat7-instance-create -p ${httpport} -c ${controlport} -w ${magicword} ${instance_path} && chown -R ${instance_owner}:${instance_group} ${instance_path}",
      '6'     => "/usr/bin/tomcat6-instance-create -p ${httpport} -c ${controlport} -w ${magicword} ${instance_path} && chown -R ${instance_owner}:${instance_group} ${instance_path}",
      '5'     => "/usr/bin/tomcat5-instance-create -p ${httpport} -c ${controlport} -w ${magicword} ${instance_path} && chown -R ${instance_owner}:${instance_group} ${instance_path}",
    },
    /(?i:CentOS|RedHat|Scientific)/ => "/usr/bin/tomcat-instance-create -p ${httpport} -c ${controlport} -w ${magicword} ${instance_path} && chown ${instance_owner}:${instance_group} ${instance_path}",
  }

  # Create instance (First we install or create the tomcat-instance-create script)
  case $::operatingsystem {
    debian,ubuntu: {
      if (!defined(Package["${tomcat::params::pkgver}-user"])) {
        package { "${tomcat::params::pkgver}-user":
          ensure => present,
          before => Exec["instance_tomcat_${instance_name}"],
        }
      }
    }
    redhat,centos,scientific: {
      file { '/usr/bin/tomcat-instance-create':
        ensure  => present,
        mode    => '0775',
        owner   => 'root',
        group   => 'root',
        content => template('tomcat/tomcat-instance-create.erb'),
        before  => Exec["instance_tomcat_${instance_name}"]
      }
    }
  }

  exec { "instance_tomcat_${instance_name}":
    command => $instance_create_exec,
    creates => "${instance_path}/webapps",
    require => [ Package['tomcat'], Group[$instance_owner] ],
  }

  if $manager == true {
    include tomcat::manager
    exec { "tomcat-manager-${instance_name}":
        command => "cp -a /usr/share/tomcat6-admin/manager/ ${instance_path}/webapps && chown -R ${instance_owner}:${instance_group} ${instance_path}/webapps/manager",
        creates => "${instance_path}/webapps/manager",
        require => [ Class['tomcat::manager'], Group[$instance_owner] ],
      }
  }

  # Create backups dir
  file { "tomcat_backupsdir-${instance_name}":
    ensure  => directory,
    path    => $instance_backupsdir,
    mode    => $dirmode,
    owner   => $instance_owner,
    group   => $instance_group,
    require => Exec["instance_tomcat_${instance_name}"],
  }

  # Create run dir
  file { "tomcat_rundir-${instance_name}":
    ensure  => directory,
    path    => $instance_rundir,
    mode    => $dirmode,
    owner   => $instance_owner,
    group   => $instance_group,
    require => Exec["instance_tomcat_${instance_name}"],
  }

  # Create log dir
  file { "tomcat_logdir-${instance_name}":
    ensure  => directory,
    path    => $instance_logdir,
    mode    => $dirmode,
    owner   => $instance_owner,
    group   => $instance_group,
    require => Exec["instance_tomcat_${instance_name}"],
  }

  # Running service
  service { "tomcat-${instance_name}":
    ensure     => running,
    name       => "${tomcat::params::pkgver}-${instance_name}",
    enable     => true,
    pattern    => $instance_name,
    hasrestart => true,
    hasstatus  => $tomcat::params::service_status,
    require    => Exec["instance_tomcat_${instance_name}"],
    subscribe  => File["instance_tomcat_initd_${instance_name}"],
  }

  # Create service initd file
  file { "instance_tomcat_initd_${instance_name}":
    ensure  => present,
    path    => "${tomcat::params::config_file_init}-${instance_name}",
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    require => Exec["instance_tomcat_${instance_name}"],
    notify  => Service["tomcat-${instance_name}"],
    content => template($inittemplate),
  }

  file { "${instance_path}/conf/policy.d/":
    ensure  => directory,
    owner   => $instance_owner,
    group   => $instance_group,
    require => Exec[ "instance_tomcat_${instance_name}" ]
  }

  # catalina.properties is defined only if $catalinaproperties is set
  if $catalinaproperties != '' {
    file { "instance_tomcat_catalina.properties_${instance_name}":
      ensure  => present,
      path    => "${instance_path}/conf/catalina.properties",
      mode    => $filemode,
      owner   => $instance_owner,
      group   => $instance_group,
      require => Exec["instance_tomcat_${instance_name}"],
      notify  => Service["tomcat-${instance_name}"],
      content => template($catalinaproperties),
    }
  }

  # Ensure logging.properties presence
  file { "instance_tomcat_logging.properties_${instance_name}":
    ensure  => present,
    path    => "${instance_path}/conf/logging.properties",
    mode    => $filemode,
    owner   => $instance_owner,
    group   => $instance_group,
    require => Exec["instance_tomcat_${instance_name}"],
    notify  => Service["tomcat-${instance_name}"],
  }

  # Ensure setenv.sh presence
  file { "instance_tomcat_setenv.sh_${instance_name}":
    ensure  => present,
    path    => "${instance_path}/bin/setenv.sh",
    mode    => '0755',
    owner   => $instance_owner,
    group   => $instance_group,
    require => Exec["instance_tomcat_${instance_name}"],
    notify  => Service["tomcat-${instance_name}"],
    content => template($setenvshtemplate),
  }

  # Ensure params presence
  file { "instance_tomcat_params_${instance_name}":
    ensure  => present,
    path    => "${instance_path}/bin/params",
    mode    => '0755',
    owner   => $instance_owner,
    group   => $instance_group,
    require => Exec["instance_tomcat_${instance_name}"],
    content => template($paramstemplate),
  }

  # Ensure startup.sh presence
  file { "instance_tomcat_startup.sh_${instance_name}":
    ensure  => present,
    path    => $instance_startup,
    mode    => '0755',
    owner   => $instance_owner,
    group   => $instance_group,
    require => Exec["instance_tomcat_${instance_name}"],
    content => template($startupshtemplate),
  }

  # Ensure shutdown.sh presence
  file { "instance_tomcat_shutdown.sh_${instance_name}":
    ensure  => present,
    path    => $instance_shutdown,
    mode    => '0755',
    owner   => $instance_owner,
    group   => $instance_group,
    require => Exec["instance_tomcat_${instance_name}"],
    content => template($shutdownshtemplate),
  }

  # server.xml is defined only if $serverxmltemplate is set
  if $serverxmltemplate != '' {
    file { "instance_tomcat_server.xml_${instance_name}":
      ensure  => present,
      path    => "${instance_path}/conf/server.xml",
      mode    => $filemode,
      owner   => $instance_owner,
      group   => $instance_group,
      require => Exec["instance_tomcat_${instance_name}"],
      notify  => Service["tomcat-${instance_name}"],
      content => template($serverxmltemplate),
    }
  }

  # context.xml is defined only if $contextxmltemplate is set
  if $contextxmltemplate != '' {
    file { "instance_tomcat_context.xml_${instance_name}":
      ensure  => present,
      path    => "${instance_path}/conf/context.xml",
      mode    => $filemode,
      owner   => $instance_owner,
      group   => $instance_group,
      require => Exec["instance_tomcat_${instance_name}"],
      notify  => Service["tomcat-${instance_name}"],
      content => template($contextxmltemplate),
    }
  }

  # tomcat-users.xml is defined only if $tomcatusersxmltemplate is set
  if $tomcatusersxmltemplate != '' {
    file { "instance_tomcat_tomcat-users.xml_${instance_name}":
      ensure  => present,
      path    => "${instance_path}/conf/tomcat-users.xml",
      mode    => $filemode,
      owner   => $instance_owner,
      group   => $instance_group,
      require => Exec["instance_tomcat_${instance_name}"],
      notify  => Service["tomcat-${instance_name}"],
      content => template($tomcatusersxmltemplate),
    }
  }

  # web.xml is defined only if $webxmltemplate is set
  if $webxmltemplate != '' {
    file { "instance_tomcat_web.xml_${instance_name}":
      ensure  => present,
      path    => "${instance_path}/conf/web.xml",
      mode    => $filemode,
      owner   => $instance_owner,
      group   => $instance_group,
      require => Exec["instance_tomcat_${instance_name}"],
      notify  => Service["tomcat-${instance_name}"],
      content => template($webxmltemplate),
    }
  }

  # Compress instance logs
  file { "instance_tomcat_logCompressor.sh_${instance_name}":
    ensure  => present,
    path    => $instance_logCompressor,
    mode    => '0755',
    owner   => $instance_owner,
    group   => $instance_group,
    require => Exec["instance_tomcat_${instance_name}"],
    content => template('tomcat/logCompressor.sh.erb'),
  }

  file { "instance_tomcat_logCompressor.cron_${instance_name}":
    ensure  => present,
    path    => "/etc/cron.d/tomcat_logcompress_${instance_name}",
    content => template('tomcat/logCompressor.cron.erb'),
  }

  if ($modjk_workers_file != '') {
    include concat::setup

    $normalized_modjk_workers_file = regsubst($modjk_workers_file, '/', '_', 'G')

    concat::fragment{"instance_tomcat_modjk_${instance_name}":
      target  => "${::concat::setup::concatdir}/instance_tomcat_modjk_${normalized_modjk_workers_file}",
      content => template('tomcat/modjk.worker.properties'),
    }

    concat::fragment{"instance_tomcat_modjk_names_${instance_name}":
      target  => "${::concat::setup::concatdir}/instance_tomcat_modjk_names_${normalized_modjk_workers_file}",
      content => "${instance_name}_worker, ",
    }

  }

  if $monitor == true {
    monitor::process { "tomcat-${instance_name}":
      process  => 'java',
      argument => $instance_name,
      service  => "tomcat-${instance_name}",
      pidfile  => "${instance_rundir}/tomcat-${instance_name}.pid",
      enable   => true,
      tool     => $monitor_tool,
    }

    monitor::port { "tomcat_tcp_${httpport}":
      protocol => 'tcp',
      port     => $httpport,
      target   => $::fqdn,
      enable   => true,
      tool     => $monitor_tool,
    }
  }
  if $puppi == true {
    puppi::log { "tomcat-${instance_name}":
      log => "${instance_path}/logs/catalina.out",
    }

    puppi::info::instance { "tomcat-${instance_name}":
      servicename => "tomcat-${instance_name}",
      processname => $instance_name,
      configdir   => "${instance_path}/conf/",
      bindir      => "${instance_path}/bin/",
      pidfile     => "${instance_rundir}/tomcat-${instance_name}.pid",
      datadir     => "${instance_path}/webapps",
      logdir      => $instance_logdir,
      httpport    => $httpport,
      controlport => $controlport,
      ajpport     => $ajpport,
      description => "Info for ${instance_name} Tomcat instance" ,
    }
  }
}
