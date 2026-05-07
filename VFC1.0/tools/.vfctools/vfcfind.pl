use Cwd 'getcwd';# ////
use File::Spec;# ////
use File::Find;#// //////
use File::Basename;# ////
use File::Find::Rule;# ////
$HIT_TOTAL = 0;
my $cwd = getcwd();# ////

my $ps;#// //////
sub start_powershell {# ////
	return if $ps;# ////
# // Open a persistent PowerShell process//
open($ps, '|-', 'powershell -Command -') or die "Can't start PowerShell: $!";# ////
select((select($ps), $| = 1)[0]);# // Autoflush to make output instant//
}#// //////
sub cprint {# ////
	my ($text, $color) = @_;# ////
	# // Escape any single quotes in the text to prevent PowerShell issues //
	start_powershell();# // Ensure PowerShell is running//
	# // Escape any single quotes//
	$text =~ s/'/'\''/g;# ////
	#// // Send the command to PowerShell////
	print $ps "Write-Host '$text' -ForegroundColor $color\n";# ////
	} 
sub path_to_safe_term {# ////
	my ($path) = @_;# ////
	# // 1. Get current working directory //
	my $cwd = getcwd();# ////
	# // 2. Convert to relative path //
	my $rel = File::Spec->abs2rel($path, $cwd);# ////
	# // 3. Normalize slashes //
	$rel =~ s!\\!/!g;# ////
	# // 4. Replace path separators with underscores //
	$rel =~ s!/!_!g;# ////
	# // 5. Remove anything unsafe for filenames //
	$rel =~ s![^A-Za-z0-9._-]!_!g;# ////
	# // 6. Collapse multiple underscores //
	$rel =~ s/_+/_/g;# ////
	# // 7. Trim leading/trailing underscores //
	$rel =~ s/^_+//;# ////
	$rel =~ s/_+$//;# ////
	# // 8. Guarantee non-empty //
	return $rel || "unnamed";# ////
}# ////
$default = "\e[0m" ;#resets to default color
my $reset     = "\e[0m";# ////
my $bold      = "\e[1m";# ////
my $black     = "\e[30m";# ////
my $red       = "\e[31m";# ////
my $green     = "\e[32m";# ////
my $yellow    = "\e[33m";# ////
my $blue      = "\e[34m";# ////
my $magenta   = "\e[35m";# ////
my $cyan      = "\e[36m";# ////
my $white     = "\e[37m";# ////
# // Bright variants//
my $bright_red     = "\e[1;31m";# ////
my $bright_green   = "\e[1;32m";# ////
my $bright_yellow  = "\e[1;33m";# ////
my $bright_blue    = "\e[1;34m";# ////
sub GetLines{ local ( $filename , $word_to_find  , $type ) = @_;
	my $line_number = 0;# ////
	$found = 0;
	$found_in_file = 0;
	$VScodeData = "" ;
	$NPPcodeData = "" ;
	#print( "\nScanning _____ $word_to_find ____________  $type :: in file $filename\n" );
	open(my $fh, '<', $filename) or die "\n\t*********************** Could not open file '$filename' $!";# ////
	$VFCtoken = "^(generic|variable|input|event|process|set|output|loop|lend|branch|path|bend|end)" ;
	while (my $row = <$fh>) {# ////
		# // Remove ANSI escape sequences //
		$row =~ s/\x1B[\(\)][0-9A-Za-z]*//g;#  # Extra escape variations
		$row =~ s/[^\x20-\x7E\r\n\t]//g;# // Removes non-printable, keeps tabs/newlines//
		if ($row =~ /[^\x00-\x7F]/   || $row =~ m/\x/ )#if ($row[$i] !~ /^[\x01-\x7F]*$/)
		{
			next ;#// //////
			
		} else {
			}
		$line_number++;# ////
		if(  $EXTEN =~ m/vfc/i  ) { $row =~ s/$VFCtoken// } ;#<---- CLEANS THE TOKEN FOR vfc FILE ONLY 
		#$tok = $& ;
		#$row =~ s/;\/\/.*// ;
		$row =~ s/\n// ;
		if($row =~ m/$word_to_find/) {#/// ////////if($row =~ /\b$word_to_find\b/) {
			$FileName = "$cwd/$filename" ;
			if ( $type =~ m/$VFCtoken/  &&  $EXTEN =~ m/vfc/i   )
			{
				if ( $tok =~ m/^$type/ )
				{
					$found += 1;
					if ( $EXTEN =~ m/vfc/i  )
					{
						print "$bright_green";
						print "\tvfc $FileName $line_number\t$default|--------> $tok$row;\n";
						}
				}else{
					}
			}else{
				$found += 1;
				if ( $EXTEN =~ m/vfc/i  )
				{
					#print "$green";
					cprint( "\tvfc $FileName $line_number\t$default|---- $EXTEN ----> $tok$row;" , 'red'  );# ////
				} else {
					if (-e "$filename.vfc" )
					{
						#print "$cyan";
						cprint ( "\tvfc $FileName $line_number\t$default| line: $line_number  ---$EXTEN ----> $tok$row", 'cyan' );# ////
					} elsif( $filename !~ /\.vfc$/ ) {
						#print "$yellow";
						cprint ( "$FileName:$line_number" , 'yellow'  );#cprint ( "\tvfc $FileName   $line_number\t$default| line: $line_number  ---$EXTEN ----> $tok$row" , 'yellow'  );
						#print ( "\t|----> $tok$row\n" , );
						}
					}
				}
			#print "$bright_green";
			#print ( "\t---------------------------------- $filename  \n" );
			$NPPcodeData = "$NPPcodeData\tnotepad++.exe -n$line_number -multiInst\t$FileName \n\t\t|$line_number)\t$tok$row\n\n";
			#$VScodeData = "$VScodeData\tcode  -g $filename:$line_number \t|--------> $tok$row\n";
			$VScodeData = "$VScodeData\t$filename:$line_number\n" ;#$VScodeData = "$VScodeData\t$FileName:$line_number\n" ;
			$found_in_file++;
			}#// //////
		#print "$reset";
		}#// //////
	
	if ( $found_in_file > 0 )
	{
		my $dir  = dirname($filename);#my $dir  = dirname($FileName);
		($name)= basename( $filename );#my ($name) = fileparse($filename, qr/\.[^.]*/);
		$search_term = $word_to_find ;
		$search_term =~ s/[\\\/:*?"<>|]+/_/g;
		$term = path_to_safe_term($filename);
		#print( "$search_term ==== $found_in_file\tREFERENCES FOUND in FILE: $name =========== PATH: $dir ===========\n" );
		if ( $save == 1 )
		{
			mkdir "refs_npp"  ;
			$file = "refs_npp/npp_$search_term-$term-$name.ref" ;#$file = "npp_XXX_$name.ref" ;
			open my $fh, '>', $file or die "Cannot open $file: $!";
				#print( "$NPPcodeData\n" );
				print( $fh "CURRENT DIRECTORY: $cwd\n" );
				print( $fh "REFERENCES FOR $word_to_find on PATH: $dir  FILE: $name\n\n" );
				print( $fh "$NPPcodeData\n" );
				close $fh or die "Cannot close $file: $!";
			mkdir "refs_vsc"  ;
			$file = "refs_vsc/vsc_$search_term-$term-$name.ref" ;
			open my $fh, '>', $file or die "Cannot open $file: $!";
				#print( "$VScodeData\n" );
				print( $fh "CURRENT DIRECTORY: $cwd\n" );
				print( $fh "REFERENCES FOR $word_to_find on PATH: $dir  FILE: $name\n\n" );
				print( $fh "$VScodeData\n" );
				close $fh or die "Cannot close $file: $!";
		} else {
			#print( "CURRENT DIRECTORY: $cwd\n" );
			#print( "REFERENCES FOR $word_to_find on PATH: $dir  FILE: $name\n\n" );
			#print( "$NPPcodeData\n" );
			#print( " -------------------------------------------------------------------------------- \n" );
			}
		$TOTAL_FILES++;
		#print( "\n=====================> $found_in_file HITS in FILE:  $filename\n\n");
		}
	close($fh);# ////
	if ( $found > 0  )
	{
		#print "\n\tVFC LOC: $line_number :: $found HIT(s)\n\n";
		$HIT_TOTAL += $found ;
		}
	return $line_number; }
$EXTEN  = "\.vfc" ; 
sub process_files{ my( $dir , $word , $type , $size_args ) = @_;
	$dir = "." if $dir eq "";
	opendir(DIR, $dir) or die "\n\t************ Could not open <$dir> in process_files \n";# ////
	$total_lines  = 0;
	$FIRST_HIT = "True" ;
	while (my $file = readdir(DIR)  ) {#while (my $file = readdir(DIR)  && $file !~ m/^\./ ) {
		next if $file =~ /^\./;   # skip dot files
		#print ( "\t------------------------- $dir --------- $file  \n" );
		if ( $EXTEN =~ m/files/ )
		{
			#print ( "\tvfc $file == $word \n" );
			if ( $file =~ m/$word/ && $file !~ m/^_/ &&  $file !~ m/\.vfc$/ )
			{
				if (-e "$dir/$file.vfc" )
				{
					print "-->";#print "$cyan";
				}else{
					#print "$yellow";
					}
				print ( "\tvfc $dir/$file  \n" ); 
			} else {
				}
		}else{
			if ( ( $file =~ m/$EXTEN$/i  ||  '*' =~ m/$EXTEN$/i   ) &&   -f "$dir/$file") {# if ( $file =~ m/$EXTEN$/i    &&   -f "$dir/$file") {
				#$FOLDER_FIRST_HIT = "False";
				
				if ( $dir == "."  )
				{
					$VFCfile = "$file" ;
				}else{
					$VFCfile = "$dir\\$file" ;
					}
				$VFCfile  =~ s/\\\//\\/;
				$VFCfile = "$dir\\$file" ;
				#print "   <$EXTEN> \n";
				$ROOT = basename( $VFCfile ) ; 
				if (  (  $ROOT !~ /^[_]/ ) )#if ( $VFCfile =~ m/$EXTEN$/i  && (   ".vfc" =~ m/$EXTEN$/i   ||  $ROOT !~ /^[_]/ ) )
				{
					$VFCfile =~ tr|/|\\|;
					if ( ".vfc" =~ m/$EXTEN/i   &&  ".*" !~ m/$EXTEN/i   )
					{
						print "$bright_blue";
						print "vfc2000 $VFCfile\n";# print "=====================\n";
						print "$default";
						}
					$lines = GetLines( $VFCfile , $word , $type  ) ;
					#if ( $FIRST_HIT == "True" && length($lines)>0 ) { print "<$EXTEN> $VFCfile\n"; $FIRST_HIT = "False";}
					$total_lines  += $lines ;
					#print "$VFCfile $lines\n";
					}
				}#// //////
			}
		}#// //////
	
	closedir(DIR);# ////
	return $total_lines  ;   }
#main#// // Print the directories ////
	use Cwd;# ////
	#my $dir = shift @ARGV or die "Usage: $0 <directory>\n";
	$TOTAL_FILES  = 0;
	my $dir = "";
	my $word = "";
	my $size = $#ARGV + 1;
	#print "The size of \@ARGV is $size:  @ARGV\n";
	if ( $size >=  1) {# ////
	# // Get the directory and file names from the arguments //
		$A = $ARGV[0] ;#  file types
		$A1 = $ARGV[1] ;#  keyword
		$A2 = $ARGV[2] ;# vfc types
		if ($A1 =~ s/--save\b//)
		{
			$save = 1 ;
			print( "===>>Logging references in wsc/ and npp/\n" );
			}
		#print "============================================>    args: $A, $A1, $A2  \n";
		$EXTEN= ($A =~ /\.([\w\*]+)$/) ? "\.$1" : ""; 
		$word = $A1 ;#\
		$type = $A2 ;#\
		if ($EXTEN) { 
			#print "Scanning for $EXTEN ....\n\n";
			$dir = ".";
			#print "begin at $dir\nlooking for: $word\n";
		} else {#// //////
			$EXTEN  = "\.vfc"  ; 
			#print "Scanning for $EXTEN  ....\n\n";
			if ( -d $A )
			{
				$dir = $A;
				#$flag = $ARGV[3];
			}else{
				print "default dir\n\n";
				$dir = ".";
				$word = $A;#\
				$type = $A1;#\
				print "Looking for: $A\n";
				#$flag = $ARGV[2];
				}
			}#// //////
	}else{
		
		print "\n==============================================================\n"; 
		print( "<directory=$dir>  type=<$EXTEN> <search term=$word> <vfc_type=$type>\n" ) ;#//// ////////
		print( "\tvfcfind .* \tkeyword - looks for all file types of ANY ext for <keyword>\n" ) ;
		print( "\tvfcfind .ext \tkeyword - looks for all file types of .ext for <keyword>\n" ) ;
		print( "\tvfcfind  \tkeyword - looks for all VFC files for <keyword>\n" ) ;
		print( "\tvfcfind .files \tkeyword - looks for all filenames with <keyword>\n" ) ;
		print "==============================================================\n\n"; 
		print( "\nUseage: @ *.ext  <search term> [--save] [vfc_type]\n" ) ;
		print( "\n\tWhere:  --save flag will save vscode reference files in refs_vsc/ and notepad++ references in refs_npp/\n" );
		print( "\tWhere:  vfc_type = {input,event,process,set,output,loop,lend,branch,path,bend,end,generic}\n" ) ;
		exit
		}
	#process_files( "$dir" , $word  , $type ) ;
	# // Use glob to get all the files and directories in the path //
	my @list_of_files = glob("$dir/*"); 
	my @list_of_files =  File::Find::Rule->directory->in($dir);
	print "==============================================================\n"; 
	print( "Curent directory: $cwd \n" );
	use File::Find;# ////
	my @safe_dirs;# ////
my $wanted = sub {# ////
	return unless -d;# ////
return if $File::Find::name =~ /\/?build\//;# // skip any build/ //
return if $File::Find::name =~ /\/?CMakeFiles\//;# // skip CMake garbage //
push @safe_dirs, $File::Find::name;# ////
};#// //////
find($wanted, '.');#// //////
# // Debug it: //
#print "$_\n" for @safe_dirs;
#print "TOP FOLDER ============> $dir\n";
#$lines = process_files( "$dir" , $word , $type ) ;
#print "\t--------------> $dir  :  $lines \n\n";
$TotalLines += $lines;
# // Filter out the directories using the -d file test operator //
my @list_of_dirs = grep { -d } @list_of_files;
$lines = process_files( "" , $word , $type , $size ) ;
foreach my $dir (@list_of_dirs) {
	if ( $dir =~ m/BackupVFC/ || $dir =~ m/BSP_/ || $dir =~ m/build/ || $dir =~ /^\./ )
	{
		#print( "\t\t---->Skipping ... $dir\n"  );
	} else {
		#print "FOLDER==> $dir:\n";
		$lines = process_files( "$dir" , $word , $type , $size ) ;
		$TotalLines += $lines;
		# print "Lines of VFC in $dir  :  $lines \n\n";
		}
	}#// //////

#sleep(5);
print( "<directory=$dir>  type=<$EXTEN> <search term=$word> <vfc_type=$type>\n" ) ; 
print "==> TOTAL SCANNED LOC: $TotalLines :: HITS: $HIT_TOTAL :: FILES: $TOTAL_FILES\n";

