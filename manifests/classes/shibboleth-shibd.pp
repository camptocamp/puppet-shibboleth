/*

== Class: shibboleth::shibd

Enables the shibd daemon.

Requires:
- Class[shibboleth::sp]

*/
class shibboleth::shibd {

  service { "shibd":
    ensure  => running,
    enable  => true,
    require => Package["shibboleth"],
  }

  #TODO: fix selinux perms on /var/run/shibboleth/shibd.sock

}
