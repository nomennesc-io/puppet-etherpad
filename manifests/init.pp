# Class: etherpad
# ===============
#
# The etherpad module installs and configures etherpad.
# This class is the entry point for the module and the configuration point.
#
class etherpad (
  # General
  Etherpad::Ensure $ensure                   = 'present', # This should be a pattern, but right now that's too long
  String $service_name                       = 'etherpad',
  Enum['running', 'stopped'] $service_ensure = 'running', # again, should be an enum…
  # what if the fact doesn't exist (yet) or is b0rked? use Optional.
  Optional[String] $service_provider         = $facts['service_provider'],
  Boolean $manage_user                       = true,
  Boolean $manage_abiword                    = false,
  Stdlib::Absolutepath $abiword_path         = '/usr/bin/abiword',
  Boolean $manage_tidy                       = false,
  Stdlib::Absolutepath  $tidy_path           = '/usr/bin/tidy',
  String  $user                              = 'etherpad',
  String  $group                             = 'etherpad',
  Stdlib::Absolutepath $root_dir             = '/opt/etherpad',
  String  $source                            = 'https://github.com/ether/etherpad-lite.git',

  # Db
  Enum['dirty', 'mysql', 'sqlite', 'postgres'] $database_type = 'dirty',
  String $database_host                                       = 'localhost',
  String $database_user                                       = 'etherpad',
  String $database_name                                       = 'etherpad',
  String $database_password                                   = 'etherpad',

  # Network
  Optional[String] $ip = undef,
  Integer $port        = 9001,
  Boolean $trust_proxy = false,

  # Performance
  Integer $max_age = 21600,
  Boolean $minify  = true,

  # Config
  Etherpad::Ldapauth $ldapauth      = {},
  Etherpad::Buttonlink $button_link = {},
  Etherpad::Mypads $mypads          = {},
  String $skinName                  = 'colibiris',
  String $skinVariants              = 'dark-toolbar super-dark-background super-dark-editor full-width-editor',
  Boolean $require_session          = false,
  Boolean $edit_only                = false,
  Boolean $require_authentication   = false,
  Boolean $require_authorization    = false,
  Boolean $use_default_ldapauth     = true,
  Optional[String]  $pad_title      = undef,
  String $default_pad_text          = 'Welcome to etherpad!',

  # Users
  Optional[Hash] $users           = undef,
  String[1] $ep_local_admin_login = 'admin',
  String[1] $ep_local_admin_pwd   = fqdn_rand_string(8),

  # Ssl
  Enum['enable','disable'] $ssl  = 'disable',
  Stdlib::Absolutepath $ssl_key  = '/etc/ssl/epad/epl-server.key',
  Stdlib::Absolutepath $ssl_cert = '/etc/ssl/epad/epl-server.crt',

  # Logging
  Boolean $logconfig_file                        = false,
  Optional[String] $logconfig_file_filename      = undef,
  Optional[Integer] $logconfig_file_max_log_size = undef,
  Optional[Integer] $logconfig_file_backups      = undef,
  Optional[String] $logconfig_file_category      = undef,

  # Padoptions
  Etherpad::Padoptions $padoptions = {},

  # Plugins
  Hash[Pattern['ep_*'], Optional[Boolean]] $plugins_list = {},
) {
  $default_padoptions = {
    noColors         => false,
    showControls     => true,
    showChat         => true,
    showLineNumbers  => true,
    useMonospaceFont => false,
    userName         => false,
    userColor        => false,
    rtl              => false,
    alwaysShowChat   => false,
    chatAndUsers     => false,
    lang             => 'en-gb',
  }
  #Merged values provides by user and default values
  $_real_padoptions = merge($default_padoptions, $padoptions)

  #Install choosing plugins
  $plugins_list.each |$_pname, $_penable| {
    case $_penable {
      true: { contain "etherpad::plugins::${_pname}"
      }
      undef: { etherpad::plugins::common { $_pname: }
      }
      false: { etherpad::plugins::ucommon { $_pname: }
      }
      default: { fail("The plugin ${_pname} is not supported yet, please chek the plugin list.")
      }
    }
  }

  if $manage_user {
    contain 'etherpad::user'

    Class['etherpad::user']
    -> Class['etherpad::install']
  }

  contain 'etherpad::install'
  contain 'etherpad::config'
  contain 'etherpad::service'

  Class['etherpad::install']
  -> Class['etherpad::config']
  ~> Class['etherpad::service']

  Class['etherpad::install']
  ~> Class['etherpad::service']
}
