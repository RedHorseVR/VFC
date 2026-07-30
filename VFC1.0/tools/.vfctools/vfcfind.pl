#!/usr/bin/env perl
use strict;
use warnings;

use Cwd 'getcwd';
use File::Spec;
use File::Find;
use File::Basename;

# ------------------------------------------------------------
# DETECT REPO ROOT BY FINDING .git
# ------------------------------------------------------------
sub find_repo_root {
    my $dir = File::Basename::dirname(File::Spec->rel2abs($0));

    while (1) {
        return $dir if -d File::Spec->catdir($dir, ".git");

        my $parent = File::Basename::dirname($dir);
        last if $parent eq $dir;
        $dir = $parent;
    }

    die "ERROR: Could not locate .git directory above script path.\n";
}

my $REPO_ROOT = find_repo_root();

# ------------------------------------------------------------
# FORCE refs_vsc TO SCRIPT DIRECTORY
# ------------------------------------------------------------
my $SCRIPT_DIR = File::Basename::dirname(File::Spec->rel2abs($0));
my $REF_ROOT   = File::Spec->catdir($SCRIPT_DIR, 'refs_vsc');
mkdir $REF_ROOT unless -d $REF_ROOT;

# Track hits per file for summary
my %HITS_PER_FILE = ();

# Folder filter globals
my $FOLDER_FILTER  = "";
my $FOLDER_EXCLUDE = "";

# ------------------------------------------------------------
# COLOR PRINT
# ------------------------------------------------------------
sub cprint {
    my ($text, $color) = @_;
    my %colors = (
        red     => "\e[31m",
        green   => "\e[32m",
        yellow  => "\e[33m",
        blue    => "\e[34m",
        magenta => "\e[35m",
        cyan    => "\e[36m",
        white   => "\e[37m",
        reset   => "\e[0m"
    );
    print $colors{$color} . $text . $colors{reset} . "\n";
}

# ------------------------------------------------------------
# SAFE TERM FOR REF FILES
# ------------------------------------------------------------
sub path_to_safe_term {
    my ($path) = @_;

    my $rel = File::Spec->abs2rel($path, $SCRIPT_DIR);

    $rel =~ s!\\!/!g;
    $rel =~ s!/!_!g;
    $rel =~ s![^A-Za-z0-9._-]!_!g;
    $rel =~ s/_+/_/g;
    $rel =~ s/^_+//;
    $rel =~ s/_+$//;

    return $rel || "unnamed";
}

# ------------------------------------------------------------
# AUTO-CORRECT BAD PATTERNS
# ------------------------------------------------------------
my @clean;
foreach my $arg (@ARGV) {

    if ($arg eq "*.*") {
        print "[AutoCorrect] '*.*' → '.' (scan all files)\n";
        push @clean, ".";
        next;
    }

    if ($arg =~ /^\*\.(\w+)$/) {
        print "[AutoCorrect] '$arg' → '.$1'\n";
        push @clean, ".$1";
        next;
    }

    if ($arg =~ /,/) {
        my @parts = split /,/, $arg;
        my @fixed;
        foreach my $p (@parts) {
            if ($p =~ /^\*\.(\w+)$/) {
                push @fixed, ".$1";
            } elsif ($p =~ /^\.(\w+)$/) {
                push @fixed, $p;
            }
        }
        if (@fixed) {
            print "[AutoCorrect] '$arg' → '" . join(",", @fixed) . "'\n";
            push @clean, join(",", @fixed);
            next;
        }
    }

    push @clean, $arg;
}
@ARGV = @clean;

# ------------------------------------------------------------
# HANDLE --save FLAG (standalone)
# ------------------------------------------------------------
my $SAVE_MODE = 0;

for (my $i = 0; $i < @ARGV; $i++) {
    if ($ARGV[$i] eq "--save" || $ARGV[$i] eq "-save") {
        $SAVE_MODE = 1;
        splice(@ARGV, $i, 1);
        last;
    }
}

# ------------------------------------------------------------
# HELP
# ------------------------------------------------------------
if (@ARGV == 0) {
    print "\n==============================================================\n";
    print "  vfcfind.pl — Recursive VFC-aware file scanner\n";
    print "==============================================================\n\n";
    print "Usage:\n";
    print "  vfcfind.pl <pattern> <linekey> [folderkey] [--save]\n\n";
    print "Examples:\n";
    print "  vfcfind.pl .cpp WIC\n";
    print "  vfcfind.pl .cpp WIC HAL\n";
    print "  vfcfind.pl .cpp WIC !HAL\n";
    print "  vfcfind.pl .cpp WIC HAL --save\n";
    print "  vfcfind.pl .cpp WIC--save\n";
    print "  vfcfind.pl .cpp WIC HAL--save\n\n";
    print "Folder Filter:\n";
    print "  <folderkey>   → only scan folders containing this substring\n";
    print "  !<folderkey>  → exclude folders containing this substring\n";
    print "  (none)        → scan all folders\n\n";
    exit;
}

# ------------------------------------------------------------
# ARGUMENT PARSING (supports optional folder filter)
# ------------------------------------------------------------
my ($pattern, $word, $folderkey);

if (@ARGV == 1) {
    $pattern   = ".vfc";
    $word      = $ARGV[0];
    $folderkey = "";
}
elsif (@ARGV == 2) {
    $pattern   = $ARGV[0];
    $word      = $ARGV[1];
    $folderkey = "";
}
else {
    $pattern   = $ARGV[0];
    $word      = $ARGV[1];
    $folderkey = $ARGV[2];
}

# ------------------------------------------------------------
# HANDLE --save ATTACHED TO EITHER WORD OR FOLDERKEY
# ------------------------------------------------------------
foreach my $ref (\$word, \$folderkey) {
    if ($$ref =~ s/(--save|-save)\s*$//) {
        $SAVE_MODE = 1;
        $$ref =~ s/\s+$//;
    }
}

# ------------------------------------------------------------
# FOLDER FILTER LOGIC
# ------------------------------------------------------------
if ($folderkey =~ /^!(.+)/) {
    $FOLDER_EXCLUDE = lc($1);
} else {
    $FOLDER_FILTER = lc($folderkey) if $folderkey ne "";
}

# ------------------------------------------------------------
# BUILD EXTENSION LIST
# ------------------------------------------------------------
my @EXTLIST = ();
if ($pattern =~ /,/) {
    @EXTLIST = split /,/, $pattern;
} else {
    @EXTLIST = ($pattern);
}

# ------------------------------------------------------------
# SEARCH FUNCTION
# ------------------------------------------------------------
my $HIT_TOTAL = 0;
my $cwd = getcwd();

sub GetLines {
    my ($filename, $word_to_find) = @_;

    open(my $fh, '<', $filename) or return 0;

    my $line = 0;
    my $found = 0;
    my $found_in_file = 0;
    my $VScodeData = "";
    my $flag = 0;

    while (my $row = <$fh>) {
        $row =~ s/\x1B[\(\)][0-9A-Za-z]*//g;
        $row =~ s/[^\x20-\x7E\r\n\t]//g;
        next if $row =~ /[^\x00-\x7F]/;

        $line++;
        chomp $row;

        if ($row =~ /$word_to_find/) {
            if ($flag == 0) {
                cprint("$filename ____________________________________________________________", 'yellow');
                $flag = 1;
            }

            $found++;
            $found_in_file++;

            cprint("\tvfc $cwd/$filename $line", 'cyan');

            my $rel = File::Spec->abs2rel($filename, $REPO_ROOT);
            $rel =~ s!\\!/!g;

            $VScodeData .= "$rel:$line\n";
        }
    }

    close($fh);

    if ($found_in_file && $SAVE_MODE) {

        my $search_term = $word_to_find;
        $search_term =~ s/[\\\/:*?"<>|]+/_/g;

        my $term = path_to_safe_term($filename);

        my $ref = "$REF_ROOT/vsc_${search_term}-${term}.ref";

        my $newfile = ! -f $ref;

        open my $fh2, '>>', $ref or die "Cannot open $ref: $!";

        if ($newfile) {
            print $fh2 "WORKSPACE ROOT: $REPO_ROOT\n";
            print $fh2 "REFERENCES FOR $word_to_find\n\n";
        }

        print $fh2 $VScodeData;
        close $fh2;

        $HITS_PER_FILE{$ref} += $found_in_file;
    }

    $HIT_TOTAL += $found;
    return $line;
}

# ------------------------------------------------------------
# PROCESS FILES IN A DIRECTORY
# ------------------------------------------------------------
sub process_files {
    my ($dir, $word) = @_;

    $dir =~ s!^\./!!;
    $dir =~ s!/\.!/!g;

    opendir(my $dh, $dir) or return 0;

    my $total = 0;

    while (my $file = readdir($dh)) {
        next if $file =~ /^\./;

        my $match = 0;
        foreach my $ext (@EXTLIST) {
            $match = 1 if $ext eq "." || $file =~ /\Q$ext\E$/i;
        }
        next unless $match;

        my $path = "$dir/$file";
        $path =~ s!/\.!/!g;

        next unless -f $path;

        $total += GetLines($path, $word);
    }

    closedir($dh);
    return $total;
}

# ------------------------------------------------------------
# DIRECTORY WALK — FULL RECURSION
# ------------------------------------------------------------
my @dirs;

find(
    sub {
        return unless -d $_;

        my $d = $File::Find::name;
        return if $d eq ".";

        $d =~ s!^\./!!;
        $d =~ s!/\.!/!g;

        return if $d =~ /build/;
        return if $d =~ /CMakeFiles/;

        push @dirs, $d;
    },
    '.'
);

my $TotalLines = 0;

$TotalLines += process_files(".", $word);

foreach my $d (@dirs) {

    next if $d =~ /BackupVFC/;
    next if $d =~ /BSP_/;

    my $ld = lc($d);

    if ($FOLDER_EXCLUDE ne "") {
        next if index($ld, $FOLDER_EXCLUDE) >= 0;
    }

    if ($FOLDER_FILTER ne "") {
        next unless index($ld, $FOLDER_FILTER) >= 0;
    }

    $TotalLines += process_files($d, $word);
}

# ------------------------------------------------------------
# FINAL SUMMARY
# ------------------------------------------------------------
print "\n==============================================================\n";
print "FILES:\n";

my $ref_count = 0;

foreach my $ref (sort keys %HITS_PER_FILE) {
    my $hits = $HITS_PER_FILE{$ref};
    my $name = basename($ref);
    print "  $name   ($hits hits)\n";
    $ref_count++;
}

if ($HIT_TOTAL == 0) {
    print "\nNO HITS FOUND FOR SEARCH KEY: $word\n";
}

print "\nHITS: $HIT_TOTAL\n";
print "SEARCH KEY: $word\n";
print "REF FILES: $ref_count\n";
print "REF DIRECTORY: $REF_ROOT\n";
print "WORKSPACE ROOT: $REPO_ROOT\n";
print "==============================================================\n";
