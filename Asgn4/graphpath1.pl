% $Id: graphpaths.pl,v 1.3 2011-05-19 19:53:59-07 - - $ */

%
% Define the links in the graph.
%

link( a, b ).
link( a, d ).
link( b, c ).
link( d, e ).
link( e, c ).
link( e, f ).
link( f, a ).
link( f, g ).
link( f, j ).
link( g, h ).
link( h, i ).
link( i, j ).

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
ispath( L, M ) :- link( L,X ),ispath( X,M ).
%

ispath( L, M ) :- ispath2( L, M, [] ).

ispath2( L, L, _ ).
ispath2( L, M, Path ) :-
   link( L, X ),
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
   link( Node, Next ),
   not( member( Next, Tried )),
   listpath( Next, End, [Next|Tried], List ).


% TEST: writeallpaths(a,e).
% TEST: writeallpaths(a,j).
