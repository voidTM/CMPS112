


/* functions */
/*Return the distance in mile of the two location */
haversine_radians( latA, latB, lonA, lonB, distance) :-
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


/* Given a location, fetch the north west lat long
 * from the database
 */
get_airport_data(airport,Lat1, Lon1, Lat2, Lon2) :-
  airport(Airport, _, degmin(A, B), degmin(C,D)),
  /*write(H),*/
  Lat1 is A,
  Lon1 is B,
  Lat2 is C,
  Lon2 is D.

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
  get_airport_data

/* round times up to ensure 60 minutes max  */
calibrate(hours, minutes) :-
    minutes is mod(minutes, 60),
    hours is hours + floor(minutes / 60).

/* check to make sure flight does not go past 1 day */
overnight_flight(hours, minutes) :-
    (   hours >= 24 ->
        write('Overnight flight.'), nl.
    ;   write('Not overnight flight.'), nl.
    ). 

/* c */
transfer_flight(time(arrival_hours, arrival_minutes),
        time(depart_hours, depart_minutes)) :-
    (   depart_minutes - arrival_minutes < 30 ->
        write('Invalid transfer.'), nl.
    ;   write('Valid transfer.'), nl.
    ).

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
  nl.
  

