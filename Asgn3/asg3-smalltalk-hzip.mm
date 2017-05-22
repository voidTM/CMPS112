.so Tmac.mm-etc
.if t .Newcentury-fonts
.SIZE 12 14
.INITR* \n[.F]
.TITLE CMPS-112 Spring\~2017 Project\~3 "Object Oriented Smalltalk"
.RCS "$Id: asg3-smalltalk-hzip.mm,v 1.7 2017-05-03 16:24:23-07 - - $"
.PWD
.URL
.de ULCB
.   if t \f[CB]\\$[1]\f[P]\l'|0\[ul]'\\$[2]
.   if n \\$[1]\\$[2]
..
.EQ
delim $$
.EN
.H 1 "Overview"
Smalltalk is a pure object-oriented language,
where everything is an object,
and all actions are accomplished by sending messages,
even for what in other languages would be control structures.
In this project we will be using Gnu Smalltalk,
the Smalltalk for those who can type
.=V [ http://smalltalk.gnu.org/ ].
.P
References\(::
.VTCODE* 1 http://smalltalk.gnu.org/documentation
.VTCODE* 1 https://www.gnu.org/software/smalltalk/manual-base
.VTCODE* 1 ftp://ftp.gnu.org/gnu/smalltalk/smalltalk-3.2.5.tar.gz
.H 1 "A file compression utility"
We present the program specifications in the form of a Unix
.V= man (1)
page.
This program will use Huffman coding to compress and decompress files.
.SH=BVL
.MANPAGE=LI "NAME"
hzip.st \[em] file compression and decompression utility
.MANPAGE=LI "SYNOPSIS"
.V= hzip.st
\|\f[CB]-dtcu\f[R]
\|\f[I]inputfile\f[R]
\|[\f[I]outputfile\f[R]]
.MANPAGE=LI "DESCRIPTION"
A file is either compressed (with the
.V= -c
option),
uncompressed (with the
.V= -u
option),
one of which is required,
unless the
.V= -t
option is specified.
The input filename is required.
If the output filename is not specified,
output is written to
the standard output.
.MANPAGE=LI "OPTIONS"
All options must be specified as the first word following the
name of the command, unlike the standard
.V= getopt (3)
used for C programs.
Exactly one of the options
.V= -t ,
.V= -c ,
or
.V= -u
is required.
.VL \n[Pi]
.MANOPT=LI -d
Debug information is printed for the benefit of the application
author.
Exact details are not specified.
.MANOPT=LI -t
The compression algorithm is activated,
and the decoding tree is printed to
the standard output.
The output filename may not be specified.
.MANOPT=LI -c
The input file is compressed and written to the output file,
if specified,
or to
the standard output,
if not.
.MANOPT=LI -u
The input file is assumed to be compressed, and is uncompressed,
written to the output file, if specified,
or to
the standard output,
if not.
.LE
.MANPAGE=LI "OPERANDS"
There are one or two filename operands.
The first is the input filename and the second is the output
filename.
If no output filename is specified, the standard output is written.
.MANPAGE=LI "EXIT STATUS"
.VL \n[Pi]
.LI 0
No errors occurred.
.LI 1
Errors occurred, either in scanning options or opening files.
.LE
.LE
.H 1 "Compression"
The compression algorithm reads the input file twice,
once to construct the decoding tree,
and if the
.V= -c
rather than the
.V= -t
option is specified,
a second time to perform the compression.
It proceeds as follows\(::
.ALX a ()
.LI
Read in the input file and create a frequency table,
counting the number of times each character appears on input.
The frequency table is indexed from 0 to 255 with characters.
Add entry 256 with a count of 1 to indicate EOF.
.LI
Iterate over the frequency table,
and for each non-zero element, create a leaf node
and insert that leaf node into a priority queue,
with the character and the count.
In Smalltalk, use a
.V= SortedCollection .
The counts take precedence,
but if two entries have the same count,
the one with the smaller character (lexicographically)
is considered smaller.
.LI
Repeatedly remove the two smallest elements from the priority queue,
creating a new tree which is then entered into the priority queue.
The smaller tree or leaf removed becomes the left child,
and the larger the right child.
The charcter in the new tree is the left child's character.
This process stops when there is only one tree left and the
priority queue is empty.
.LI
For each character that has appeared as non-zero in the frequency
table,
construct an encoding string, using a depth-first traversal.
The encoding string is a sequence of bits indicating the path 
from the root to a leaf.
.LI
If the
.V= -t
option is specified, write out the encoding table sorted by
character.
The first column is a single character, if printable, or an integer if
not.
The second column is the frequency for that character.
The third column is a sequence of 0 and 1 characters indicating the
encoding.
Format should appear as if done by the C format items
.V= "\[Dq]%3d\~%5d\~%s\[Dq]"
or
.V= "\[Dq]%3c\~%5d\~%s\[Dq]" .
Then stop.
.LI
If the
.V= -t
option is not specified,
write out the encoding table as follows\(::
Perform a post-order traversal of the decoding tree,
writing out one bit at a time in big-endian format.
for each leaf,
write out a 0 bit, followed by the 8 bits of the corresponding byte.
Write out the bits in the order bit 7, bit 6, \&.\|.\|., bit 0,
that is high bit first.
As a special case,
if the byte is 0,
write out bit 8,
which will be a 0 for a byte value of 0,
and 1 for a byte value of 256 (the EOF marker).
.LI
For each interior node,
write out a 1 bit.
.LI
Reopen the input file and write out the encoded version of
each byte.
At end of the buffer, write out the encoding string for EOF.
Then pad with 0 bits out to a byte boundary, if needed.
.LE
.H 1 "Decompression"
To uncompress a file, consider that the compressed file has a
decoding tree followed by data.
It is possible that the compressed version is large than the
uncompressed version.
Proceed as follows\(::
.ALX a ()
.LI
Reconstruct the Huffman decoding tree.
Read one bit.
.LI
If it is a 0,
read the next 8 bits and reconstruct the byte,
giving a value from 0 to 255.
If the value is 0,
read one more bit, and if it is a 1, add 256 to the byte,
giving the encoding for EOF.
Then push this byte onto a stack.
.LI
If it is a 1,
pop the 1-subtree from the stack,
then pop the 0-subtree from the stack,
and create a new tree with both of those children and push the new
tree back on the stack.
.LI
When the stack is empty,
there is only one tree left,
the decoding tree.
.LI
Now loop over the rest of the input file to reconstruct the
original file\(::
Initialize a pointer to the root of the decoding tree.
.LI
Read a single bit and use it to move down the 0-link or the 1-link
to the child of the current node.
.LI
If thise node is a leaf,
write out the corresponding byte and reset the pointer back to the root
of the tree.
.LI
If not, continue reading bits until you find a leaf.
.LE
.H 1 "Efficiency of the encoding.
The encoded tree contains only instances of those characters
that actually occur in the file,
and so is smaller than the complete tree.
In the worst case, there are 257 different characters to write
to the file,
255 of which are encoded as leaf nodes using 9 bits,
the remaining two (0 and 256) being encoded using 10 bits.
So the leaf nodes in the tree will consist of at most
$255 times 9 + 2 times 10 = 2315$ bits.
In a complete binary tree with $n$ nodes there are 
$n - 1$ interior nodes,
and since each of these are represented by 1 bit,
there are at most 256 bits representing interior nodes,
with a total of $2315 + 256 = 2571$ bits as the worst case
for the entire tree.
2571 bits = 321.375 bytes.
.P
Actual Huffman encoding will compress a file unless each byte
in the file occurs exactly the same number of bytes in the file,
which means that in the worst case,
the file will increase in size by 322 bytes.
Some files with poor statistical properties will increase a little,
but most will in fact be compressed significantly.
.IR "The Complete Works of William Shakespeare"
is 5,447,534 bytes long.
The
.V= compress 
program, a patented algorithm, can compress this to 2,214,693 bytes.
The
.V= gzip
program, a free algorithm,
is more efficient a compresses it to 2,015,136 bytes.
How many bytes are taken up when the present Huffman algorithm is
used\(??
.H 1 "What to submit"
Submit a
.V= README
and
.V= hzip.st
with a hash-bang and marked as executable.
Submit a
.V= PARTNER
file if you are doing pair programming.
See the rules for pair programming.
.FINISH
