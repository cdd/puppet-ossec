class ossec::server (
  $mailserver_ip,
  $ossec_emailfrom = "ossec@${domain}",
  $ossec_emailto,
  $ossec_active_response = true,
  $ossec_global_host_information_level = 8,
  $ossec_global_stat_level=8,
  $ossec_email_alert_level=7,
  $ossec_ignorepaths = []
) {
  include ossec::common
	
  # install package
  case $lsbdistid {
    /(Ubuntu|ubuntu|Debian|debian)/ : {
        package { "ossec-hids-server":
          ensure  => installed,
          require => Apt::Source['ossec_ppa'],
        }
      }
    }
    default: { fail("OS family not supported") }
  }

#  include rsyslog::server
#  package{ $ossec::common::hidsserverpackage:
#	ensure => present,
#	require => Apt::Repo["ossec"]
#}
	
  service { $ossec::common::hidsserverservice:
    ensure => running,
    enable => true,
    hasstatus => true,
    pattern => $ossec::common::hidsserverservice,
    require => Package[$ossec::common::hidsserverpackage],
  }

  # configure ossec
  include concat::setup
  concat { '/var/ossec/etc/ossec.conf':
    owner => root,
    group => ossec,
    mode => 0440,
    require => Package[$ossec::common::hidsserverpackage],
    notify => Service[$ossec::common::hidsserverservice]
  }
  concat::fragment { "ossec.conf_10" :
    target => '/var/ossec/etc/ossec.conf',
    content => template("ossec/10_ossec.conf.erb"),
    order => 10,
    notify => Service[$ossec::common::hidsserverservice]
  }

#	Concat::Fragment <<| tag == 'ossec' |>>

  concat::fragment { "ossec.conf_90" :
    target => '/var/ossec/etc/ossec.conf',
    content => template("ossec/90_ossec.conf.erb"),
    order => 90,
    notify => Service[$ossec::common::hidsserverservice]
  }

#  # get log from rsyslog for apache
#  if (defined(Package['rsyslog'])) {
#    file {"/etc/rsyslog.d/30-ossec.conf":
#      ensure  => file,
#      group   => root,
#      owner   => root,
#      source  => "puppet:///modules/ossec/30-ossec.conf",
#      notify  => Service['rsyslog'],
#      require => Package['rsyslog'],
#    }
#  }

  include concat::setup
  concat { "/var/ossec/etc/client.keys":
    owner   => "root",
    group   => "ossec",
    mode    => "640",
    notify  => Service[$ossec::common::hidsserverservice]
  }
  Ossec::AgentKey<<| |>>

  concat::fragment { "var_ossec_etc_client.keys_end" :
    target  => "/var/ossec/etc/client.keys",
    order   => 99,
    content => "\n",
    notify => Service[$ossec::common::hidsserverservice]
  }

}
