#!/usr/bin/perl
# Mechanical regex-scan engine (perl 5.14+; JSON::PP is core since 5.14). One
# of the four catalog engines. Parses ../references/regex-scan.md at run time
# and never duplicates patterns into code. Catalog patterns need one
# conversion: \uXXXX -> \x{XXXX} (perl reads \u as a titlecase modifier, so the
# raw JS flavor silently changes meaning). Lone $ in a pattern is JS
# end-anchor semantics; the engine converts $ to \z (which also neutralizes
# the $) interpolation hazard).
#
# Contract (identical across engines): engine [file|-] [--json]
# Exit: 0 within gate; 1 gate violation; 2 usage or catalog parse error.
#
# Run: perl scan.pl input.txt
#      cat input.txt | perl scan.pl --json
use strict;
use warnings;
use utf8;
use JSON::PP;

use FindBin;
use File::Spec;
my $catalog = $ENV{SCAN_CATALOG}
    || File::Spec->catfile($FindBin::Bin, '..', '..', 'references', 'regex-scan.md');

sub die2 {
    my ($msg) = @_;
    print STDERR "scan: $msg\n";
    exit 2;
}

open(my $mdh, '<:encoding(UTF-8)', $catalog) or die2("catalog not found: $catalog");
my $md = do { local $/; <$mdh> };
close $mdh;

my @entries;
my $parse_error;
{
    my ($sev, $title, $buf) = (undef, undef);
    my $flush = sub {
        my $t = $title;
        return 0 unless defined $t;
        if (defined $buf) {
            push @entries, { title => $t, sev => $sev, kind => 'regex', source => join("\n", @$buf) };
        } elsif ($sev eq 'LIMIT' || $sev eq 'SOFT') {
            push @entries, { title => $t, sev => $sev, kind => 'judgment' };
        } elsif ($sev eq 'HARD' && index($t, 'Em dash') >= 0) {
            push @entries, { title => $t, sev => $sev, kind => 'literal' };
        } else {
            $parse_error = sprintf('HARD section without a fence: "%s"', $t);
        }
        $title = undef; $buf = undef;
        return 1;
    };

    for my $raw (split /\n/, $md) {
        if ($raw =~ /^## (HARD|LIMIT|SOFT) patterns\s*$/) {
            $flush->();
            die2("catalog parse error: $parse_error") if defined $parse_error;
            $sev = $1;
            next;
        }
        if ($raw =~ /^### (.+)$/) {
            $flush->();
            die2("catalog parse error: $parse_error") if defined $parse_error;
            $title = $1;
            $title =~ s/\s+$//;
            next;
        }
        if (defined $title) {
            if ($raw =~ /^```/) {
                if (defined $buf) {
                    push @entries, { title => $title, sev => $sev, kind => 'regex', source => join("\n", @$buf) };
                    $title = undef; $buf = undef;
                } else {
                    $buf = [];
                }
                next;
            }
            if (defined $buf) { push @$buf, $raw; next; }
            next;  # prose before an opening fence
        }
    }
    $flush->();
}
die2("catalog parse error: $parse_error") if defined $parse_error;
die2('catalog parse error: no pattern sections found') unless @entries;

for my $e (@entries) {
    (my $disp = $e->{title}) =~ s/ — .*//;
    $e->{name} = $disp;
    if ($e->{sev} eq 'LIMIT' && $e->{title} =~ /LIMIT (\d+)/) {
        $e->{max} = $1 + 0;
    } else {
        $e->{max} = undef;
    }
}

# ------------------------------------------------------------------ args ---#
my ($json_mode, $file_arg, $saw) = (0, undef, 0);
for my $a (@ARGV) {
    if ($a eq '--json') { $json_mode = 1; }
    elsif ($a eq '-') { die2('multiple input files') if $saw; ($file_arg, $saw) = ('-', 1); }
    elsif ($a =~ /^--/) { die2("unknown option: $a"); }
    else { die2('multiple input files') if $saw; ($file_arg, $saw) = ($a, 1); }
}

my $text;
if (!defined $file_arg || $file_arg eq '-') {
    die2('no input file and stdin is a terminal (usage: engine [file|-] [--json])') if -t STDIN;
    binmode(STDIN, ':encoding(UTF-8)');
    $text = do { local $/; <STDIN> };
} else {
    open(my $inh, '<:encoding(UTF-8)', $file_arg) or die2("cannot read input: $file_arg: $!");
    $text = do { local $/; <$inh> };
    close $inh;
}
$text = '' unless defined $text;

# ------------------------------------------------------------------ scan ---#
my @line_starts = (0);
while ($text =~ /\n/g) { push @line_starts, pos($text); }
pos($text) = 0;

sub lc_of {
    my ($idx) = @_;
    my ($lo, $hi) = (0, $#line_starts);
    while ($lo < $hi) {
        my $mid = int(($lo + $hi + 1) / 2);
        if ($line_starts[$mid] <= $idx) { $lo = $mid; } else { $hi = $mid - 1; }
    }
    return { line => $lo + 1, col => $idx - $line_starts[$lo] + 1 };
}

sub clip {
    my ($s) = @_;
    $s =~ s/\n/⏎/g;
    return length($s) > 64 ? substr($s, 0, 61) . '...' : $s;
}

# Scan one pattern against $text; returns list of [start, end, matchtext].
sub scan_re {
    my ($p) = @_;
    $p =~ s{(\\u)([0-9A-Fa-f]{4})}{\\x{$2}}g;
    $p =~ s{\$}{\\z}g;   # JS $ == \z in perl; also kills $) interpolation
    my $re = eval { qr/$p/i };
    unless (defined $re) {
        my $err = $@ // 'compilation failed';
        $err =~ s/\s+at \(eval.*//s;
        die2(sprintf('catalog parse error: pattern "%s" does not compile: %s', $::e_name, $err));
    }
    my @hits;
    my $pos = 0;
    while (1) {
        pos($text) = $pos;
        last unless $text =~ /$re/g;
        my ($s, $e) = ($-[0], $+[0]);
        push @hits, [$s, $e, substr($text, $s, $e - $s)];
        $pos = ($e > $s) ? $e : $s + 1;
        last if $pos > length($text);
    }
    return @hits;
}

binmode(STDOUT, ':encoding(UTF-8)');

my @results;
my $violation = 0;
for my $e (@entries) {
    our $e_name = $e->{name};
    if ($e->{kind} eq 'judgment') {
        push @results, { name => $e->{name}, severity => $e->{sev}, count => undef, judged => 1, spans => [] };
        next;
    }
    my @hits;
    if ($e->{kind} eq 'literal') {
        my $pos = 0;
        while (1) {
            pos($text) = $pos;
            last unless $text =~ /(—|--)/g;
            push @hits, [$-[0], $+[0], $1];
            $pos = ($+[0] > $-[0]) ? $+[0] : $-[0] + 1;
            last if $pos > length($text);
        }
    } else {
        @hits = scan_re($e->{source});
    }
    my @spans;
    for my $h (@hits) {
        push @spans, {
            start => lc_of($h->[0]),
            end   => lc_of($h->[1]),
            text  => clip($h->[2]),
        };
    }
    my $n = scalar @hits;
    push @results, { name => $e->{name}, severity => $e->{sev}, count => $n, judged => 0, spans => \@spans };
    $violation = 1 if $e->{sev} eq 'HARD' && $n > 0;
    $violation = 1 if $e->{sev} eq 'LIMIT' && defined $e->{max} && $n > $e->{max};
}

# --------------------------------------------------------------- output ---#
my $width = 0;
for my $r (@results) { $width = length($r->{name}) if length($r->{name}) > $width; }
my $out = '';
for my $r (@results) {
    my $label = $r->{judged}
        ? 'JUDGMENT REQUIRED'
        : sprintf('%d %s', $r->{count}, $r->{count} == 1 ? 'hit' : 'hits');
    $out .= sprintf("%s  %-*s  %s\n", $r->{severity}, $width, $r->{name}, $label);
    for my $s (@{ $r->{spans} }) {
        $out .= sprintf('  L%d col%d-L%d col%d  "%s"' . "\n",
            $s->{start}{line}, $s->{start}{col}, $s->{end}{line}, $s->{end}{col}, $s->{text});
    }
}
if ($json_mode) {
    JSON::PP->new->canonical(1)->encode(\@results);  # sanity: serializes
    my $json = JSON::PP->new->canonical(1)->encode(\@results);
    print $json, "\n";
} else {
    print $out;
}

exit($violation ? 1 : 0);