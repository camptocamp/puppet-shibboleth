/*

== Class: shibboleth::administration

Creates a "shibboleth-admin" group and use sudo to allows members of this group
to:
- restart shibd service.

Requires:
- management of /etc/sudoers with common::concatfilepart

Warning: will overwrite /etc/sudoers !

*/
class shibboleth::administration {

  group { "shibboleth-admin":
    ensure => present,
  }

  common::concatfilepart { "sudoers.shibboleth":
    ensure  => present,
    file    => "/etc/sudoers",
    content => "# this part comes from shibboleth::administration
User_Alias SHIBBOLETH_ADMIN = %shibboleth-admin
Cmnd_Alias SHIBBOLETH_ADMIN = /etc/init.d/shibd
SHIBBOLETH_ADMIN ALL=(root) SHIBBOLETH_ADMIN
",
    require => Group["shibboleth-admin"],
  }

}
