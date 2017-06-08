% $Id: graphpaths.pl,v 1.3 2011-05-19 19:53:59-07 - - $ */

%
% Define the links in the graph.
%

flight( bos, nyc, time(  7,30 ) ).
flight( dfw, den, time(  8, 0 ) ).
flight( atl, lax, time(  8,30 ) ).
flight( chi, den, time(  8,30 ) ).
flight( mia, atl, time(  9, 0 ) ).
flight( sfo, lax, time(  9, 0 ) ).
flight( sea, den, time( 10, 0 ) ).
flight( nyc, chi, time( 11, 0 ) ).
flight( sea, lax, time( 11, 0 ) ).
flight( den, dfw, time( 11,15 ) ).
flight( sjc, lax, time( 11,15 ) ).
flight( atl, lax, time( 11,30 ) ).
flight( atl, mia, time( 11,30 ) ).
flight( chi, nyc, time( 12, 0 ) ).
flight( lax, atl, time( 12, 0 ) ).
flight( lax, sfo, time( 12, 0 ) ).
flight( lax, sjc, time( 12, 0 ) ).
flight( nyc, bos, time( 12,15 ) ).
flight( bos, nyc, time( 12,30 ) ).
flight( den, chi, time( 12,30 ) ).
flight( dfw, den, time( 12,30 ) ).
flight( mia, atl, time( 13, 0 ) ).
flight( sjc, lax, time( 13,15 ) ).
flight( lax, sea, time( 13,30 ) ).
flight( chi, den, time( 14, 0 ) ).
flight( lax, nyc, time( 14, 0 ) ).
flight( sfo, lax, time( 14, 0 ) ).
flight( atl, lax, time( 14,30 ) ).
flight( lax, atl, time( 15, 0 ) ).
flight( nyc, chi, time( 15, 0 ) ).
flight( nyc, lax, time( 15, 0 ) ).
flight( den, dfw, time( 15,15 ) ).
flight( lax, sjc, time( 15,30 ) ).
flight( chi, nyc, time( 18, 0 ) ).
flight( lax, atl, time( 18, 0 ) ).
flight( lax, sfo, time( 18, 0 ) ).
flight( nyc, bos, time( 18, 0 ) ).
flight( sfo, lax, time( 18, 0 ) ).
flight( sjc, lax, time( 18,15 ) ).
flight( atl, mia, time( 18,30 ) ).
flight( den, chi, time( 18,30 ) ).
flight( lax, sjc, time( 19,30 ) ).
flight( lax, sfo, time( 20, 0 ) ).
flight( lax, sea, time( 22,30 ) ).

%
% Prolog version of not.
%

not( X ) :- X, !, fail.
not( _ ).

%
% Is there a path from one node to another?
%

%
% This is the old version, which does not work on the new set
% of facts.  It causes the message [WARNING: Out of local stack],
% presumably due to the loop in the graph.
%
ispath( L, L ).
ispath( L, M ) :- 
   flight( L,X,_),
   ispath( X,M ).
%

ispath( L, M ) :- ispath2( L, M, [] ).

ispath2( L, L, _ ).
ispath2( L, M, Path ) :-
   flight( L,X,_),
   not( member( X, Path )),
   ispath2( X, M, [L|Path] ).

%
% Find a path from one node to another.
%

writeallpaths( Node, Node ) :-
   write( Node ), write( ' is ' ), write( Node ), nl.
writeallpaths( Node, Next ) :-
   listpath( Node, Next, [Node], List ),
   write( Node ), write( ' to ' ), write( Next ), write( ' is ' ),
   writepath( List ),
   fail.

writepath( [] ) :-
   nl.
writepath( [Head|Tail] ) :-
   write( ' ' ), write( Head ), writepath( Tail ).

listpath( Node, End, Outlist ) :-
   listpath( Node, End, [Node], Outlist ).

listpath( Node, Node, _, [Node] ).
listpath( Node, End, Tried, [Node|List] ) :-
   flight( Node,Next,_),
   not( member( Next, Tried )),
   listpath( Next, End, [Next|Tried], List ).


% TEST: writeallpaths(a,e).
% TEST: writeallpaths(a,j).
