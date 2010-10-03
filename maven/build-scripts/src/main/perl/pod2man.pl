#! /usr/bin/perl -w

use strict;
use warnings;
use File::Path qw(mkpath);
use File::Find ();
use Pod::Man;

# for the convenience of &wanted calls, including -eval statements:
use vars qw/*name *dir *prune/;
*name   = *File::Find::name;
*dir    = *File::Find::dir;
*prune  = *File::Find::prune;

sub wanted;

our $release = shift || die "must supply release number\n";

# Traverse desired filesystems
File::Find::find({wanted => \&wanted, no_chdir => 1}, 'target/lib/perl');

exit;

sub extract_module_name {
    my ($name) = @_;

    my $pkg_name = undef;

    open(my $fh, '<', $name) || die "error opening $name: $!\n";

    while (<$fh>) {
        if (/package\s+(.*?)\s*;/sx) {
            $pkg_name = $1;
            last;
        }
    }

    close($fh) || die "error closing $name: $!\n";

    if (!defined($pkg_name)) {
        die "package not found for module $name\n";
    }

    return $pkg_name;
}


sub extract_pod_name {
    my ($name) = @_;

    $name =~ s!\.pm!\.pod!gx;
    $name =~ s!/lib/perl/!/doc/pod/!x;

    return $name;
}


sub create_man_page {
    my ($pod_fname, $module_name, $section) = @_;

    my $parser = Pod::Man->new(release => $release, section => $section);

    my $odir = "target/doc/man/man$section";
    mkpath($odir);

    my $ofile = "$odir/$module_name.8";
    my $gzfile = "$ofile.gz";

    $parser->parse_from_file($pod_fname, $ofile);

    `gzip $ofile`;

    return;
}


sub process_perl_module {
    my ($name) = @_;

    print "Generating man page from $name\n";
    
    my $module_name = extract_module_name($name);
    my $pod_name = extract_pod_name($name);
    create_man_page($pod_name, $module_name, 8);

    return;
}


sub wanted {
    /^.*\.pm\z/sx && process_perl_module($name);
    return;
}

