Tim is a minimalistic IRC bot with a focus on modularity and reliability.

### Configuration
The bot is configured by creating a file called `local.config.pm` in the
`include` folder.

### Modules
* Weather.pm - Obtains a short weather report from the Norwegian weather forecasting
  site Yr.no.
* AtB.pm - Obtains bus route information from the Norwegian bus service AtB.

### Dependencies:
* POE::Component::IRC
* POE::Component
* JSON::MaybeXS
* XML::Simple
* Schedule::Cron
* Test::More
* Devel::Cover
* Module::Refresh

These can also be obtained from the following debian packages:
* libpoe-component-irc-perl
* libpoe-perl
* libjson-maybexs-perl
* libxml-simple-perl
* libschedule-cron-perl
* libtest-simple-perl
* libdevel-cover-perl
* libmodule-refresh-perl
