

# define database
use Rex::Commands::DB {
                        dsn => "DBI:mysql:database=stashy;host=localhost",
                        user => "stashy",
                        password => "stashy",
                     };

# define user and password / keys
user "root";

# define servers to inventor
group "inventory" => "dbuild01", "ctest64", "mango";

use Data::Dumper;
use Rex::Commands::Inventory;
use Rex::Commands::Gather;
use Rex::Hardware;
use Rex::Hardware::Host;
use Stashy::Commons;

use strict;
use warnings;

task "inventor", group => "inventory", sub {

   my $inventory = inventor;
   my $host_info = $inventory->{"configuration"}->{"host"};

   my $osrelease = Rex::Hardware::Host->get_operating_system_version();

   my @s = db select => {
               fields => "id",
               from   => "systems",
               where  => "hostname='" . $host_info->{"name"} . "' AND domainname='" . $host_info->{"domain"} . "'"
            };
   my $in_db = @s?1:0;


   if(! $in_db) {

      db insert => "systems", {
                        hostname => $host_info->{"name"},
                        domainname => $host_info->{"domain"},
                        added => datetime(),
                        os => get_operating_system(),
                        osrelease => $osrelease,
                        product_name => $inventory->{"system_info"}->{"product_name"},
                     }; 
                     
      my @sys = db select => {
               fields => "id",
               from   => "systems",
               where  => "hostname='" . $host_info->{"name"} . "' AND domainname='" . $host_info->{"domain"} . "'"
            };

      my $system_id = $sys[0]->{"id"};
      my $base_board = $inventory->{"base_board"};

      db insert => "baseboard", {
                        systems_id => $system_id,
                        serialnumber => $base_board->{"serialnumber"} || "",
                        manufacturer => $base_board->{"manufacturer"} || "",
                        product_name => $base_board->{"product_name"} || "",
                     };

     my $cpus = $inventory->{"cpus"};
     for my $cpu (@{$cpus}) {
        my ($speed) = ($cpu->{"max_speed"} =~ m/^(\d+)/);
        db insert => "cpus", {
                        systems_id => $system_id,
                        family => $cpu->{"family"} || "",
                        speed  => $speed || 0,
                     };
     }

     my $dimms = $inventory->{"dimms"};
     for my $dimm (@{$dimms}) {
        my ($speed) = ($dimm->{"speed"} =~ m/^(\d+)/);
        my ($size)  = ($dimm->{"size"} =~ m/^(\d+)/);
        db insert => "dimms", {
                        systems_id => $system_id,
                        serial_number => $dimm->{"serial_number"},
                        locator => $dimm->{"locator"},
                        size => $dimm->{"size"},
                        part_number => $dimm->{"part_number"},
                        speed => $dimm->{"speed"},
                        type => $dimm->{"type"},
                        form_factor => $dimm->{"form_factor"},
                     };
     }

     my $eths = $inventory->{"net"};
     for my $eth (@{$eths}) {
      db insert => "network_devices", {
                        systems_id => $system_id,
                        dev => $eth->{"dev"},
                        product => $eth->{"product"},
                        mac => $eth->{"mac"},
                        vendor => $eth->{"vendor"},
                     };

        my @dev = db select => {
                           fields => "id",
                           from => "network_devices",
                           where => "dev='" . $eth->{"dev"} . "' AND systems_id=$system_id AND mac='" . $eth->{"mac"} . "'",
                        };

       my $eth_id = $dev[0]->{"id"};

       my $net_conf = $inventory->{"configuration"}->{"network"}->{"current_configuration"}->{$eth->{"dev"}};
       if($net_conf) {
         db insert => "network_device_configuration", {
                                 eth_id => $eth_id,
                                 ip => $net_conf->{"ip"},
                                 netmask => $net_conf->{"netmask"},
                                 broadcast => $net_conf->{"broadcast"},
                              };
       }

    }
       
   }

};
