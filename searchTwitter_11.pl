use strict;
use TwitterUtil;
use Encode;
#use warnings;
use strict;
use Getopt::Long;
use DBI;


#
#Output:
# delimiter:\t
# tweet_id, username, userid, date, client, text

#
#perl searchTwitter_noPM.pl -q "twitter" -s 2009-12-01 -u 2009-12-15 -l all -p 1
#
#-q:query
#-s:since
#-u:until
#-l:language all, ja ,en etc.
#-p: page (1-100) 15 tweets/1 page



my $query = "twitter";
my $lang = "ja";
my $since="";
my $unti="";
my $page=1;
my $tweetCount = 100;
GetOptions('query=s' => \$query, 'since=s' => \$since, 'until=s' => \$unti,
	  'language=s' => \$lang, 'count=s' => \$tweetCount);



#my $db=DBI->connect("DBI:mysql:sakaki:localhost","sakaki","ud0nud0n");
#my $table="toyota_test";



my $totalCount = 0;
my $eachCount = 100;
if($tweetCount < $eachCount){
    $eachCount = $tweetCount;
}
my $command = "?q=$query&lang=$lang&result_type=recent&count=$eachCount";

while($command ne "" && $totalCount < $tweetCount){
    
    #コマンド呼び出し
#    print STDERR "$command\n";
    
    
    if($since ne ""){
	if($since =~ /^\d{4}-\d{2}-\d{2}$/){
	    $command .= "&since=$since";
	}
    }
    if($unti ne ""){
	if($unti =~ /^\d{4}-\d{2}-\d{2}$/){
	    $command .= "&until=$unti";
	}
    }
    my $twitter = new  TwitterUtil();
    
    eval{    
	my $result=$twitter->run_auth("https://api.twitter.com/1.1/search/tweets.json$command");    
	
	
	#結果表示
	my $ref_list = $$result{"statuses"};
	$command = $result->{search_metadata}->{next_results};
	
	foreach my $hash (@$ref_list){
	    my $text = $$hash{text};
	    $text =~ s/\r\n/ /gs;
	    $text =~ s/\n/ /gs;
	    
	    #Tweetの全情報表示
#	    $sql="INSERT INTO $table (`tweet_id`,`tweet_time`,`twitter_user`,`twitter_user_id`,`tweet_body`,`station`,`road`) VALUES (\'$$hash{id}\', \'$$hash{created_at}\', \'$$hash{from_user}\', \'$$hash{from_user_id}\', \'$text\')";
	    my $user = $hash->{user}->{screen_name};
	    my $userid = $hash->{user}->{id};
	    my $date = TwitterUtil::convertDate($hash->{created_at});
	    print encode("utf8","$$hash{id}\t$user\t$userid\t$$hash{created_at}\t$$hash{source}\t$text\n");
	    $totalCount++;
#	    my $sth = $db->prepare($sql);
#	    $sth->execute;
	} 
    };
#$db->dicconnect;

    if($@){
	print STDERR $@,"\n";
    }
}
