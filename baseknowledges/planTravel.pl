%
% Calculates the travel plan to deliver medicines' parcels.
% (The entry point)
%
%
% Input (parameters):
% 
% Departure: The departure location, same as (DepName, DepLat, DepLon, DepTime)
%     DepName: The name of the departure location (and arrival)
%     DepLat: The latitude of the departure location
%     DepLon: The longitude of the departure location
%     DepName: The departure time (in minutes)
%
% Pharmacies: The pharmacies to deliver, same as [ (PharName, PharLat, PharLon, LimitTime) | Tpha ]
%     PharName: The name of the pharmacy
%     PharLat: The latitude of the pharmacy
%     PharLon: The longitude of the pharmacy
%     LimitTime: The limit time for the deliver (0 in case there is no restriction)
%     Tpha: More pharmacies, tail of the pharmacies' list
%
% Output (return):
%
% Plan: The ordered list of the pharmacies to deliver, in the format:
%     [ (DelPharName, DelPharLat, DelPharLon, DelPharTime), Tdelphar]
%     DelPharName: The name of the pharmacy to deliver
%     DelPharLat: The latitude of the pharmacy to deliver
%     DelPharLon: The longitude of the pharmacy to deliver
%     DelPharTime: The expected delivery time
%     Tdelphar: More pharmacies to deliver, tail of the deliveries pharmacies' list (ordered)
%
% planTravel( Departure, Pharmacies, Plan ).
% planTravel( (DepName, DepLat, DepLon, DepTime) , [(PharName, PharLat, PharLon, LimitTime) | Tpha] , Plan) .


% ########## CONSTANTS ########## %

% The velocity that the supplier travels in km/h
velocity( 50 ) .

% ########## UTIL METHODS ########## %

%
% Calculates the distance (meters) and time (minutes) to
% travel between two locations.
%
calculateCost(ID1, ID2, Distance, Time) :-
    location(ID1, (Lat1,Lon1) ) ,
    location(ID2, (Lat2,Lon2) ) ,
    calculateCost( (Lat1,Lon1) , (Lat2,Lon2), Distance, Time) .

calculateCost( (Lat1,Lon1), (Lat2,Lon2), Distance, Time) :-
    distance(Lat1, Lon1, Lat2, Lon2, Distance) ,
    timeToTravelDistance(Distance, Time) .

%
% Calculates how much time it takes (minutes) to
% travel a given distance (meters).
%
timeToTravelDistance(Distance, Time) :-
    velocity(Velocity) ,
    kmHourToMeterMinutes(Velocity, VelocityMetersPerMinutes) ,
    Time is Distance / VelocityMetersPerMinutes .

%
% Converts from kilometers per hour to
% meters per minute.
%
% 1 km/h ~~ 16.6667 m/min
%
kmHourToMeterMinutes(KmH, MMin) :-
    MMin is KmH * 16.6667 .

%
% Calculates distance in meters between two linear coordinates
%
distance(Lat1, Lon1, Lat2, Lon2, Dis) :-
	degrees2radians(Lat1, Psi1) ,
	degrees2radians(Lat2, Psi2) ,
	DifLat is Lat2 - Lat1 ,
	DifLon is Lon2 - Lon1 ,
	degrees2radians(DifLat, DeltaPsi) ,
	degrees2radians(DifLon, DeltaLambda) ,
	A is sin(DeltaPsi/2) * sin(DeltaPsi/2) + cos(Psi1) * cos(Psi2) * sin(DeltaLambda/2) * sin(DeltaLambda/2) ,
	C is 2 * atan2(sqrt(A), sqrt(1-A)) ,
	Dis1 is 6371000*C ,
	Dis is round(Dis1) .

degrees2radians(Deg, Rad) :-
	Rad is Deg * 0.0174532925 .

linearCoord(IDlocation, X, Y) :-
    location(IDlocation, (Lat, Lon) ) ,
    geo2linear(Lat, Lon, X, Y) .

geo2linear(Lat, Lon, X, Y) :-
    degrees2radians(Lat, LatR) ,
    degrees2radians(Lon, LonR) ,
    X is round( 6371 * cos(LatR) * cos(LonR) ) ,
    Y is round( 6371 * cos(LatR) * sin(LonR) ) .