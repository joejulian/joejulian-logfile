define logfile::log (
  $target = $name,
  $debug  = undef,
  $discover_interval = 15,
  $exclude = undef,
  $format  = undef,
  $message_format = undef,
  $sincedb_path = undef,         # not implemented in beaver
  $sincedb_write_interval = 15,  #
  $stat_interval = 1,
  $tags = undef,
  $type,
  $ensure = undef,
  $owner = 'root',
  $group = 'root',
  $mode = '0600',
  $options = []
) {
  include ::logrotate
  $filename = sha1($name)

  file { $filename:
    path   => $target,
    owner  => $owner,
    group  => $group,
    mode   => $mode,
    ensure => $ensure,
  }
  if ($ensure != "absent") {
    logrotate::file { $filename:
      log     => $target,
      options => $options,
    }
  }
  # beaver is installed using pip which isnt' an option in older puppet versions
  # I skip this entirely with the expectation that your puppet rules will install
  # the newer version.
  if versioncmp($puppetversion, "3.1.0") > -1 {
    include beaver

    beaver::watch { $name:
      target                 => $target,
      debug                  => $debug,
      discover_interval      => $discover_interval,
      exclude                => $exclude,
      format                 => $format,
      message_format         => $message_format,
      sincedb_path           => $sincedb_path,
      sincedb_write_interval => $sincedb_write_interval,
      stat_interval          => $stat_interval,
      tags                   => $tags,
      type                   => $type,
      ensure                 => $ensure,
    }
  } else {
    warning("Beaver requires puppet version >= 3.1.0")
  }
}
