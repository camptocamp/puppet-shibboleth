#
# == Class: shibboleth::shibd
#
# Enables the shibd daemon.
#
# Requires:
# - Class[shibboleth::sp]
# - selinux module
#
class shibboleth::shibd {

  $manage_shibd_user = $shibd_user ? {
        '' => false,
   default => true,
  }

  $shibd_local_config_file = $operatingsystem ? {
    /RedHat|CentOS/ => '/etc/sysconfig/shibd',
            default => '',
  }

  $shibd_user = $shibd_user ? {
         '' => 'root',
    default => $shibd_user,
  }

  service { 'shibd':
    ensure  => running,
    enable  => true,
    require => Package[ 'shibboleth' ],
  }

  # apache must be able to connect to shibd's socket.
  if $selinux {

    file { '/var/run/shibboleth/':
      ensure  => 'directory',
      owner   => $shibd_user,
      group   => $shibd_user,
      seltype => 'httpd_var_run_t',
      notify  => Service[ 'shibd' ],
      require => Package[ 'shibboleth' ],
    }

    selinux::module { 'shibd':
      notify  => Selmodule[ 'shibd' ],
      content => "# file managed by puppet

module shibd 1.0;

require {
        type httpd_t;
        type initrc_t;
        class unix_stream_socket connectto;
}

#============= httpd_t ==============
allow httpd_t initrc_t:unix_stream_socket connectto;
",

    }

    selmodule { 'shibd':
      ensure      => present,
      syncversion => true,
    }

  }

  file { '/var/log/shibboleth':
    ensure => 'directory',
    owner  => $shibd_user,
    group  => $shibd_user,
    mode   => '750',
  }

  if $manage_shibd_user {

    file { $shibd_local_config_file:
      ensure  => present,
      content => template( "shibboleth/etc/config/shibd.$operatingsystem.erb" ),
      owner   => 'root',
      group   => 'root',
      mode    => 644,
    }

  }

}
