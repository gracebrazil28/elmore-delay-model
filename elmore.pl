########                                         ##########
#            University of Central Florida                #
# Department of Electrical Engineering & Computer Science #
#                   EEL 4932  - CAD of VLSI               #
#                     HW#4 CAD of VLSI                    #
########                                         ##########

#! /usr/bin/perl
use warnings;
#use strict;
use utf8;
use File::Basename;
use Data::Dumper qw(Dumper);
use List::Util qw( min max );
use List::MoreUtils qw(first_index);

########                                         ##########
#                      MAIN PROGRAM                       #
########                                         ##########
 

#Ask user to give the location of the input file folder
#print "Give the input folder's path name (ex: '/Users/Desktop/in')\n>> ";
#my $dir = <STDIN>;
#chomp $dir;

#my own directory for testing purposes only
my $dir = "/Users/preciousbrazil/Desktop/Sandbox/in";


opendir(DIR, $dir) or die "Could not open '$dir'! Try again!\n";
#$num_files = () = readdir(DIR);
$file_no = 0;

#go through all the files within the input folder
foreach my $file (glob("$dir/*")) {

  open my $filename, "<", $file or die "can't open '$file'\n";
  my $lineNum=0;
  print "Reading input file $file . . \n";
  my $j = 0;
  while(my $line = <$filename>){
         my $array_ref = +{};
         $filebasename = basename($file);
         ($outputname = $filebasename) =~ s/^(.*?)\.in/$1/;
         $lineNum +=1;
         chomp $line;
         #first line is resistance per unit length
         if ($lineNum == 1){
               @res_len_sci = $line =~ /\: (.*)/s;
               @res_len = sprintf("%.10g", $res_len_sci[$file_no]);
         }
         #second line is capacitance per unit length
         elsif ($lineNum == 2){
               @cap_len_sci = $line =~ /\: (.*)/s;
               @cap_len = sprintf("%.10g", $cap_len_sci[$file_no]);
         }
         #third line is sink node capacitance
         elsif ($lineNum == 3){
               @cap_sink_sci = $line =~ /\: (.*)/s;
               @cap_sink = sprintf("%.10g", $cap_sink_sci[$file_no]);
         }
         #fourth  line is buffer output resistance
         elsif ($lineNum == 4){
               @res_buffer = $line =~ /\: (.*)/s;
         }
         #fifth line is sink count
         elsif ($lineNum == 5){
               @sink_count = $line =~ /\: (.*)/s;
         }
         #sixth line is node count
         elsif ($lineNum == 6){
               @node_count = $line =~ /\: (.*)/s;
         }  
         #seventh line is empty
         elsif ( ($lineNum == 7)|($lineNum == 8)| ($lineNum == 9) ) {
         	#do nothing
         }  
          
         #body
         else {
         my @fields = split / /, $line; 
    
            foreach my $i (0..4){
                  $horizontal[$i] = $fields[$i];
                  $array_ref -> {$i} = $horizontal[$i];                 
            }

         push @node_array, $array_ref;

         $j += 1;
        print "Line finished reading\n";    
        
        } #close reading body statement   
    
    } #close while open

  #Checking values (for testing purposes)
  #print " res_len: \n";
  #print Dumper (@res_len);
  #print " cap_len: \n";
  #print Dumper (@cap_len);
  #print " cap_sinkload: \n";
  #print Dumper (@cap_sink);
  #print " res_buffer : \n";
  #print Dumper (@res_buffer);
  #print " sink_count: \n";
  #print Dumper (@sink_count);
  #print " node_count: \n";
  #print Dumper (@node_count);
  #print "*********** Printing the expected node array\n";
  ## @node_array 0-> node, 1-> parent_node, 2-> left_child, 3->right_child, 4-> length
  print Dumper (@node_array);
  print "Accessing node 1's parents node: $node_array[0]->{'1'}\n";
      
      
  ### Parsing done - START Calculation of Elmore Delay ###    
  
  # Calculate edge resistance Re = r * le, edge capacitance Ce = c * le
foreach my $k (0.. $node_count[$file_no]-1) {
   	$current_Re = $res_len[$file_no] * $node_array[$k]->{'4'}; 
   	push @edge_Res, $current_Re;
   	$current_Ce = $cap_len[$file_no] * $node_array[$k]->{'4'};
   	push @edge_Cap, $current_Ce;
  }
  #Print Arrays for Testing Purposes
  print " Edge Resistance \n";
  print Dumper (@edge_Res);
  print " Edge Capacitance \n";
  print Dumper (@edge_Cap); 
       
   #TODO: calculate downstream capacitance for each node
   
   #TODO: calculate the capacitance for each node
   @node_cap;
   @node_res;
   
   foreach my $node (@node_array){
   
   #if not the root node, add half of its edge capacitance to its parent
   if ($node->{'1'} != -1){
      	print " Adding to the parent first .... \n";
   		print "i = $node->{'0'} Cei = $edge_Cap[$node->{'0'}-1]\n";
   		print "This node's parent is: $node->{'1'}\n";
   		$node_cap[$node->{'1'}-1] += $edge_Cap[$node->{'0'}-1]/2;
   		print Dumper (@node_cap);
   		
   		print " Adding to to its own .... \n";
   		#add own edge capacitance (halved)
        print "i = $node->{'0'} Cei = $edge_Cap[$node->{'0'}-1] C_sink= $cap_sink[$file_no]\n";
   		$node_cap[$node->{'0'}-1] += $edge_Cap[$node->{'0'}-1]/2;
   		print Dumper (@node_cap);
   		
   		print " Adding sink cap if this is a sink .... \n";
   		#check if this is a sink, add sink capacitance
   		if ( ($node->{'2'} == -1) & ($node->{'3'} == -1) ){
   		$node_cap[$node->{'0'}-1] += $cap_sink[$file_no];
  		}
  		print "Final Node capacitance: $node_cap[$node->{'0'}-1] \n";
   }
   
   else {
   # this is the root note, 
   # its children have been adding half of its own edge capacitance already
    print "This is the ROOT NODE! \n";
    print "i = $node->{'0'}\n";
   	print "Final Node capacitance: $node_cap[$node->{'0'}-1] \n";
   }
   

}


   # TODO: Now Calculate the Delay for all the nodes
   #
   
   
   
   ############ --------                  *                -------- ############
   # NOTES:

   #  Delay is computed by rd (buffer resistance)* c_prime + Re * c_prime
   #  t_root = buffer_res * (all downstream node_cap)
   # t_child_of_root = t_root + Re_root * (all downstream node_cap)
   
   ############ --------                  *                -------- ############   
   
   
   
   #Let me know when EOF is reached
   print "File Ended. . . . .\n";
   close($filename);
   
   $file_no += 1;
   
   
    #Create Output File(cut information)
    open my $finaloutput, '>', $outputname.'.out';
    # provide the cut of the partitioning
    print {$finaloutput} "file name, min delay, max delay, skew" . "\n";
    foreach my $item (@partition){
    	print {$finaloutput} " $ouputname, min, max, skew" . "\n";
    }
    close $finaloutput;
 
   
    #print "\n\n*************************************************************\n\n";
    #print " > >  Check directory for the output files produced   < < ";
    #print "\n\n*************************************************************\n\n";  

   
   
} #close foreach file

