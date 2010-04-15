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

/*

== Class shibboleth::idp


*/
class shibboleth::idp {

  if ( ! $shibidp_ver ) {
    $shibidp_ver = "2.1.5"
  }

  if ( ! $shibidp_home ) {
    $shibidp_home = "/opt/shibboleth-idp-${shibidp_ver}"
  }

  if ( ! $shibidp_hostname ) {
    $shibidp_hostname = "localhost"
  }

  if ( ! $shibidp_keypass ) {
    fail("missing mandatory attribute: \$shibidp_keypass.")
  }

  if ( ! $shibidp_javahome ) {
    $shibidp_javahome = "/usr"
  }

  $mirror = "http://shibboleth.internet2.edu/downloads/shibboleth/idp"
  $url = "${mirror}/${shibidp_ver}/shibboleth-identityprovider-${shibidp_ver}-bin.zip"

  $shibidp_installdir = "/usr/src/shibboleth-identityprovider-${shibidp_ver}"

  common::archive::zip { "${shibidp_installdir}/.installed":
    source => $url,
    target => "/usr/src/",
  }

  # see http://ant.apache.org/faq.html#passing-cli-args
  exec { "install shibboleth idp":
    command => "cd ${shibidp_installdir} && ./install.sh",
    environment => ["JAVA_HOME=${shibidp_javahome}", "ANT_OPTS=-Didp.home.input=${shibidp_home} -Didp.hostname.input=${shibidp_hostname} -Didp.keystore.pass=${shibidp_keypass}"],
    creates => ["${shibidp_home}/war/idp.war"],
    require => Common::Archive::Zip["${shibidp_installdir}/.installed"],
  }

  file { "/opt/shibboleth-idp":
    ensure  => link,
    target  => $shibidp_home,
    require => Exec["install shibboleth idp"],
  }

  file { "/etc/shibboleth":
    ensure  => link,
    target  => "/opt/shibboleth-idp/conf",
    require => [File["/opt/shibboleth-idp"], Exec["install shibboleth idp"]],
  }

  file { "/var/log/shibboleth":
    ensure  => link,
    target  => "/opt/shibboleth-idp/logs",
    require => [File["/opt/shibboleth-idp"], Exec["install shibboleth idp"]],
  }

  if ( $shibidp_tomcat ) {

    # copy war file from installation dir to tomcat webapp dir.
    # see also https://spaces.internet2.edu/display/SHIB2/IdPApacheTomcatPrepare for
    # an alternate method.
    file { "/srv/tomcat/${shibidp_tomcat}/webapps/idp.war":
      source  => "file:///${shibidp_home}/war/idp.war",
      notify  => Service["tomcat-${shibidp_tomcat}"],
      require => [
        File["/srv/tomcat/${shibidp_tomcat}/webapps/"],
        Exec["install shibboleth idp"]],
    }

    # Copy library shipped with source to tomcat dir.
    # Don't forget to point the common.loader variable to this directory in
    # your catalina.properties file !
    file { "/srv/tomcat/${shibidp_tomcat}/private/endorsed/":
      ensure  => directory,
      source  => "file:///${shibidp_installdir}/endorsed/",
      recurse => true,
      require => [
        Common::Archive::Zip["${shibidp_installdir}/.installed"],
        File["/srv/tomcat/shibb-idp/private/"]],
      notify  => Service["tomcat-${shibidp_tomcat}"],
    }

  }

}
