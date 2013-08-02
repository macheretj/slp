#!/usr/bin/perl -w

@procs = `ps -e -o pid,user,comm | awk '{ print \$1","\$2","\$NF }'`;

$num_args = $#ARGV + 1;
if ($num_args != 2) {
  print "*** Wrong usage! Please specify \"process name\" as 1st arg and \"username\" as 2nd.\n";
  print "*** Exemple: strictproc.pl ssh-agent foobar\n";
  exit;
}


$procname = $ARGV[0];
$username = $ARGV[1];

chomp(@procs);

foreach $proc (@procs) {

@fields = split(/,/,$proc);

$user = $fields[1];
$comm = $fields[2];

        if ( $user eq $username && $comm eq $procname ) {

        print "Real agent: $proc\n";
        push(@realprocs, $proc);

        }




}

print @realprocs;
print "\n";
