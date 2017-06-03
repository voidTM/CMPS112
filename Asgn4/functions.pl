


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

/*calculate flight time from one airport to another? */

find_arrival_time(departure_time, distance, arrival_time) :-
	travel_time is distance / 500,
	/* convert travel hours to date time format */
	travel_hours is floor(travel_time),
	minutes is (travel_time - travel_hours) / 60,
	travel_minutes is floor(minutes),
	 