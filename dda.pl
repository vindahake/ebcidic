#!/usr/bin/perl
use Convert::IBM390 qw(:all);

my $str, $buf;
my $count=0, $numbytes;
my $filename, $ofile;

###MAIN
$num_args= @ARGV;
if ($num_args < 1) {
	printf STDERR "Error: usage dda.pl filename\n";
	exit 2;
}
$filename = $ARGV[0];

if (open(FF, $filename) == 0) {
	printf STDERR "Error open failed\n";
	exit 1;
}

#open good file
$ofile = $filename . ".txt";
if (open(GD, ">$ofile") == 0) {
    printf STDERR "Error open $ofile failed errno=$!\n";
    exit 1;
}

#open bad file
$ofile = $filename . ".bad";
if (open(BD, ">$ofile") == 0) {
    print STDERR "Error open $ofile failed errno=$!\n";
    exit 1;
}

#get all the valid acct numbers
getacct();

while (( $numbytes = read(FF, $buf, 1)) > 0) {

	$rec_type = unpackeb('e1', $buf);

	if ($rec_type == "3") {
		body();
	}
	if ($rec_type == "4") {
		trailer();
	}
}
printf STDERR "Total recs=$count\n";
exit 0;

###
sub trailer()
{

	printf STDERR "Trailer\n";
	$numbytes = read( FF, $buf, 634);
	@data2 = unpackeb('e4 p8 p5 p8.2 p5 p8.2 p5 p8.2 p5 p8.2 p5 p8.2 p5 p8.2 e544', $buf);

	(
	$bank_num, $acct_num,
	$tot_credit_cnt, $tot_credit_amt, 
	$tot_credit_cnt_pst, $tot_credit_amt_pst,
	$tot_credit_amt_unpst, $tot_credit_amt_unpst,
	$tot_debit_cnt, $tot_debit_amt,
	$tot_debit_cnt_pst, $tot_debit_amt_pst,
	$tot_debit_amt_unpst, $tot_debit_amt_unpst,
	$filler2
	) = @data2;

	printf GD "$rec_type,$bank_num,$acct_num,$tot_credit_cnt,$tot_credit_amt,$tot_credit_cnt_pst,$tot_credit_amt_pst,$tot_credit_amt_unpst,$tot_credit_amt_unpst,$tot_debit_cnt,$tot_debit_amt,$tot_debit_cnt_pst,$tot_debit_amt_pst,$tot_debit_amt_unpst,$tot_debit_amt_unpst,$filler2";
	

}

###
sub body
{

	$numbytes = read( FF, $buf, 634);
	@data = unpackeb('e4 p8 p5 p5 p2 e3 p8.2 p6 p7 e2 e1 e1 e1 p3 e12 e20 
	p7.2 p7.2 p5 
	p7.2 p7.2 p5 
	p7.2 p7.2 p5 
	p7.2 p7.2 p5 
	p7.2 p7.2 p5 
	p7.2 p7.2 p5 
	e1 e1 e350 p8.2 e72', 
	$buf);

	$count++;

	($bank_num, $acct_num, $posting_date, $effective_date, $int_tran_code, 
	$ext_tran_code, $amount, $item_qty_date, $batch_seq, $posting_status, $posting_ind, 
	$cr_db_ind, $enclose_ind, $rim_source, $trans_ref_num, $client_ref_num, 
	$cust_float_amt, $bank_float_amt, $float_date, 
	$cust_float_amt2, $bank_float_amt2, $float_date2, 
	$cust_float_amt3, $bank_float_amt3, $float_date3, 
	$cust_float_amt4, $bank_float_amt4, $float_date4, 
	$cust_float_amt5, $bank_float_amt5, $float_date5, 
	$cust_float_amt6, $bank_float_amt6, $float_date6, 
	$float_print_sw, $funds_avail_code, $description, $running_balance, $filler1
	
	) = @data;

#	print "rec_type=$rec_type\n";
#	print "bank_num=$bank_num\n";
#	print "acct_num=$acct_num\n";
#	print "posting_date=$posting_date\n";
#	print "effective_date=$effective_date\n";
#	print "int_tran_code=$int_tran_code\n";
#	print "ext_tran_code=$ext_tran_code\n";
#	print "amount=$amount\n";
#	print "item_qty_date=$item_qty_date\n"; 
#	print "batch_seq=$batch_seq\n";
#	print "posting_status=$posting_status\n";
#	print "posinting_ind=$posting_ind\n";
#	print "cr_db_ind=$cr_db_ind\n";
#	print "enclose_ind=$enclose_ind\n";
#	print "rim_source=$rim_source\n";
#	print "trans_ref_num=$trans_ref_num\n";
#	print "client_ref_num=$client_ref_num\n";
#	print "cust_float_amt=$cust_float_amt\n";
#	print "bank_float_amt=$bank_float_amt\n";
#	print "float_date=$float_date\n";
#	print "cust_float_amt2=$cust_float_amt2\n";
#	print "bank_float_amt2=$bank_float_amt2\n";
#	print "float_date2=$float_date2\n";
#	print "cust_float_amt3=$cust_float_amt3\n";
#	print "bank_float_amt3=$bank_float_amt3\n";
#	print "float_date3=$float_date3\n";
#	print "cust_float_amt4=$cust_float_amt4\n";
#	print "bank_float_amt4=$bank_float_amt4\n";
#	print "float_date4=$float_date4\n";
#	print "cust_float_amt5=$cust_float_amt5\n";
#	print "bank_float_amt5=$bank_float_amt5\n";
#	print "float_date5=$float_date5\n";
#	print "cust_float_amt6=$cust_float_amt6\n";
#	print "bank_float_amt6=$bank_float_amt6\n";
#	print "float_date6=$float_date6\n";
#	print "float_print_sw=$float_print_sw\n";
#	print "funds_avail_code=$funds_avail_code\n";
#	print "description=$description\n";
#	print "running_balance=$running_balance\n";
#	print "filler1=$filler1\n";

	if (exists $acctlist{$acct_num}) {	
		printf GD "$rec_type,$bank_num,$acct_num,$posting_date,$effective_date,$int_tran_code,$ext_tran_code,$amount,$item_qty_date,$batch_seq,$posting_status,$posting_ind,$cr_db_ind,$enclose_ind,$rim_source,$trans_ref_num,$client_ref_num,$cust_float_amt,$bank_float_amt,$float_date,$cust_float_amt2,$bank_float_amt2,$float_date2,$cust_float_amt3,$bank_float_amt3,$float_date3,$cust_float_amt4,$bank_float_amt4,$float_date4,$cust_float_amt5,$bank_float_amt5,$float_date5,$cust_float_amt6,$bank_float_amt6,$float_date6,$float_print_sw,$funds_avail_code,$description,$running_balance,$filler1\n";
	} else {
		printf BD "$rec_type,$bank_num,$acct_num,$posting_date,$effective_date,$int_tran_code,$ext_tran_code,$amount,$item_qty_date,$batch_seq,$posting_status,$posting_ind,$cr_db_ind,$enclose_ind,$rim_source,$trans_ref_num,$client_ref_num,$cust_float_amt,$bank_float_amt,$float_date,$cust_float_amt2,$bank_float_amt2,$float_date2,$cust_float_amt3,$bank_float_amt3,$float_date3,$cust_float_amt4,$bank_float_amt4,$float_date4,$cust_float_amt5,$bank_float_amt5,$float_date5,$cust_float_amt6,$bank_float_amt6,$float_date6,$float_print_sw,$funds_avail_code,$description,$running_balance,$filler1\n";
	}
}


####
sub getacct 
{
	my $anum;

	#open the acct file which is the filter
	if (open(AC, "< pwsacct.txt") == 0) {
		printf STDERR "Error open failed pwsacct errno=$!\n";
		exit 1;
	}
	while (<AC>) {
		chop;
		($anum) = split;
		$acctlist{$anum} = 1;
	}
}

