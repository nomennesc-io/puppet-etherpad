# Matches Pad Options Keys And Values
type Etherpad::Padoptions = Struct[
  {
    Optional['noColors']         => Boolean,
    Optional['showControls']     => Boolean,
    Optional['showLineNumbers']  => Boolean,
    Optional['useMonospaceFont'] => Boolean,
    Optional['userName']         => Variant[Undef,Boolean, String],
    Optional['userColor']        => Variant[Undef,Boolean, String],
    Optional['rtl']              => Boolean,
    Optional['alwaysShowChat']   => Boolean,
    Optional['chatAndUsers']     => Boolean,
    Optional['lang']             => String[1],
  }
]
