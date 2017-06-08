not( X ) :- X, !, fail.
not( _ ).


/* Math functions */
/*Return the distance in mile of the two location */
haversine( LatA, LatB, LonA, LonB, Distance) :-
   Dlon is LonB - LonA,
   Dlat is LatB - LatA,
   A is sin( Dlat / 2 ) ** 2
      + cos( LatA ) * cos( LatB ) * sin( Dlon / 2 ) ** 2,
   Dist is 2 * atan2( sqrt( A ), sqrt( 1 - A )),
   Distance is Dist * 3959.

/* convert degree and minutes to radians */
dms_to_radian( Degree, Minutes, Radian) :-
	Dec_minute is (Minutes / 60),
	Dec_degree is Degree + Dec_minute,
	Radian is Dec_degree / 180 * pi.

/* Time operations */
/* add time */
add_time(time(H_A,M_A), time(H_B,M_B), time(H_C,M_C)) :-
  H_C is H_A + H_B,
  M_C is M_A + M_B,
  calibrate(H_C, M_C).

/* converts time to minutes */
time_minutes(time(H, M), Minutes) :-
  Minutes is H * 60 + M.


/* Get the latitude and longitude of an airport */
get_airport_data(Airport, Latitude, Longitude) :-
  airport(Airport, _, degmin(A, B), degmin(C,D)),
  dms_to_radian(A, B, Latitude),
  dms_to_radian(C, D, Longitude).

/*calculate flight time from one airport to another? */
calc_arrival_time(Depart_time, Arrival_time, Distance) :-
  Travel_time is Distance / 500,
  T_hours is floor(Travel_time),
  T_min is (Travel_time - T_hours) * 60, 
  T_minutes is floor(T_min),
  add_time(Depart_time, time(T_hours, T_minutes), Arrival_time).

/* calculate time for a particular leg of a flight? */
flight_leg(Departure, Arrival, Arrival_time) :-
  flight(Departure, Arrival, Depart_time),
  get_airport_data(Departure, Lat_d, Lon_d),
  get_airport_data(Arrival, Lat_a, Lon_a),
  haversine(Lat_d, Lat_a, Lon_d, Lon_a, Distance),
  calc_arrival_time(Depart_time, Arrival_time, Distance).


/* traversal algorithm to find flight legs? */

/* round times up to ensure 60 minutes max  */
calibrate(Hours, Minutes) :-
    Hours is Hours + floor(Minutes / 60),
    Minutes is mod(Minutes, 60).

/* converts Hours minutes into minutes */
hrs2mins(time(Hours, Mins), Minutes) :-
    Minutes is (Hours * 60) + Mins.

	
/*Helper function that prints the airport name*/
print_airport(Airport) :-
  airport(Airport,Name,_,_), 
  write(Name), nl.

/* print all flight paths? */
print_path( [] ) :-
   nl.
print_path([Airport|Rest]) :-
  format('flights: ~w',[Airport]), nl,
  print_path(Rest).


/* check to make sure flight does not go past 1 day */
overnight_flight(Departure,Arrival) :-
    flight_leg(Departure, Arrival, Arrival_T),
    hrs2mins(Arrival_T, Curr_T),
    Curr_T < 1440. 

/* c */
transfer_flight(time(Arrival_H, Arrival_M),
        time(Depart_H, Depart_M)) :-
        hrs2mins(time(Arrival_H, Arrival_M), M1),
        hrs2mins(time(Depart_H, Depart_M), M2),
        (M2 - M1) >= 30.


/* print list somewhere? */
/* find shortest path between two airports */
shortest(Departure, Arrival) :-
    listpath(Departure, Arrival, List),
    print_path(List).

/* recurse while the node arrived at is not the end node */
listpath(Node, End, [flight(Node, Next, Next_Dep)|Outlist] ) :-
    not(Node = End),
   write('starting recursion'), nl,

    flight(Node, Next, Next_Dep),
    listpath(Next, End, [flight(Node, Next, Next_Dep)], Outlist).

listpath(Node, Node, _, []).

listpath( Node, End,
   [flight(Prev_Dep,Prev_Arr,Prev_DepTime)|Tried], 
   [flight(Node, Next, Next_Dep)|List] ) :-
   flight(Node, Next, Next_Dep),                        
   flight_leg(Prev_Dep, Prev_Arr, Prev_Arrtime),      
   transfer_flight(Prev_Arrtime, Next_Dep),                  
   overnight_flight(Node,Next),               
   append([flight(Prev_Dep,Prev_Arr,Prev_DepTime)], Tried, Tried2),     
       format('List = : ~w', [List]), nl,
    format('Next = : ~w ',[flight(Node, Next, Next_Dep)]), nl,
   append([flight(Node, Next, Next_Dep)], Tried2, Tried3),  
   not( member( flight(Node, Next, Next_Dep), Tried2 )),                        
   not(Next = Prev_Arr),
   listpath( Next, End, Tried3, List ).        

/* fly functions */
fly(Airport, Airport) :-
   write('Error: Departure and arrival airports are the same'),
   nl, !.

fly(Departure, _) :-
  not(airport(Departure, _, _,_)),
  write('Error: Invalid departure airport'),
  !, fail.

fly(_, Arrival) :-
  not(airport(Arrival, _, _,_)),
  write('Error: Invalid arrival airport'),
  !, fail.

fly(Departure,Arrival) :-
  write('Printing flying options'), nl,
  shortest(Departure, Arrival),
  nl, !.

fly(Departure, Arrival ) :- 
  not(shortest(Departure, Arrival)),
  write('Couldnt find you a flight'),
  nl, !.