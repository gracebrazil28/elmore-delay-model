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
use List::MoreUtils qw( minmax );
use List::MoreUtils qw(first_index);

########                                         ##########
#                      MAIN PROGRAM                       #
########                                         ##########
 

#Ask user to give the location of the path of the input file
print "Give the file's exact path (ex: '/Users/Desktop/in/r1_top.txt')\n>> ";
my $file = <STDIN>;
chomp $file;

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
  #print "Accessing node 1's parents node: $node_array[0]->{'1'}\n";
      
      
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
       
   
   #TODO: calculate the capacitance for each node
   #@node_cap;
   
   foreach my $node (@node_array){
   
   #if not the root node, add half of its edge capacitance to its parent
   if ($node->{'1'} != -1){
      	#print " Adding to the parent first .... \n";
   		#print "i = $node->{'0'} Cei = $edge_Cap[$node->{'0'}-1]\n";
   		#print "This node's parent is: $node->{'1'}\n";
   		$node_cap[$node->{'1'}-1] += $edge_Cap[$node->{'0'}-1]/2;
   		#print Dumper (@node_cap);
   		
   		print " Adding to to its own .... \n";
   		#add own edge capacitance (halved)
        #print "i = $node->{'0'} Cei = $edge_Cap[$node->{'0'}-1] C_sink= $cap_sink[$file_no]\n";
   		$node_cap[$node->{'0'}-1] += $edge_Cap[$node->{'0'}-1]/2;
   		#print Dumper (@node_cap);
   		
   		#print " Adding sink cap if this is a sink .... \n";
   		#check if this is a sink, add sink capacitance
   		if ( ($node->{'2'} == -1) & ($node->{'3'} == -1) ){
   		$node_cap[$node->{'0'}-1] += $cap_sink[$file_no];
  		}
  		#print "Final Node capacitance: $node_cap[$node->{'0'}-1] \n";
   }
   
   else {
   # this is the root note, 
   # its children have been adding half of its own edge capacitance already
    print "This is the ROOT NODE! \n";
    print "i = $node->{'0'}\n";
   	print "Final Node capacitance: $node_cap[$node->{'0'}-1] \n";
   }

} # end going through the node_array from parsed input file

	print "Printing Node capacitance array: \n";
    print Dumper (@node_cap);
    
   # To calculate delay, we need to create an array that adds all the downstream capacitance
   # This is to make the delay calculation easier
   #@downstream_cap;
   
   foreach my $node (@node_array){
   # adding the node capacitance here will be a BOTTOM-UP approach since the higher we are
   # in the binary tree, the more downstream capacitance it will have
   
   if ( $node->{'1'} != -1 ){
    $downstream_cap[$node->{'0'}-1]+= $node_cap[$node->{'0'}-1]; 
    # add this to its parent's downstream cap
    $downstream_cap[$node->{'1'}-1] += $downstream_cap[$node->{'0'}-1];
    }
   
   else {
   # if we get here, that means this is the root node
   print "We got to the root node, the sum of its downstream capacitance are already here\n";
   # add its own node capacitance here
   $downstream_cap[$node->{'0'}-1]+= $node_cap[$node->{'0'}-1]; 
   }   
 } #end foreach calculation for downstream cap
 
 print Dumper (@downstream_cap);
    

    @delay_node=  map {0} (1.. $node_count[$file_no]);
    print "about to print inital contents of delay array: @delay_node\n";
   # ENABLE THIS LOOP AFTER CALCULATING THE DOWNSTREAM CAPACITANCES OF EACH NODE
     
   foreach my $node (@node_array) {
   # also because calculating for the delay for the root is different (buffer resistance is considered)
   if ( $node->{'1'} == -1 ) {
   	#this is the root node, calculate for delay 
   	$delay_node[$node->{'0'}-1] =  $res_buffer[$file_no] * $downstream_cap[$node->{'0'}-1]; 	
   }	
	else {
	# this means that this is not the root node, begin normal calculations
	# calculate the node's own delay = edge_red * downstream caps
 	$delay_node[$node->{'0'}-1] += $edge_Res[$node->{'0'}-1] * $downstream_cap[$node->{'0'}-1];
	}     
  } #end foreach loop
  
  print Dumper (@delay_node);
  
  # After calculating each node's delay, we can start accumulating delays per node
  
  	foreach my $node (@node_array) {
  	
  	$this_node = $node->{'0'};
  	print "this node is $this_node\n";
  	
  	# check this current node's parent
  	$par_node = &findParent ($this_node);
  	print "this current node's parent is: $par_node\n";
  	  	if ($par_node == -1) {
  	  	goto OUT;
  	}
  	
  	
  	#add the parent's delay to this node's delay
  	$delay_node[$this_node-1] += $delay_node[$par_node-1];
  	#print Dumper (@delay_node);
  	
  	
  	$par2_node = 0;
	while ($par2_node != -1){
		$par2_node = &findParent($par_node);
		print "has another parent: $par2_node\n";
		if ($par2_node != -1) {
			$delay_node[$this_node-1] += $delay_node[$par2_node-1];
			#print Dumper (@delay_node);
			}
		}

	OUT:
  	}
  	
  	print "final delay array... \n";
  	print Dumper (@delay_node);
	
	   
   #CALCULATE CLOCK SKEW: largest difference between the arrival time of the clock signal between a pair of clock sinks
   #save all the sink delays
	foreach my $node (@node_array) {
	if ( ($node->{'2'} == -1) & ($node->{'3'} == -1) ) {
		push (@sinks, $delay_node[$node->{'0'}-1]);
		}
	}
	print Dumper (@sinks);
   #save max, save min, calculate the difference
   ($min, $max) = minmax @sinks;
   $max_skew = $max-$min;
   print "Min delay is $min\n";
   print "Max delay is $max\n";
   print "Max skew is $max_skew\n";
   
   
   
   #Let me know when EOF is reached
   print "File Ended. . . . .\n";
   close($filename);

sub findParent {
 my ($thisnode) = @_;
 $par_node = $node_array[$thisnode-1]->{'1'};
 #print "found its parent! it is $par_node\n";
 return $par_node;
}
