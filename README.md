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
