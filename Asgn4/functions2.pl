<<<<<<< HEAD
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
    Minutes is mod(Minutes, 60),
    Hours is Hours + floor(Minutes / 60).

/* converts Hours minutes into minutes */
hrs2mins(time(Hours, Mins), Minutes) :-
    Minutes is Hours * 60 + Mins.

	
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
overnight_flight(flight(Departure,Arrival,Depart_time)) :-
    flight_leg(Departure, Arrival, time(Arrival_H, Arrival_T)),
    format('currHour: ~w',[Arrival_H]), nl,
    Arrival_H < 24. 

/* c */
transfer_flight(time(Arrival_H, Arrival_M),
        time(Depart_H, Depart_M)) :-
        hrs2mins(time(Arrival_H, Arrival_M), M1),
        hrs2mins(time(Depart_H, Depart_M), M2),
        M2 - M1 > 30.




/* print list somewhere? */
/* find shortest path between two airports */
shortest(Departure, Arrival) :-
    listpath(Departure, Arrival, List),
    print_path(List).

/* recurse while the node arrived at is not the end node */
listpath(Node, End, [flight(Node, Next, Next_Dep)|Outlist] ) :-
    %not(Node = End),
    flight(Node, Next, Next_Dep),
    listpath(Next, End, [flight(Node, Next, Next_Dep)], Outlist).

listpath(Node, Node, _, []).
listpath(Node, End, [flight(Prev_Dep, Prev_Arr, Prev_Deptime)|Tried],
        [flight(Node, Next, Next_Dep)|List] ) :-
    /* get next possible departure from airport? */
    flight(Node, Next, Next_Dep),
    format('From: ~w ', [Prev_Dep]),
    format('To: ~w', [Prev_Arr]), nl,
    /*needs some change in sub functions*/
    flight_leg(Prev_Dep, Prev_Arr, Prev_Arrtime),
    transfer_flight(Prev_Arrtime, Next_Dep),
    overnight_flight(flight(Node,Next,Next_Dep)),
    /*------------------------------------*/

    append([flight(Prev_Dep, Prev_Arr, Prev_Deptime)], Tried, Tried2),
    /* broken statement that does nothing? */
    not(member([flight(Node, Next, Next_Dep)], Tried2)), 
    %not(Next = Prev_Arr),
    listpath(Next, End, [flight(Node, Next, Next_Dep)|Tried2], List).


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
=======
/*functions.pl*/
%Prolog version of NOT
not(X) :- X, !, fail.
not(_).

/*Finds distance between airports*/

/*Converts from degrees and minutes to degrees*/
degmin_to_rad( degmin( Degrees, Minutes ), Radians ) :-	
   Radians is (Degrees + Minutes / 60) * (pi / 180).			


/*Uses haversine formula to converts distance to miles, given degrees*/   
haversine_radians( Lat1, Lon1, Lat2, Lon2, Distance ) :-
   Dlon is Lon2 - Lon1,
   Dlat is Lat2 - Lat1,
   A is sin( Dlat / 2 ) ** 2
      + cos( Lat1 ) * cos( Lat2 ) * sin( Dlon / 2 ) ** 2,
   Dist is 2 * atan2( sqrt( A ), sqrt( 1 - A )),
   Distance is Dist * 3961.

/*computes distance*/   
distance( Airport1, Airport2, Distance ) :-
    airport( Airport1, _, Lat1, Lon1 ),					%Takes in an airport, gets lat and lon
    airport( Airport2, _, Lat2, Lon2 ),					%Takes in an airport, gets lat and lon
    degmin_to_rad( Lat1, LatD1 ),						%Converts latitude of airport 1 to degrees
    degmin_to_rad( Lat2, LatD2 ),						%Converts latitude of airport 2 to degrees
    degmin_to_rad( Lon1, LonD1 ),						%Converts longitude of airport 1 to degrees
    degmin_to_rad( Lon2, LonD2 ),						%Converts longitude of airport 2 to degrees
														%Calculates distance
    haversine_radians( LatD1, LonD1, LatD2, LonD2, Distance ).				

/*gets distance between airports, divides by 500 to get number of hours of flight*/
dist_in_hours(Airport1, Airport2, FlightTime) :-
   distance(Airport1, Airport2, Distance),
   FlightTime is Distance / 500.

arrival_time(flight(Airport1, Airport2, time(Disance_hours,Disance_minutes)), ArrivalTime) :-
   dist_in_hours(Airport1, Airport2, FlightTime),								%Distance in Hours
   hoursmins_to_hours(time(Disance_hours,Disance_minutes), DepartureTime),		%Converts to hours
   ArrivalTime is DepartureTime + FlightTime. 									%Unit is hoursonly   
   

/*converts from hours and minutes to hours*/   
hoursmins_to_hours( time( Hours, Mins) , Hoursonly ) :-
   Hoursonly is Hours + Mins / 60.						%Hours is hours + minutes/60

/*converts from minutes to hours*/   
mins_to_hours(Mins, Hours):-
   Hours is Mins / 60.									%Hours is minutes/60
   
/*converts from hours to minutes*/
hours_to_mins(Mins, Hours) :-
   Mins is Hours * 60.									%Minutes is hours * 60
   
/*If departure is less than 10 hours, print a leading zero*/   
print_2digits( Digits ) :-
   Digits < 10, print( 0 ), print( Digits ).

/*otherwise, print digits*/
print_2digits( Digits ) :-
   Digits >= 10, print( Digits ).
   
/*Displays a time*/   
print_time( Hoursonly ) :-			
   Minsonly is floor( Hoursonly * 60 ),					%Gets minutes from hours(rounds down)
   Hours is Minsonly // 60,								%Gets hours		
   Mins is Minsonly mod 60,								%Gets minutes
   
   /*Decides how many digits to print based on number of hours*/
   print_2digits( Hours ),
   print( ':' ),
   print_2digits( Mins ).
   
   
writepath( []) :-
	nl.
	
writepath( [flight(Depart,Arrive,Depart_hoursmins)|List]) :-
   airport( Depart, Depart_name, _, _ ),								%Gets departure airport
   airport( Arrive, Arrive_name, _, _),									%Gets arrival airport
   hoursmins_to_hours(Depart_hoursmins, DepartTime), 					%Converts to hour
   arrival_time(flight(Depart,Arrive,Depart_hoursmins), ArrivalTime), 	%Gets arrivaltime
   
   /*Formats output*/
   write('depart  '), write( Depart ), 
      write('  '), write( Depart_name ), 
      write('  '), print_time( DepartTime),
   nl,
   write('arrive  '), write( Arrive ), 
      write('  '), write( Arrive_name ), 
      write('  '), print_time( ArrivalTime),
   nl,
   
   writepath( List ). 

/*Is the flight possible with a 30 minute transfer*/	
possible_transfer( H1, T2) :-
   hoursmins_to_hours( T2, H2),
   hours_to_mins( M1, H1),
   hours_to_mins( M2, H2),
   M1 + 30 < M2.									%Possible with 30 minute delay?

/*makes sure flight arrives before 24 hours (same day)*/
possible_flight(flight(Dep,Arriv,DepTime)) :-
   arrival_time(flight(Dep,Arriv,DepTime), ArrivTime),
   ArrivTime < 24.
   
/*based off graphpaths.pl*/
listpath( Node, End, [flight(Node, Next, Next_Dep)|Outlist] ) :-	%two nodes and a flight list
   not(Node = End), 											%not at the end
   flight(Node, Next, Next_Dep),
   listpath( Next, End, [flight(Node, Next, Next_Dep)], Outlist). 

listpath( Node, Node, _, [] ).
listpath( Node, End,
   [flight(Prev_Dep,Prev_Arr,Prev_DepTime)|Tried], 
   [flight(Node, Next, Next_Dep)|List] ) :-
   flight(Node, Next, Next_Dep), 												%Finds potential flight
   arrival_time(flight(Prev_Dep,Prev_Arr,Prev_DepTime), Prev_Arriv), 			%Gets arrival time of previous flight
   possible_transfer(Prev_Arriv, Next_Dep), 									%Possible Transfer
   possible_flight(flight(Node,Next,Next_Dep)),									%Possible Flight
   Tried2 = append([flight(Prev_Dep,Prev_Arr,Prev_DepTime)], Tried),			%Appends flight to tried flights
   not( member( Next, Tried2 )), 												%Flight not already tried
   not(Next = Prev_Arr),														%Not same
   listpath( Next, End, [flight(Node, Next, Next_Dep)|Tried2], List ).    		%Adds potential flight to list
	  

travel_time([flight(Dep, Arr, Depart_hoursmins)|List], Length) :-
   length(List, 0),
   hoursmins_to_hours(Depart_hoursmins,Depart_hours), 
   arrival_time(flight(Dep, Arr, Depart_hoursmins), ArrivalTime),
   Length is ArrivalTime - Depart_hours.

travel_time([flight(Dep, Arr, Depart_hoursmins)|List], Length) :-
   length(List, L),
   L > 0,
   travel_time(flight(Dep, Arr, Depart_hoursmins), List, Length).
   

travel_time(flight(_, _, Depart_hoursmins), [Head|List], Length) :-
   length(List, 0),
   hoursmins_to_hours(Depart_hoursmins, Depart_hours),
   arrival_time(Head, ArrivalTime),
   Length is ArrivalTime - Depart_hours.

travel_time(flight(Dep, Arr, Depart_hoursmins), [_|List], Length) :-
   length(List, L),
   L > 0,
   travel_time(flight(Dep, Arr, Depart_hoursmins), List, Length).
   

/*Gets the shortest flight*/
shortest(Depart, Arrive, List) :-
   listpath(Depart, Arrive, List),			%Lists shortest path
   noshorter(Depart, Arrive, List).			%No shorter paths

/*Checks to see that there are no shorter paths*/
noshorter(Depart, Arrive, List) :-
   listpath(Depart, Arrive, List2),			%Checks other path
   travel_time(List, Length1),				%Gets travel time of orig path
   travel_time(List2, Length2),				%Travel time of new path
   Length1 > Length2,						%If orig path takes longer, this isnt shortest
   !, fail.

noshorter(_, _, _).

   
/*Gets path from one airport to the next*/   
fly( Depart, Arrive ) :-
   shortest(Depart, Arrive, List),
   nl,
   writepath(List),!.

/*flying to same airport has distance 0*/   
fly( Depart, Depart ) :-
   write('You are already here'),
   !, fail.

/*Departure airport not found*/   
fly( Depart, _ ) :-
   \+ airport(Depart, _, _, _),
   write('Departure Airport not found'),
   !, fail.

/*Arrival airport not found*/   
fly( _, Arrive ) :-
   \+ airport(Arrive, _, _, _),
   write('Cant fly there'),
   !, fail.

/*no flights found*/   
fly( Depart, Arrive ) :- 
   \+shortest(Depart, Arrive, _),
   write('Couldnt find you a flight'),
   !, fail.
>>>>>>> 3911b26d29b06a454bdc32fb771060e102fc4638
