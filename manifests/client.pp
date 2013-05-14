#
class ossec::client (
  $ossec_active_response=true,
  $ossec_server_ip
) {
  include ossec::common

  case $lsbdistid {
    /(Ubuntu|ubuntu|Debian|debian)/ : {
      package { "ossec-hids-agent":
        ensure => installed,
        require => Apt::Source['ossec_ppa'],
      }
    }
    default: { fail("OS family not supported") }
  }

  service { $ossec::common::hidsagentservice:
    ensure => running,
    enable => true,
    hasstatus => true,
    pattern => $ossec::common::hidsagentservice,
    require => Package[$ossec::common::hidsagentpackage],
  }

  include concat::setup
  concat { '/var/ossec/etc/ossec.conf':
    owner => root,
    group => ossec,
    mode => 0440,
    require => Package[$ossec::common::hidsagentpackage],
    notify => Service[$ossec::common::hidsagentservice]
  }

  concat::fragment { "ossec.conf_10" :
    target => '/var/ossec/etc/ossec.conf',
    content => template("ossec/10_ossec_agent.conf.erb"),
    order => 10,
    notify => Service[$ossec::common::hidsagentservice]
  }
  concat::fragment { "ossec.conf_99" :
    target => '/var/ossec/etc/ossec.conf',
    content => template("ossec/99_ossec_agent.conf.erb"),
    order => 99,
    notify => Service[$ossec::common::hidsagentservice]
  }

  # get log from rsyslog for apache
#  file {"/etc/rsyslog.d/30-ossec_agent.conf":
#    ensure  => file,
#    group   => root,
#    owner   => root,
#    source  => "puppet:///modules/ossec/30-ossec_agent.conf",
#    notify  => Service['rsyslog'],
#    require => Package['rsyslog'],
#  }

  include concat::setup
  concat { "/var/ossec/etc/client.keys":
    owner   => "root",
    group   => "ossec",
    mode    => "640",
    notify  => Service[$ossec::common::hidsagentservice],
    require => Package[$ossec::common::hidsagentpackage]
  }
  ossec::agentKey{ "ossec_agent_${hostname}_client": agent_id=>$uniqueid, agent_name => $hostname, agent_ip_address => $ipaddress}
  @@ossec::agentKey{ "ossec_agent_${hostname}_server": agent_id=>$uniqueid, agent_name => $hostname, agent_ip_address => $ipaddress}
}


