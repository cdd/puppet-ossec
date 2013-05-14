
#
#
class ossec::common {
  case $lsbdistid {
    /(Ubuntu|ubuntu|Debian|debian)/ : {
      $hidsagentservice='ossec-hids-agent'
      $hidsagentpackage='ossec-hids-agent'
      $hidsserverservice='ossec-hids-server'
      $hidsserverpackage='ossec-hids-server'
      case "${lsbdistcodename}" {
        lucid: {
          apt::source { 'ossec_ppa':
            location => "http://ppa.launchpad.net/nicolas-zin/ossec-ubuntu/ubuntu",
            key      => "0C4FF926",
          }
        }
        default : { fail("This ossec module has not been tested on your distribution (or 'redhat-lsb' package not installed)") }
      }
    }
    /(CentOS|Redhat|RedHatEnterpriseServer)/ : {
      fail("This ossec module has not been tested on your distribution")
      # $hidsagentservice='ossec-hids'
      # $hidsagentpackage='ossec-hids-client'
      # $hidsserverservice='ossec-hids'
      # $hidsserverpackage='ossec-hids-server'
      # case $operatingsystemrelease {
      #   /^5/: {$redhatversion='el5'}
      #   /^6/: {$redhatversion='el6'}
      # }
      # package { 'inotify-tools': ensure=>present}
    }
    default : { fail("This ossec module has not been tested on your distribution") }
  }
}

