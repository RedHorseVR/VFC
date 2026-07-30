#!/usr/bin/env perl
<<<<<<< HEAD
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

=======
#
# vfcfind.pl — Recursive VFC-aware file / text / filename scanner
#
# Features:
#   - Search file contents for a regex "search_key_expression"
#   - Filter which files are scanned via "filter_pattern"
#   - Optional folder include/exclude via "folder_filter"
#   - Special ".files" mode: filename-only search, VSCode-clickable output
#   - Optional "--save" to generate VSCode reference files under refs_vsc/
#
# Usage:
#   vfcfind.pl <filter_pattern> <search_key_expression> [folder_filter] [--save]
#
#   <filter_pattern>:
#     - ".vfc"          → scan files ending in ".vfc"
#     - ".cpp"          → scan files ending in ".cpp"
#     - ".h,.cpp"       → scan files ending in ".h" or ".cpp"
#     - "."             → scan all files
#     - ".files"        → special mode: search filenames only (see below)
#     - "*.files"       → same as ".files"
#     - "files"         → same as ".files"
#
#   <search_key_expression>:
#     - Perl regular expression used to match lines (or filenames in .files mode)
#     - Example: "WIC", "HAL", "MyFunc\\(", "^(?i)wic" etc.
#
#   [folder_filter]:
#     - Optional, treated as a Perl regular expression (no automatic /i)
#     - "src"          → only folders whose path matches /src/
#     - "!test"        → exclude folders whose path matches /test/
#     - "(?i)src"      → case-insensitive match, user-controlled
#
#   [--save]:
#     - When present, matching lines are recorded into refs_vsc/*.ref files
#       for VSCode "vfc" integration.
#
# Special ".files" mode:
#   - If <filter_pattern> is ".files", "*.files", or "files":
#       → Do NOT scan file contents
#       → Instead, search only filenames using <search_key_expression> as regex
#       → Output: "relative/path/to/file:1" (VSCode ctrl-click friendly)
#
# Notes:
#   - Case sensitivity is entirely controlled by your regexes.
#   - No automatic /i is added anywhere.
#

use strict;
use warnings;

use Cwd 'getcwd';
use File::Spec;
use File::Find;
use File::Basename;

# ------------------------------------------------------------
# DETECT REPO ROOT BY FINDING .git
# ------------------------------------------------------------
# We walk upward from the script's directory until we find a ".git" folder.
# This is used as the WORKSPACE ROOT for VSCode reference files.
sub find_repo_root {
    my $dir = File::Basename::dirname(File::Spec->rel2abs($0));

>>>>>>> ef460458fcba2bbea446d66ec2d11a4600e16d35
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
<<<<<<< HEAD
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
=======
# SETUP SCRIPT / REF DIRECTORIES
# ------------------------------------------------------------
my $SCRIPT_DIR = File::Basename::dirname(File::Spec->rel2abs($0));

# refs_vsc directory is always next to the script
my $REF_ROOT   = File::Spec->catdir($SCRIPT_DIR, 'refs_vsc');
mkdir $REF_ROOT unless -d $REF_ROOT;

# Track hits per ref file for summary
my %HITS_PER_FILE = ();

# Folder filter globals (regex strings, not compiled yet)
my $FOLDER_FILTER_STR  = "";
my $FOLDER_EXCLUDE_STR = "";

# Compiled regexes for folder filters (created later)
my $FOLDER_FILTER_RE   = undef;
my $FOLDER_EXCLUDE_RE  = undef;

# ------------------------------------------------------------
# COLOR PRINT (ANSI)
# ------------------------------------------------------------
# Uses standard ANSI escape codes. These work on:
#   - Linux/macOS terminals
#   - Windows Terminal / PowerShell with VT enabled
# They may not work on legacy Windows CMD.
sub cprint {
    my ($text, $color) = @_;
    my %colors = (
        red     => "\033[31m",
        green   => "\033[32m",
        yellow  => "\033[33m",
        blue    => "\033[34m",
        magenta => "\033[35m",
        cyan    => "\033[36m",
        white   => "\033[37m",
        reset   => "\033[0m"
    );
    my $c = $colors{$color} // $colors{reset};
    print $c . $text . $colors{reset} . "\n";
>>>>>>> ef460458fcba2bbea446d66ec2d11a4600e16d35
}

# ------------------------------------------------------------
# SAFE TERM FOR REF FILES
# ------------------------------------------------------------
<<<<<<< HEAD
=======
# Converts a path into a safe token for naming .ref files.
>>>>>>> ef460458fcba2bbea446d66ec2d11a4600e16d35
sub path_to_safe_term {
    my ($path) = @_;

    my $rel = File::Spec->abs2rel($path, $SCRIPT_DIR);

<<<<<<< HEAD
=======
    # Normalize separators and sanitize
>>>>>>> ef460458fcba2bbea446d66ec2d11a4600e16d35
    $rel =~ s!\\!/!g;
    $rel =~ s!/!_!g;
    $rel =~ s![^A-Za-z0-9._-]!_!g;
    $rel =~ s/_+/_/g;
    $rel =~ s/^_+//;
    $rel =~ s/_+$//;

    return $rel || "unnamed";
}

# ------------------------------------------------------------
<<<<<<< HEAD
# AUTO-CORRECT BAD PATTERNS
# ------------------------------------------------------------
=======
# AUTO-CORRECT BAD PATTERNS IN ARGV
# ------------------------------------------------------------
# This block normalizes some common user mistakes:
#   "*.*"      → "."
#   "*.ext"    → ".ext"
#   "*.h,*.c"  → ".h,.c"
>>>>>>> ef460458fcba2bbea446d66ec2d11a4600e16d35
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
<<<<<<< HEAD
# HANDLE --save FLAG (standalone)
# ------------------------------------------------------------
=======
# HANDLE --save FLAG (standalone argument)
# ------------------------------------------------------------
# We support:
#   vfcfind.pl .cpp WIC HAL --save
#   vfcfind.pl .cpp WIC --save
#   vfcfind.pl WIC --save
>>>>>>> ef460458fcba2bbea446d66ec2d11a4600e16d35
my $SAVE_MODE = 0;

for (my $i = 0; $i < @ARGV; $i++) {
    if ($ARGV[$i] eq "--save" || $ARGV[$i] eq "-save") {
        $SAVE_MODE = 1;
        splice(@ARGV, $i, 1);
        last;
    }
}

# ------------------------------------------------------------
<<<<<<< HEAD
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
=======
# HELP / USAGE
# ------------------------------------------------------------
if (@ARGV == 0) {
    print "\n==============================================================\n";
    print "  vfcfind.pl — Recursive VFC-aware file / text / filename scanner\n";
    print "==============================================================\n\n";
    print "Usage:\n";
    print "  vfcfind.pl <filter_pattern> <search_key_expression> [folder_filter] [--save]\n\n";
    print "Arguments:\n";
    print "  <filter_pattern>\n";
    print "    - \".vfc\"        → scan files ending in .vfc\n";
    print "    - \".cpp\"        → scan files ending in .cpp\n";
    print "    - \".h,.cpp\"     → scan files ending in .h or .cpp\n";
    print "    - \".\"           → scan all files\n";
    print "    - \".files\"      → filename-only search mode (see below)\n";
    print "    - \"*.files\"     → same as .files\n";
    print "    - \"files\"       → same as .files\n\n";
    print "  <search_key_expression>\n";
    print "    - Perl regular expression used to match lines (or filenames in .files mode)\n";
    print "    - Example: WIC, HAL, MyFunc\\(, ^(?i)wic, etc.\n\n";
    print "  [folder_filter]\n";
    print "    - Optional, treated as a Perl regular expression\n";
    print "    - \"src\"    → only scan folders whose path matches /src/\n";
    print "    - \"!test\"  → exclude folders whose path matches /test/\n";
    print "    - \"(?i)src\"→ case-insensitive match (user-controlled)\n\n";
    print "  [--save]\n";
    print "    - When present, matching lines are recorded into refs_vsc/*.ref\n";
    print "      for VSCode \"vfc\" integration.\n\n";
    print "Special .files mode:\n";
    print "  - If <filter_pattern> is .files, *.files, or files:\n";
    print "      * Do NOT scan file contents\n";
    print "      * Search only filenames using <search_key_expression> as regex\n";
    print "      * Output: relative/path/to/file:1 (VSCode ctrl-click friendly)\n\n";
>>>>>>> ef460458fcba2bbea446d66ec2d11a4600e16d35
    exit;
}

# ------------------------------------------------------------
<<<<<<< HEAD
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
=======
# ARGUMENT PARSING
# ------------------------------------------------------------
# We support:
#   vfcfind.pl <search_key_expression>
#       → filter_pattern defaults to .vfc
#
#   vfcfind.pl <filter_pattern> <search_key_expression>
#
#   vfcfind.pl <filter_pattern> <search_key_expression> <folder_filter>
#
my ($filter_pattern, $search_key_expression, $folder_filter);

if (@ARGV == 1) {
    $filter_pattern        = ".vfc";
    $search_key_expression = $ARGV[0];
    $folder_filter         = "";
}
elsif (@ARGV == 2) {
    $filter_pattern        = $ARGV[0];
    $search_key_expression = $ARGV[1];
    $folder_filter         = "";
}
else {
    $filter_pattern        = $ARGV[0];
    $search_key_expression = $ARGV[1];
    $folder_filter         = $ARGV[2];
}

# ------------------------------------------------------------
# HANDLE --save ATTACHED TO EITHER SEARCH KEY OR FOLDER FILTER
# ------------------------------------------------------------
# Examples:
#   vfcfind.pl .cpp WIC--save
#   vfcfind.pl .cpp WIC HAL--save
foreach my $ref (\$search_key_expression, \$folder_filter) {
    next unless defined $$ref;
>>>>>>> ef460458fcba2bbea446d66ec2d11a4600e16d35
    if ($$ref =~ s/(--save|-save)\s*$//) {
        $SAVE_MODE = 1;
        $$ref =~ s/\s+$//;
    }
}

# ------------------------------------------------------------
<<<<<<< HEAD
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

=======
# FOLDER FILTER LOGIC (REGEX, USER-CONTROLLED CASE)
# ------------------------------------------------------------
# folder_filter:
#   ""        → no filter
#   "src"     → include only folders matching /src/
#   "!test"   → exclude folders matching /test/
#   "(?i)src" → user-chosen case-insensitive include
if (defined $folder_filter && $folder_filter ne "") {
    if ($folder_filter =~ /^!(.+)/) {
        $FOLDER_EXCLUDE_STR = $1;
    } else {
        $FOLDER_FILTER_STR = $folder_filter;
    }
}

# Compile regexes if provided; any regex error is fatal.
if ($FOLDER_FILTER_STR ne "") {
    $FOLDER_FILTER_RE = eval { qr/$FOLDER_FILTER_STR/ };
    die "Invalid folder_filter regex: $FOLDER_FILTER_STR\n" if $@;
}
if ($FOLDER_EXCLUDE_STR ne "") {
    $FOLDER_EXCLUDE_RE = eval { qr/$FOLDER_EXCLUDE_STR/ };
    die "Invalid folder_filter exclusion regex: $FOLDER_EXCLUDE_STR\n" if $@;
}

# ------------------------------------------------------------
# SPECIAL .files MODE
# ------------------------------------------------------------
# .files / *.files / files → filename-only search
# In this mode:
#   - We do NOT open files
#   - We match $search_key_expression against the filename (not path)
#   - We print "relative/path/to/file:1"
my $FILES_MODE = 0;

if ($filter_pattern eq ".files"
    || $filter_pattern eq "*.files"
    || $filter_pattern eq "files")
{
    $FILES_MODE = 1;
}

# ------------------------------------------------------------
# BUILD EXTENSION LIST (NON .files MODE)
# ------------------------------------------------------------
# For non-.files mode, filter_pattern is treated as a list of extensions:
#   ".cpp"        → files ending in .cpp
#   ".h,.cpp"     → files ending in .h or .cpp
#   "."           → all files
my @EXTLIST = ();
if (!$FILES_MODE) {
    if ($filter_pattern =~ /,/) {
        @EXTLIST = split /,/, $filter_pattern;
    } else {
        @EXTLIST = ($filter_pattern);
    }
}

# ------------------------------------------------------------
# GLOBAL HIT COUNTERS
# ------------------------------------------------------------
my $HIT_TOTAL = 0;
my $cwd       = getcwd();

# ------------------------------------------------------------
# GetLines — scan a single file for matching lines
# ------------------------------------------------------------
# Parameters:
#   $filename           → path to file
#   $word_to_find       → regex (search_key_expression)
#
# Behavior:
#   - Strips ANSI and non-printable characters
#   - Skips non-ASCII lines
#   - Matches lines using /$word_to_find/
#   - Prints colored output
#   - Optionally appends VSCode reference data to .ref files when --save
>>>>>>> ef460458fcba2bbea446d66ec2d11a4600e16d35
sub GetLines {
    my ($filename, $word_to_find) = @_;

    open(my $fh, '<', $filename) or return 0;

<<<<<<< HEAD
    my $line = 0;
    my $found = 0;
    my $found_in_file = 0;
    my $VScodeData = "";
    my $flag = 0;

    while (my $row = <$fh>) {
        $row =~ s/\x1B[\(\)][0-9A-Za-z]*//g;
        $row =~ s/[^\x20-\x7E\r\n\t]//g;
=======
    my $line          = 0;
    my $found         = 0;
    my $found_in_file = 0;
    my $VScodeData    = "";
    my $flag          = 0;

    while (my $row = <$fh>) {
        # Strip ANSI escape sequences
        $row =~ s/\x1B[\(\)][0-9A-Za-z]*//g;
        # Remove non-printable except CR/LF/TAB
        $row =~ s/[^\x20-\x7E\r\n\t]//g;
        # Skip non-ASCII lines
>>>>>>> ef460458fcba2bbea446d66ec2d11a4600e16d35
        next if $row =~ /[^\x00-\x7F]/;

        $line++;
        chomp $row;

<<<<<<< HEAD
=======
        # Use the search_key_expression as a Perl regex
>>>>>>> ef460458fcba2bbea446d66ec2d11a4600e16d35
        if ($row =~ /$word_to_find/) {
            if ($flag == 0) {
                cprint("$filename ____________________________________________________________", 'yellow');
                $flag = 1;
            }

            $found++;
            $found_in_file++;

<<<<<<< HEAD
            cprint("\tvfc $cwd/$filename $line", 'cyan');

=======
            # vfc command line for VSCode integration
            cprint("\tvfc $cwd/$filename $line", 'cyan');

            # Build relative path from repo root for .ref file
>>>>>>> ef460458fcba2bbea446d66ec2d11a4600e16d35
            my $rel = File::Spec->abs2rel($filename, $REPO_ROOT);
            $rel =~ s!\\!/!g;

            $VScodeData .= "$rel:$line\n";
        }
    }

    close($fh);

<<<<<<< HEAD
=======
    # If we had hits in this file and --save is enabled, write .ref data
>>>>>>> ef460458fcba2bbea446d66ec2d11a4600e16d35
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
<<<<<<< HEAD
# PROCESS FILES IN A DIRECTORY
# ------------------------------------------------------------
sub process_files {
    my ($dir, $word) = @_;

=======
# process_files — scan all files in a directory (non-recursive)
# ------------------------------------------------------------
# Parameters:
#   $dir    → directory path
#   $word   → search_key_expression (regex)
#
# Behavior:
#   - In normal mode: filter by @EXTLIST and call GetLines
#   - In .files mode: ignore contents, match filenames only
sub process_files {
    my ($dir, $word) = @_;

    # Normalize "./" and "/./"
>>>>>>> ef460458fcba2bbea446d66ec2d11a4600e16d35
    $dir =~ s!^\./!!;
    $dir =~ s!/\.!/!g;

    opendir(my $dh, $dir) or return 0;

    my $total = 0;

    while (my $file = readdir($dh)) {
<<<<<<< HEAD
        next if $file =~ /^\./;

        my $match = 0;
        foreach my $ext (@EXTLIST) {
            $match = 1 if $ext eq "." || $file =~ /\Q$ext\E$/i;
        }
        next unless $match;
=======
        next if $file =~ /^\./;  # skip hidden and . / ..
>>>>>>> ef460458fcba2bbea446d66ec2d11a4600e16d35

        my $path = "$dir/$file";
        $path =~ s!/\.!/!g;

        next unless -f $path;

<<<<<<< HEAD
=======
        # .files mode: filename-only search
        if ($FILES_MODE) {
            # Match search_key_expression against the filename (not path)
            if ($file =~ /$word/) {
                # VSCode-friendly: relative path from repo root, line 1
                my $rel = File::Spec->abs2rel($path, $REPO_ROOT);
                $rel =~ s!\\!/!g;
                cprint("$rel:1", 'green');

                $HIT_TOTAL++;
            }
            next;
        }

        # Normal mode: extension-based filtering
        my $match = 0;
        foreach my $ext (@EXTLIST) {
            # "." means all files
            if ($ext eq ".") {
                $match = 1;
                last;
            }
            # Extension match at end of filename
            if ($file =~ /\Q$ext\E$/) {
                $match = 1;
                last;
            }
        }
        next unless $match;

>>>>>>> ef460458fcba2bbea446d66ec2d11a4600e16d35
        $total += GetLines($path, $word);
    }

    closedir($dh);
    return $total;
}

# ------------------------------------------------------------
# DIRECTORY WALK — FULL RECURSION
# ------------------------------------------------------------
<<<<<<< HEAD
=======
# We collect all directories under "." (repo root), then:
#   - Apply folder exclude regex (if any)
#   - Apply folder include regex (if any)
#   - Skip some hard-coded build dirs
#   - Call process_files() for each directory
>>>>>>> ef460458fcba2bbea446d66ec2d11a4600e16d35
my @dirs;

find(
    sub {
        return unless -d $_;

        my $d = $File::Find::name;
        return if $d eq ".";

        $d =~ s!^\./!!;
        $d =~ s!/\.!/!g;

<<<<<<< HEAD
=======
        # Hard-coded exclusions
>>>>>>> ef460458fcba2bbea446d66ec2d11a4600e16d35
        return if $d =~ /build/;
        return if $d =~ /CMakeFiles/;

        push @dirs, $d;
    },
    '.'
);

my $TotalLines = 0;

<<<<<<< HEAD
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
=======
# Process current directory first
$TotalLines += process_files(".", $search_key_expression);

# Process all discovered directories
foreach my $d (@dirs) {

    # Additional hard-coded exclusions
    next if $d =~ /BackupVFC/;
    next if $d =~ /BSP_/;

    # Apply folder exclude regex if defined
    if (defined $FOLDER_EXCLUDE_RE) {
        next if $d =~ $FOLDER_EXCLUDE_RE;
    }

    # Apply folder include regex if defined
    if (defined $FOLDER_FILTER_RE) {
        next unless $d =~ $FOLDER_FILTER_RE;
    }

    $TotalLines += process_files($d, $search_key_expression);
>>>>>>> ef460458fcba2bbea446d66ec2d11a4600e16d35
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
<<<<<<< HEAD
    print "\nNO HITS FOUND FOR SEARCH KEY: $word\n";
}

print "\nHITS: $HIT_TOTAL\n";
print "SEARCH KEY: $word\n";
=======
    print "\nNO HITS FOUND FOR SEARCH KEY: $search_key_expression\n";
}

print "\nHITS: $HIT_TOTAL\n";
print "SEARCH KEY: $search_key_expression\n";
>>>>>>> ef460458fcba2bbea446d66ec2d11a4600e16d35
print "REF FILES: $ref_count\n";
print "REF DIRECTORY: $REF_ROOT\n";
print "WORKSPACE ROOT: $REPO_ROOT\n";
print "==============================================================\n";
<<<<<<< HEAD
=======

exit 0;
>>>>>>> ef460458fcba2bbea446d66ec2d11a4600e16d35
