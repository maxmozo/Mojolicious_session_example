#!/usr/bin/perl -w
#
# take_snapshot.pl - copies files from the app directory to a named directory
# Boyd Duffee, Aug 2017
#
# bug: copies .swp files to Snapshot, need to stop editing before taking snapshot

use strict;
use v5.010;
use File::Copy::Recursive qw/dircopy/;

if (my $files = `find . -name "*.swp"`) {
	die "Stop editing files before taking a snapshot\n", $files;
}

my $name = ucfirst shift;
die "Usage: $0 <name>\n" unless $name;

my $archive_dir = 'Snapshots';
mkdir $archive_dir unless -d $archive_dir;

my $directory = "$archive_dir/$name";
die "$name already exists in $archive_dir\n" if -e "$directory";
mkdir $directory;

my $working_copy = 'session_tutorial';
dircopy($working_copy, $directory) or die "Couldn't copy $working_copy to $directory: $!\n";
unlink("$archive_dir/$name/ldap_config.yml");	# breaks the symlink
system("rm $archive_dir/$name/log/*.log");	# remove log files

say "Files copied to $directory";
exit;
