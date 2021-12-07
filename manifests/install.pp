# == Class etherpad::install
#
# This class is called from etherpad for install.
#
class etherpad::install {
  case $etherpad::ensure {
    'present', 'absent', 'latest': {
      $deps_ensure    = $etherpad::ensure
      $vcs_ensure     = $etherpad::ensure
      $vcs_revision   = 'master'
    }
    default: {
      $deps_ensure    = 'present'
      $vcs_ensure     = 'present'
      $vcs_revision   = $etherpad::ensure
    }
  }

  if $etherpad::logconfig_file {
    file { $etherpad::logconfig_file_filename:
      ensure => file,
      owner  => $etherpad::user,
      group  => $etherpad::group,
    }
  }

  if $etherpad::manage_abiword {
    package { 'abiword':
      ensure => $deps_ensure,
    }
  }
  if $etherpad::manage_tidy {
    package { 'tidy':
      ensure => $deps_ensure,
    }
  }

  if $deps_ensure == 'absent' {
    exec { "/bin/rm -rf ${etherpad::root_dir}":
      onlyif => "/usr/bin/test -e ${etherpad::root_dir}",
    }
  } else {
    $environment = ["HOME=${etherpad::root_dir}"]

    vcsrepo { $etherpad::root_dir:
      ensure   => $vcs_ensure,
      provider => 'git',
      owner    => $etherpad::user,
      group    => $etherpad::group,
      source   => $etherpad::source,
      revision => $vcs_revision,
    }
    ~> exec { "${etherpad::root_dir}/bin/installDeps.sh":
      user        => $etherpad::user,
      group       => $etherpad::group,
      cwd         => $etherpad::root_dir,
      path        => ['/usr/bin', '/bin', '/usr/local/bin'],
      environment => $environment,
      timeout     => 600, # installDeps takes a *long* time
      refreshonly => true,
      require     => Package['nodejs'],
    }
  }
}
