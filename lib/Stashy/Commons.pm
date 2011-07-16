#
# (c) Jan Gehring <jan.gehring@gmail.com>
# 
# vim: set ts=3 sw=3 tw=0:
# vim: set expandtab:
   
package Stashy::Commons;
   
use strict;
use warnings;
   
require Exporter;
use base qw(Exporter);
use vars qw(@EXPORT);
    
@EXPORT = qw(datetime);
   
sub datetime {
   my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
   $year += 1900;
   ++$mon;
   $mon  = sprintf("%02i", $mon);
   $mday = sprintf("%02i", $mday);

   return "$year-$mon-$mday $hour:$min:$sec";
}
   
1;
