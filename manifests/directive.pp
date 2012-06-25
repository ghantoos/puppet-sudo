define sudo::directive (
  $ensure=present,
  $content="",
  $source=""
) {

  # sudo skipping file names that contain a "."
  $dname = regsubst($name, '\.', '-', 'G')

  if versioncmp($::sudoversion,'1.7.2') < 0 {

    common::append_if_no_such_line { $dname:
      file  => "/etc/sudoers",
      line  => $content ? {
        ""      => undef,
        default => $content,
      },
      require => Package["sudo"],
    }
  
  } else {

    file {"/etc/sudoers.d/${dname}":
      ensure  => $ensure,
      owner   => root,
      group   => root,
      mode    => 0440,
      content => $content ? {
        ""      => undef,   
        default => $content,
      },
      source  => $source ? {
        ""      => undef,  
        default => $source,
      },
      notify  => Exec["sudo-syntax-check for file $dname"],
      require => Package["sudo"],
    }
  
  }

  exec {"sudo-syntax-check for file $dname":
    command     => "/usr/sbin/visudo -c -f /etc/sudoers.d/${dname} || ( rm -f /etc/sudoers.d/${dname} && exit 1)",
    refreshonly => true,
  }

}
