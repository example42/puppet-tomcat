# Puppet module: tomcat

This is a Puppet tomcat module from the second generation of Example42 Puppet Modules.

Made by Alessandro Franceschi / Lab42 - http://www.example42.com

Released under the terms of Apache 2 License.

Check Modulefile for dependencies.

## GENERAL USAGE
This module can be used in 2 ways:

* With the old style "Set variables and include class" pattern:

        $tomcat_template = "example42/tomcat/tomcat.conf.erb"
        include tomcat

* As a parametrized class:

        class { "tomcat":
          template => "example42/tomcat/tomcat.conf.erb",
        }

You can even, under some degrees, mix these two patterns.

You can for example set general top scope variables that affect all your parametrized classes:

        $puppi = true
        $monitor = true
        $monitor_tool = [ "nagios" , "munin" , "puppi" ]
        class { "tomcat":
          template => "example42/tomcat/tomcat.conf.erb",
        }
        
The above example has the same effect of:

        class { "tomcat":
          template => "example42/tomcat/tomcat.conf.erb",
          puppi        => true,
          monitor      => true,
          monitor_tool => [ "nagios" , "munin" , "puppi" ],
        }

Note that if you use the "Set variables and include class" pattern you can define variables only
at the top level scope or in a ENC (External Node Classifer) like Puppet Dashboard, Puppet Enterprise Console or The Foreman.

Below you have an overview of the most important module's parameters (you can mix and aggregate them).

The examples use parametrized classes, but for all the parameters you can set a $tomcat_ top scope variable.

For example, the variable "$tomcat_absent" is equivant to the "absent =>" parameter.

## USAGE - Basic management
* Install tomcat with default settings

        class { "tomcat": }

* Disable tomcat service.

        class { "tomcat":
          disable => true
        }

* Disable tomcat service at boot time, but don't stop if is running.

        class { "tomcat":
          disableboot => true
        }

* Remove tomcat package

        class { "tomcat":
          absent => true
        }

* Enable auditing without without making changes on existing tomcat configuration files

        class { "tomcat":
          audit_only => true
        }


## USAGE - Overrides and Customizations
* Use custom sources for main config file 

        class { "tomcat":
          source => [ "puppet:///modules/lab42/tomcat/tomcat.conf-${hostname}" , "puppet:///modules/lab42/tomcat/tomcat.conf" ], 
        }


* Use custom source directory for the whole configuration dir

        class { "tomcat":
          source_dir       => "puppet:///modules/lab42/tomcat/conf/",
          source_dir_purge => false, # Set to true to purge any existing file not present in $source_dir
        }

* Use custom template for main config file 

        class { "tomcat":
          template => "example42/tomcat/tomcat.conf.erb",      
        }

* Define custom options that can be used in a custom template without the
  need to add parameters to the tomcat class

        class { "tomcat":
          template => "example42/tomcat/tomcat.conf.erb",    
          options  => {
            'LogLevel' => 'INFO',
            'UsePAM'   => 'yes',
          },
        }

* Automaticallly include a custom subclass

        class { "tomcat:"
          my_class => 'tomcat::example42',
        }


## USAGE - Example42 extensions management 
* Activate puppi (recommended, but disabled by default)
  Note that this option requires the usage of Example42 puppi module

        class { "tomcat": 
          puppi    => true,
        }

* Activate puppi and use a custom puppi_helper template (to be provided separately with
  a puppi::helper define ) to customize the output of puppi commands 

        class { "tomcat":
          puppi        => true,
          puppi_helper => "myhelper", 
        }

* Activate automatic monitoring (recommended, but disabled by default)
  This option requires the usage of Example42 monitor and relevant monitor tools modules

        class { "tomcat":
          monitor      => true,
          monitor_tool => [ "nagios" , "monit" , "munin" ],
        }

* Activate automatic firewalling 
  This option requires the usage of Example42 firewall and relevant firewall tools modules

        class { "tomcat":       
          firewall      => true,
          firewall_tool => "iptables",
          firewall_src  => "10.42.0.0/24",
          firewall_dst  => "$ipaddress_eth0",
        }


