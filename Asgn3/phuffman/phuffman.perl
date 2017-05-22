#!/usr/bin/perl
# $Id: phuffman.perl,v 1.4 2016-11-08 12:16:25-08 - - $

use strict;
use warnings;

$0 =~ s|/*$||;
$0 =~ s|^.*/||;
my $exit_status = 0;
sub note(@) {print STDERR "$0: @_"}
$SIG{__WARN__} = sub {note @_; $exit_status = 1};
$SIG{__DIE__} = sub {warn @_; exit};
END {exit $exit_status}

########################################################################

sub newtree($$;$$) {
   my ($char, $count, $leftp, $rightp) = @_;
   my $tree = {CHAR=> $char, COUNT=> $count};
   $tree->{CHILDREN} = [$leftp, $rightp] if $leftp || $rightp;
   return $tree;
}

sub cmptree($$) {
   my ($tree1p, $tree2p) = @_;
   return $tree1p->{COUNT} <=> $tree2p->{COUNT}
       || $tree1p->{CHAR}  <=> $tree2p->{CHAR}
}

sub hencode($$$);
sub hencode($$$) {
   my ($encodings, $tree, $encoding) = @_;
   if ($tree->{CHILDREN}) {
      hencode $encodings, $tree->{CHILDREN}->[$_], $encoding . $_
              for 0 .. $#{$tree->{CHILDREN}}
   }else {
      $encodings->[$tree->{CHAR}] = $encoding;
   }
}


########################################################################

use constant ROOT=> 1;

sub parent($) {my ($index) = @_; $index >> 1}
sub lchild($) {my ($index) = @_; $index << 1}
sub rchild($) {my ($index) = @_; $index << 1 | 1}
sub empty($)  {my ($pqueue) = @_; $#$pqueue < ROOT}
sub newpqueue() {[0]}

sub swap($$$) {
   my ($pqueue, $index1, $index2) = @_;
   @$pqueue[$index1, $index2] = @$pqueue[$index2, $index1];
}

sub rootward($$$) {
   my ($pqueue, $index1, $index2) = @_;
   return (cmptree $pqueue->[$index1], $pqueue->[$index2]) < 0
}

sub insert($$) {
   my ($pqueue, $tree) = @_;
   push @$pqueue, $tree;
   for (my $child = $#$pqueue; $child > ROOT; ) {
      my $parent = parent $child;
      last if rootward $pqueue, $parent, $child;
      swap $pqueue, $child, $parent;
      $child = $parent;
   }
}

sub deletemin($) {
   my ($pqueue) = @_;
   die "deletemin: pqueue is empty" if empty $pqueue;
   swap $pqueue, ROOT, $#$pqueue;
   my $result = pop @$pqueue;
   my $parent = ROOT;
   for (;;) {
      my $child = lchild $parent;
      last if $child > $#$pqueue;
      my $rchild = rchild $parent;
      $child = $rchild if $rchild <= $#$pqueue
                       && rootward $pqueue, $rchild, $child;
      last if rootward $pqueue, $parent, $child;
      swap $pqueue, $parent, $child;
      $parent = $child;
   }
   return $result;
}


########################################################################

# 1. Load frequency table.

my @frequencies;
for my $filename (@ARGV ? @ARGV : "-") {
   open my $file, "<$filename" or do {warn "$filename: $!\n"; next};
   map {++$frequencies[ord $_]} split "" while <$file>;
   close $file;
   $frequencies[256] = 1;
}

# 2. Load priority queue from frequency table.

my $pqueue = newpqueue;
for my $char (0..$#frequencies) {
   insert $pqueue, newtree $char, $frequencies[$char]
          if $frequencies[$char];
}

# 3. Unload priority queue into Huffman tree.

my $tree;
for (;;) {
   last if empty $pqueue;
   $tree = deletemin $pqueue;
   last if empty $pqueue;
   my $rtree = deletemin $pqueue;
   insert $pqueue, newtree $tree->{CHAR},
                   $tree->{COUNT} + $rtree->{COUNT}, $tree, $rtree;
}

# 4. Traverse Huffman tree into encoding array.

my @encodings;
hencode \@encodings, $tree, "" if $tree;

# 5. Print out frequency and encoding table.

for my $char (0 .. $#frequencies) {
   next unless $frequencies[$char];
   my $fmt = (chr $char) =~ m/[[:graph:]]/ ? " %c " : "x%02X";
   printf $char == 256 ? "EOF"
        : (chr $char) =~ m/[[:graph:]]/ ? " %c "
        : "x%02X", $char;
   printf "%8d  %s\n", $frequencies[$char], $encodings[$char];
}

