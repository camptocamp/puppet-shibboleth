# == Class: shibboleth::sp
#
# Installs shibboleth's service provider, and allow it's apache module get
# loaded with apache::module.
#
# Requires:
# - Class[apache]
#
# Limitations:
# - currently RedHat/CentOS only.
class shibboleth::sp(
  $manage_repo    = true,
  $shib_mod_vers  = '22',
  $httpd_mod_file = '/etc/httpd/mods-available/shib.load',
) {

  if ( $manage_repo ) {
    # The content is taken directly from https://shibboleth.net/downloads/service-provider/RPMS/
    yumrepo { 'security_shibboleth':
      descr      => "Shibboleth-RHEL_${::operatingsystemmajrelease}",
      mirrorlist => "https://shibboleth.net/cgi-bin/mirrorlist.cgi/RHEL_${::operatingsystemmajrelease}",
      gpgkey     => "https://shibboleth.net/downloads/service-provider/RPMS/repomd.xml.key\n        https://shibboleth.net/downloads/service-provider/RPMS/cantor.repomd.xml.key",
      enabled    => 1,
      before     => Package['shibboleth'],
      gpgcheck   => 1,
    }

    # ensure file is managed in case we want to purge /etc/yum.repos.d/
    # http://projects.puppetlabs.com/issues/3152
    file { '/etc/yum.repos.d/security_shibboleth.repo':
      ensure  => file,
      mode    => '0644',
      owner   => 'root',
      require => Yumrepo['security_shibboleth'],
    }
  }

  package { 'shibboleth':
    ensure => present,
    name   => "shibboleth.${::architecture}",
  }

  $shibpath = $::architecture ? {
    'x86_64' => "/usr/lib64/shibboleth/mod_shib_${shib_mod_vers}.so",
    'i386'   => "/usr/lib/shibboleth/mod_shib_${shib_mod_vers}.so",
  }

  file { $httpd_mod_file:
    ensure  => file,
    content => "# file managed by puppet\nLoadModule mod_shib ${shibpath}\n",
  }

  file { '/etc/httpd/conf.d/shib.conf':
    ensure  => absent,
    require => Package['shibboleth'],
    notify  => Service['httpd'],
  }

# TODO
##
## Used for example logo and style sheet in error templates.
##
#<IfModule mod_alias.c>
#  <Location /shibboleth-sp>
#    Allow from all
#  </Location>
#  Alias /shibboleth-sp/main.css /usr/share/doc/shibboleth/main.css
#  Alias /shibboleth-sp/logo.jpg /usr/share/doc/shibboleth/logo.jpg
#</IfModule>

}
