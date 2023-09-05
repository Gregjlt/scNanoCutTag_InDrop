#!/usr/bin/perl

# usage: thisscript linenumberslist.txt contentsfile.gz

unless (open(IN, $ARGV[0])) {
    die "Can't open list of line numbers file '$ARGV[0]': $!\n"; # Redirige les erreurs vers STDERR
}
my %linenumbers = ();
while (<IN>) {
    chomp;
    $linenumbers{$_} = 1;
}

# Utilisez zcat ou gzip -dc pour décompresser le fichier de contenu
open(IN, '-|', 'zcat', $ARGV[1]) or die "Can't open compressed contents file '$ARGV[1]': $!\n"; # Redirige les erreurs vers STDERR

$. = 0;
while (<IN>) {
    print if defined $linenumbers{$.};
}

exit;