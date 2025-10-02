use warnings;
use Getopt::Std;
use utf8;
use feature 'say';
no warnings 'once';
use IO::File;
use IO::Handle;
use File::Basename;
use MIME::Base64;
#use Getopt::Long qw(GetOptions);
#Getopt::Long::Configure qw(gnu_getopt);
use Getopt::Std;
#use Data::Dumper;
use strict;

my $config = "UBS_11";
my $ki = "shakespeare";
my %options;
getopts("s:c:g:m:i:k:e:", \%options);
foreach my $values(values %options)
{
	print "$values\n";
}
my $s3path = $options{s};# = $ARGV[0];
#$s3path =~ s/\r//g;
my $eml_number = $options{c};# = $ARGV[1];
#$eml_number =~ s/\r//g;

if(exists $options{g})
{
	$config = $options{g};
}
my $manifestPath = $options{m};# = $ARGV[2];
#$manifestPath =~ s/\r//g;
my $ingest_output;

if(exists $options{i})
{
	$ingest_output = $options{i};
}
# = $ARGV[3];
#$ingest_output =~ s/\r//g;
my $kg;
if(exists $options{k})
{
	$kg = $options{k};
}
if(exists $options{e})
{
        $ki = $options{e};
}


#print "$s3path--$eml_number--$manifestPath--$ingest_output--$kg--\n\n";
#my $test = <STDIN>;

print "Cleaning output path..\n";
my $clean = `rm -rf output/$config/*.*`; 
#print "sed -i 's/rowCount=[0-9]\\+/rowCount=$eml_number/g' configs/examples/$config.config";
#my $test = <STDIN>;
my $editEmlNumber = `sed -i 's/rowCount=[0-9]\\+/rowCount=$eml_number/g' configs/examples/$config.config`;

#my $cmd = `generateemails_thread.bat $config`;

my $cmd = system("bash generateemails_thread.sh $config");

my @files = glob("output/$config/*.eml");


open MOUT, '>', "manifest.txt"; 
open PM, '>', "participantPropertyMapping.json";
open PEM, '>', "participantPermissionsMap.json";
open DR, '>', "dataRoles.json";
open UI, '>', "userInformation.json";
open IS, '>', "inScopePropertyMapping.json";
print PM "[\n";
print PEM "{\n\"permissive\": {\n";
print DR "{\n  \"dataRoles\": [\n";
print UI "{\n  \"users\": [\n";
print IS "[\n";
my %regions;
my %inscope;
my $filen = scalar @files;
my $count = 0;
my %pemdd;
foreach my $filename(@files)
{
	$count++;
	my $filename_only = substr($filename, rindex($filename,"/")+1);
	if($count%1000 == 0)
	{
		print "s3://$s3path$filename_only\n";
	}
	print MOUT "s3://$s3path$filename_only\n";
	open JSN, '<', "$filename.json";
	open JSNPM, '<', "$filename.json.pm";
	my $contentspm = do { local $/; <JSNPM> };
	chomp($contentspm);
	$contentspm =~ s/\s+$//;
	#print "-->$contentspm<--\n";
	#my $_test = system("cat $filename.json.pm");
	my @temp = split /:/,(split /\n/,$contentspm)[0];
	my $temp2 = $temp[1];
	$temp2 =~ s/\s+$//g;
	$temp2 =~ s/-/_/g;
	$contentspm = $temp[0] . ":" . $temp2;
	my $contents = do { local $/; <JSN> };
	chomp($contents);
	$contents =~ s/\s+$//;
	#print "-->$temp[0]<-->$temp2<---\n";
	if(not exists $pemdd{$contentspm})
	{
		if($filen != $count) 
		{
			print PM "$contents,\n";
			print PEM "$contentspm,\n";
		}
		else
		{
			print PM "$contents\n";
			print PEM "$contentspm\n";
		}
        	#$pemdd{$temp[0]} = 1;
	}elsif($filen == $count)
	{
		my $temp0 = $temp[0];
		$temp0 =~ s/-/-z/g;
		print PEM $temp0 . ":" . $temp2;
	}
	$pemdd{$contentspm} = 1;
	close(JSN);
	close(JSNPM);
	open JSNDR, '<', "$filename.dr";
	my $contentsdr = do { local $/; <JSNDR> };
	chomp($contentsdr);
	$contentsdr =~ s/\s+$//;
	$regions{$contentsdr} = 1;
	close(JSNDR);
	open ISIN, '<', "$filename.is";
	my $contentsis = do { local $/; <ISIN> };
	chomp($contentsis);
	$contentsis =~ s/\s+$//;
	$inscope{$contentsis} = 1;
	
}
close(MOUT);
print PM "]";
#print PM "]\n}";
close(PM);
print PEM "   }\n}";
close(PEM);

foreach my $region(keys %regions)
{
	
	$region =~ s/-/_/;
	print DR "    {\n      \"name\": \"$region" . "_Major\",\n";
	print DR "      \"permissions\":[\n";
	print DR "        \"msg:$region\",\n";
	print DR "        \"ki:$ki-$region\",\n";
	print DR "        \"alert:$region:$ki-$region\",\n";
	print DR "        \"index:alerted\",\n";
	print DR "        \"index:unalerted\"]\n    },\n";
	
	print UI "    {\n      \"username\": \"$region" . "_major\",\n";
	print UI "      \"email\":    \"$region.Major\@enron.com\",\n";
        print UI "      \"firstName\": \"$region\",\n";
        print UI "      \"lastName\": \"Major\",\n";
        print UI "      \"groups\": [\"L2 Review\"],\n";
        print UI "      \"dataRoles\": [\"$region" . "_Major\"],\n";
        print UI "      \"functionalRoles\": [\"analyst\", \"monitoring_manager\"],\n";
	print UI "      \"attributes\": {\"knownEntityId\": \"1\"}\n},\n";
}

print DR "    {\n      \"name\": \"admin\",\n";
print DR "      \"permissions\":[\n        \"msg:GLOBAL_ADMIN\",\n";

foreach my $region(keys %regions)
{
	$region =~ s/-/_/;
	print DR "        \"msg:$region\",\n";	
	print DR "        \"ki:$ki-$region\",\n";
	print DR "        \"alert:$region:$ki-$region\",\n"
}

print DR "        \"index:alerted\",\n";
print DR "        \"index:unalerted\"\n]\n    }\n";

print UI "     {\n      \"username\": \"admin\",\n";
print UI "      \"email\":    \"admin\@enron.com\",\n";
print UI "      \"firstName\": \"admin\",\n";
print UI "      \"lastName\": \"admin\",\n";
print UI "      \"groups\": [\"L2 Review\"],\n";
print UI "      \"dataRoles\": [\"admin\"],\n";
print UI "      \"functionalRoles\": [\"admin\"],\n";
print UI "      \"attributes\": {\"knownEntityId\": \"1\"}\n}\n";

print DR "]\n}";
print UI "]\n}"; 
close(DR);
close(UI);

my $isn = scalar keys %inscope;
my $iscount = 0;

foreach my $inscopeline(keys %inscope)
{
	$inscopeline =~ s/-/_/;
	$iscount++;
	if($isn != $iscount)
	{
		print IS "$inscopeline,\n";
	}
	else
	{
		print IS "$inscopeline\n"
	}
}
print IS "]";
close(IS);
#my $test = <STDIN>;
my $delTemp = system("rm -rf output/$config/*.pm;rm -rf output/$config/*.json;rm -rf output/$config/*.dr;rm -rf output/$config/*.is");
my $mCsurvf = system("mv participantP* output/$config/;mv manifest.txt output/$config/;mv dataRoles.json output/$config/;mv userInformation.json  output/$config/;mv inScopePropertyMapping.json  output/$config/;");

if(defined $kg)
{
print "automatically ingesting generated files\n";
my $ingest_cmd = system("bash ingest_csurv.sh manifest.txt $manifestPath $ingest_output $kg");
print "$ingest_cmd\n";
}
#FOR /f %%a IN ('dir /b "C:\datagen\TestFileGenerator-0.7.3\output\%1\*"') do @ECHO s3://dr-edu/test/mj/datagen/eml_1/%%a >> manifest.txt 2>&1 
