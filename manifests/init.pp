class shibboleth::sp {

  yumrepo { "security_shibboleth":
    descr    => "Shibboleth-RHEL_${lsbmajdistrelease}",
    baseurl  => "http://download.opensuse.org/repositories/security://shibboleth/RHEL_${lsbmajdistrelease}",
    gpgkey   => "file:///etc/pki/rpm-gpg/RPM-GPG-KEY-shibboleth",
    enabled  => 1,
    gpgcheck => 1,
    require  => Exec["download shibboleth repo key"],
  }

  exec { "download shibboleth repo key":
    command => "curl -s http://download.opensuse.org/repositories/security:/shibboleth/RHEL_5/repodata/repomd.xml.key -o /etc/pki/rpm-gpg/RPM-GPG-KEY-shibboleth",
    creates => "/etc/pki/rpm-gpg/RPM-GPG-KEY-shibboleth",
    require => File["/etc/pki/rpm-gpg/"],
  }

  package { "shibboleth":
    ensure  => "present",
    name    => "shibboleth.${architecture}",
    require => Yumrepo["security_shibboleth"],
  }

  $shibpath = $architecture ? {
    x86_64 => "/usr/lib64/shibboleth/mod_shib_22.so",
    i386   => "/usr/lib/shibboleth/mod_shib_22.so",
  }

  file { "/etc/httpd/mods-available/shib.load":
    ensure  => present,
    content => "# file managed by puppet\nLoadModule mod_shib ${shibpath}\n",
  }

  file { "/etc/httpd/conf.d/shib.conf":
    ensure  => absent,
    require => Package["shibboleth"],
    notify  => Service["apache"],
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

class shibboleth::idp {
}
