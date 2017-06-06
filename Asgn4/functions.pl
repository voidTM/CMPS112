


/* functions */
/*Return the distance in mile of the two location */
haversine( latA, latB, lonA, lonB, distance) :-
   radius is 3,959,
   dlon is lonB - lonA,
   dlat is latB - latA,
   a is sin( Dlat / 2 ) ** 2
      + cos( latA ) * cos( latB ) * sin( dlon / 2 ) ** 2,
   dist is 2 * atan2( sqrt( a ), sqrt( 1 - a )),
   distance is dist * radius.


/* convert degree and minutes to radians */

dms_to_radian( degree, minutes, radian) :-
	dec_minute is (minutes / 60).
	dec_degree is degree + dec_minute,
	rad is dec_degree / 180 * pi.

/* add time */
add_time(time(hA,mA), time(hB,mB), time(hC,mC)) :-
  hC is hA + hB,
  mC is mA + mB,
  calibrate(hC, mC).


/* Get the latitude and longitude of an airport */
get_airport_data(airport, latitude, longitude) :-
  airport(airport, _, degmin(A, B), degmin(C,D)),
  dms_to_radian(A, B, latitude),
  dms_to_radian(C, D, longitude).

/*calculate flight time from one airport to another? */
calc_arrival_time(depart_time, arrival_time, distance) :-
  travel_time is distance / 500,
  t_hours is floor(travel_time),
  t_min is (travel_time - travel_hours) * 60, 
  t_minutes is floor(t_min),
  add_time(depart_time, time(t_hours, t_minutes), arrival_time).
  write(arrival_time), nl.

/* calculate time for a particular leg of a flight? */
flight_leg(departure, arrival, arrival_time)
  flight(departure, arrival, depart_time),
  get_airport_data(departure, lat_d, lon_d),
  get_airport_data(arrival, lat_a, lon_a),
  haversine(lat_d, lat_a, lon_d, lon_a, distance),
  calc_arrival_time(depart_time, arrival_time, distance).

/* round times up to ensure 60 minutes max  */
calibrate(hours, minutes) :-
    minutes is mod(minutes, 60),
    hours is hours + floor(minutes / 60).

/* converts hours minutes into minutes */
hrs2mins(time(hours, minutes), Mins) :-
    Mins is hours * 60 + minutes.

	
/* check to make sure flight does not go past 1 day */
overnight_flight(flight(departure,arrival,depart_time)) :-
    flight_leg(departure, arrival, arrival_time),
    (   arrival_time >= 24 ->
        write('Overnight flight.'), nl.
    ;   write('Not overnight flight.'), nl.
    ). 

/* c */
transfer_flight(time(arrival_hours, arrival_minutes),
        time(depart_hours, depart_minutes)) :-
        hrs2mins(time(arrival_hours, arrival_minutes), M1),
        hrs2mins(time(depart_hours, depart_minutes), M2),
    (   M2 - M1 < 30 ->
        write('Invalid transfer.'), nl.
    ;   write('Valid transfer.'), nl.
    ).

/* find shortest path between two airports */
shortest(departure, arrival, list) :-
    listpath(departure, arrival, list).

listpath(Node, End, [flight(Node, Next, Next_Dep)|Outlist] ) :-
    not(Node = End),
    flight(Node, Next, Next_Dep),
    listpath(Next, End, [flight(Node, Next, Next_Dep)], Outlist).

listpath(Node, Node, _, []).
listpath(Node, End, [flight(Prev_Dep, Prev_Arr, Prev_Deptime)|Tried],
        [flight(Node, Next, Next_Dep)|list] ) :-
    flight(Node, Next, Next_Dep),

    /*needs some change in sub functions*/
    flight_leg(Prev_Dep, Prev_Arr, Prev_Arrtime),
    transfer_flight(Prev_flight, Future_flight),
    overnight_flight(flight(Node,Next,Next_Dep)),
    /*------------------------------------*/

    Tried2 = append([flight(Prev_Dep, Prev_Arr, Prev_Deptime)], Tried),
    not(member(Next, Tried2)),
    not(Next = Prev_Arr),
    listpath(Next, End, [flight(Node, Next, Next_Dep)|Tried2], list).


/* fly functions */
fly(airportA, airportA) :-
   write('Error: Departure and arrival airports are the same'),
   nl, !.

fly(departure, _) :-
  not(airport(departure, _, _,_)),
  write('Error: Invalid departure airport'),
  nl, !.

fly(_, arrival) :-
  not(airport(arrival, _, _,_)),
  write('Error: arrival departure airport'),
  nl, !.

fly(From,To) :-
  write('Printing flying options'),
  shortest(departure, arrival, list),
  nl, !.

fly( Depart, Arrive ) :- 
  not(shortest(departure, arrival, _)),
  write('Couldnt find you a flight'),
  nl, !.