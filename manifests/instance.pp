# Define: tomcat::instance
# NOTE: Work in progress. Still doesn't work
#
# Tomcat user instance
#
# Usage:
# With standard template:
# tomcat::instance  { "name": }
#
define tomcat::instance (
  $basedir                = '/srv',
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
  $manager                = false
  ) {

  require tomcat::params

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

  # AJP proxy port - Used in server.xml-default template
  # Note: YOU MUST explicitely define a template name in $serverxmltemplate to use one
  # By default the script that creates an instance doesn't set the ajp port

  # CATALINA BASE
  $instance_path = "${basedir}/${instance_name}"

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
    /(?i:Debian|Ubuntu)/           => $tomcat::tomcat_version ? {
      '7'     => "chown ${instance_owner}:${instance_group} ${basedir} && su - ${instance_owner} -c '/usr/bin/tomcat7-instance-create -p ${httpport} -c ${controlport} -w ${magicword} ${instance_path}' && chown ${basedir_owner}:${basedir_group} ${basedir}",
      '6'     => "chown ${instance_owner}:${instance_group} ${basedir} && su - ${instance_owner} -c '/usr/bin/tomcat6-instance-create -p ${httpport} -c ${controlport} -w ${magicword} ${instance_path}' && chown ${basedir_owner}:${basedir_group} ${basedir}",
      '5'     => "chown ${instance_owner}:${instance_group} ${basedir} && su - ${instance_owner} -c '/usr/bin/tomcat5-instance-create -p ${httpport} -c ${controlport} -w ${magicword} ${instance_path}' && chown ${basedir_owner}:${basedir_group} ${basedir}",
    },
    /(?i:CentOS|RedHat|Scientific)/ => "chown ${instance_owner}:${instance_group} ${basedir} && su - ${instance_owner} -c '/usr/bin/tomcat-instance-create -p ${httpport} -c ${controlport} -w ${magicword} ${instance_path}' && chown ${basedir_owner}:${basedir_group} ${basedir}",
  }

  # Create instance (First we install or create the tomcat-instance-create script)
  case $::operatingsystem {
    debian,ubuntu: {
      package { "${tomcat::params::pkgver}-user":
        ensure => present,
      }
    }
    redhat,centos,scientific: {
      file { "/usr/bin/tomcat-instance-create":
        ensure  => present,
        mode    => '0775',
        owner   => 'root',
        group   => 'root',
        content => template('tomcat/tomcat-instance-create.erb'),
      }
    }
  }


  exec { "instance_tomcat_${instance_name}":
    command => $instance_create_exec,
    creates => "${instance_path}/webapps",
    require => Package["tomcat"],
  }

  if $manager == true {
    include tomcat::manager
    exec { "tomcat-manager-${instance_name}":
        command => "cp -a /usr/share/tomcat6-admin/manager/ ${basedir}/${instance_name}/webapps && chown -R ${instance_owner}:${instance_group} ${basedir}/${instance_name}/webapps/manager",
        creates => "${basedir}/${instance_name}/webapps/manager",
        require  => Class["tomcat::manager"],
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
  service {"tomcat-${instance_name}":
    ensure     => running,
    name       => "tomcat-${instance_name}",
    enable     => true,
    pattern    => $instance_name,
    hasrestart => true,
    hasstatus  => "${tomcat::params::service_status}",
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
    content => template("$inittemplate"),
  }

  # catalina.properties is defined only if $catalinaproperties is set
  if $catalinaproperties != '' {
    file { "instance_tomcat_catalina.properties_${instance_name}":
      ensure  => present,
      path    => "${basedir}/${instance_name}/conf/catalina.properties",
      mode    => $filemode,
      owner   => $instance_owner,
      group   => $instance_group,
      require => Exec["instance_tomcat_${instance_name}"],
      notify  => Service["tomcat-${instance_name}"],
      content => template("$catalinaproperties"),
    }
  }

  # Ensure logging.properties presence
  file { "instance_tomcat_logging.properties_${instance_name}":
    ensure  => present,
    path    => "${basedir}/${instance_name}/conf/logging.properties",
    mode    => $filemode,
    owner   => $instance_owner,
    group   => $instance_group,
    require => Exec["instance_tomcat_${instance_name}"],
    notify  => Service["tomcat-${instance_name}"],
  }

  # Ensure setenv.sh presence
  file { "instance_tomcat_setenv.sh_${instance_name}":
    ensure  => present,
    path    => "${basedir}/${instance_name}/bin/setenv.sh",
    mode    => '0755',
    owner   => $instance_owner,
    group   => $instance_group,
    require => Exec["instance_tomcat_${instance_name}"],
    notify  => Service["tomcat-${instance_name}"],
    source  => template("$setenvshtemplate"),
  }

  # Ensure params presence
  file { "instance_tomcat_params_${instance_name}":
    ensure  => present,
    path    => "${basedir}/${instance_name}/bin/params",
    mode    => '0755',
    owner   => $instance_owner,
    group   => $instance_group,
    require => Exec["instance_tomcat_${instance_name}"],
    source  => template("$paramstemplate"),
  }

  # Ensure startup.sh presence
  file { "instance_tomcat_startup.sh_${instance_name}":
    ensure  => present,
    path    => $instance_startup,
    mode    => '0755',
    owner   => $instance_owner,
    group   => $instance_group,
    require => Exec["instance_tomcat_${instance_name}"],
    content => template("$startupshtemplate"),
  }

  # Ensure shutdown.sh presence
  file { "instance_tomcat_shutdown.sh_${instance_name}":
    ensure  => present,
    path    => $instance_shutdown,
    mode    => '0755',
    owner   => $instance_owner,
    group   => $instance_group,
    require => Exec["instance_tomcat_${instance_name}"],
    content => template("$shutdownshtemplate"),
  }

  # server.xml is defined only if $serverxmltemplate is set
  if $serverxmltemplate != '' {
    file { "instance_tomcat_server.xml_${instance_name}":
      ensure  => present,
      path    => "${basedir}/${instance_name}/conf/server.xml",
      mode    => $filemode,
      owner   => $instance_owner,
      group   => $instance_group,
      require => Exec["instance_tomcat_${instance_name}"],
      notify  => Service["tomcat-${instance_name}"],
      content => template("$serverxmltemplate"),
    }
  }

  # context.xml is defined only if $contextxmltemplate is set
  if $contextxmltemplate != "" {
    file { "instance_tomcat_context.xml_${instance_name}":
      ensure  => present,
      path    => "${basedir}/${instance_name}/conf/context.xml",
      mode    => $filemode,
      owner   => $instance_owner,
      group   => $instance_group,
      require => Exec["instance_tomcat_${instance_name}"],
      notify  => Service["tomcat-${instance_name}"],
      content => template("$contextxmltemplate"),
    }
  }

  # tomcat-users.xml is defined only if $tomcatusersxmltemplate is set
  if $tomcatusersxmltemplate != '' {
    file { "instance_tomcat_tomcat-users.xml_${instance_name}":
      ensure  => present,
      path    => "${basedir}/${instance_name}/conf/tomcat-users.xml",
      mode    => $filemode,
      owner   => $instance_owner,
      group   => $instance_group,
      require => Exec["instance_tomcat_${instance_name}"],
      notify  => Service["tomcat-${instance_name}"],
      content => template("$tomcatusersxmltemplate"),
    }
  }

  # web.xml is defined only if $webxmltemplate is set
  if $webxmltemplate != '' {
    file { "instance_tomcat_web.xml_${instance_name}":
      ensure  => present,
      path    => "${basedir}/${instance_name}/conf/web.xml",
      mode    => $filemode,
      owner   => $instance_owner,
      group   => $instance_group,
      require => Exec["instance_tomcat_${instance_name}"],
      notify  => Service["tomcat-${instance_name}"],
      content => template("$webxmltemplate"),
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
    content => template("tomcat/logCompressor.cron.erb"),
  }

  if $monitor ==true {
    monitor::process { "tomcat-$instance_name":
      process  => 'java',
      argument => $instance_name,
      service  => "tomcat-${instance_name}",
      pidfile  => "${instance_rundir}/tomcat-${instance_name}.pid",
      enable   => true,
      tool     => $monitor_tool,
    }

    monitor::port { "tomcat_tcp_$httpport":
      protocol => 'tcp',
      port     => $httpport,
      target   => $fqdn,
      enable   => true,
      tool     => $monitor_tool,
    }
  }
  if $puppi == true {
    puppi::log { "tomcat-${instance_name}":
      log => "${basedir}/${instance_name}/logs/catalina.out",
    }
    puppi::info::instance { "tomcat-${instance_name}":
      servicename => "tomcat-${instance_name}",
      processname => $instance_name,
      configdir   => "${basedir}/${instance_name}/conf/",
      bindir      => "${basedir}/${instance_name}/bin/",
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
