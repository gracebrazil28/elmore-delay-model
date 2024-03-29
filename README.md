# Elmore Delay Model for Timing Delay Algorithm
### Elmore Delay Calculation in PERL
#### EEL4932 - Grace Brazil Fall 2019 

## Pre-liminary: Make sure you have perl interpreter ##
How do I know if I have the interpreter?  
>'perl -v' 

try it in your terminal, if it gives you an error you don't have it!
If you don't have it go here: http://www.perl.org/get.html
Afterwards, you should be able to do perl <space> anyperlscript.pl in your terminal


## Running the script in your terminal:
1. cd into the location where you saved the perl script
> cd /Desktop/Sandbox

2. run the perl script (UNIX)
> perl elmore.pl

3. It will ask you a prompt
> "Give the file's exact path (ex: '/Users/Desktop/in/r1_top.txt')\n>> "
Give exactly the file's exact path as shown in the example. 

At the end of the script, it should tell you something like this:
>Min delay is 4.54682619696774e-009
>
>Max delay is 1.14358552659227e-008
>
>Max skew is 6.889029068955e-009
>
>File Ended. . . . .

The calculation should be shown in your terminal/command prompt.

### Disclosure
Input files were not created by me. Input files by Dr. Rickard Ewetz: https://www.cecs.ucf.edu/faculty/rickard-ewetz/

## Background ##
The Elmore delay is an approximation for the delay of an arbitrary and complex RC circuits. The Elmore delay model is represented in a binary tree structure. Every edge in a binary tree is a wire with some resistance and capacitance. 

Consider the edge e = (u, v) of length le connecting a parent node u and a child node e. The resistance and capacitance of the wire are given by Re = r × le, Ce = c × le, where ‘r’ and ‘c’ are per-unit-length resistance and per unit length capacitance, respectively. Re will represent the edge resistance and Ce will represent the edge capacitance.

A sink node v (or leaf node) has a sink capacitance. There is a driver connected to the root node of the tree with an output resistance rd. 

A sink node has a sink capacitance. There is a driver connected to the root node of the tree with an output resistance rd. The node capacitance can be calculated as half of the edge capacitance of neighboring nodes (left child, right child and parent) summed up. If it is a sink node, then it is half of the edge capacitance plus the sink capacitance.

The downstream capacitance can be obtained by adding the node capacitance of a parent node plus the capacitance of its children, and its children’s children until we reach the sink node. The delay of the root node can be calculated as the buffer resistance times the downstream capacitance. The delay of each node can be calculated as the edge resistance times the downstream capacitance of the node. Afterwards, accumulation of delay can be added the lower the node is in the binary tree by summing the parent’s node to the child node and recursively finding if the parent has a parent node and adding its delay.   

## Task ##
The objective of this assignment is to calculate the Elmore delay in a binary tree structure. The program should take an input file name as the input and print the maximum skew to the screen. 

## Input Files ##
The content of the input files:

• Resistance per unit length (ohm/um), which specifies the per-unit-length resistance of a wire, r. 

• Capacitance per unit length (F/um), which specifies the per-unit-length capacitance of a wire, c. 

• Sink node capacitance (F), which specifies the sink capacitance associated with a leaf node v, cv. 

• Buffer output resistance (ohm), which specifies the output resistance at the sources, rd. 

• Sinkcount, which specifies the total number of sinks in your RC tree.

• Nodecount, which specifies the total number of nodes in the RC tree. 

• thisnode, which specifies the node number (integer) of current node. 

• parnode, which specifies the node number (integer) of the parent of current node. A node number of “-1” indicates the absence of a parent node, i.e., the current node is the root node of the tree. 

• lcnode, which specifies the node number (integer) of the left child node. A node number of “-1” indicates the absence of a left child node. 

• rcnode, which specifies the node number (integer) of the right child node. A node number of “-1” indicates the absence of a right child node. 

• length, which specifies the length (in m) from current node to its parent node by replacing the two edges with a single edge with a weight equal to the sum of the two edges.)


## Plan ##

Step 1: Parse the input file

Save the node information in an Array of Hashes. ‘0’ corresponds to the first column, ‘1’ corresponds to second column and so on. Grabbing the node’s parent, left child or right child can be easily called.

Step 2: Calculate node capacitance 

Create a node capacitance array for each node which is indexed [thisnode – 1]. See Background section in calculating node capacitance.

Step 3: Calculate downstream capacitance

Create a downstream capacitance array which is also indexed [thisnode-1]. See Background section in calculating downstream capacitance.

Step 4: Create an array that calculate the node’s own delay contribution

Calculating the delay contribution of each node is edge resistance * downstream capacitance of the node. The parent node is buffer resistance * downstream capacitance.

Step 5: Calculate accumulated delay  

This can be done by creating a new array to store final delay. The node delay can be copied so that its own node delay contribution doeds not have to be added. What is left for the delay calculation is adding the parent’s delay to this node. Create a recursive function that grabs the parent’s delay contribution and sums it with this node’s delay. Stay in this loop to find the previous parent’s parent until we reach the root node. 

Blog Post: https://gracebrazilprojects.wordpress.com/2019/12/06/elmore-delay-model-for-timing-delay-algorithm/

