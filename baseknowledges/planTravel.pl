%
% planTravel( Departure, Pharmacies, Plan ).
% planTravel( (DepName, DepLat, DepLon, DepTime) , [(PharName, PharLat, PharLon, LimitTime) | Tpha] , Plan) .
%
% Calculates the travel plan to deliver medicines' parcels.
% (The entry point)
%
% Input (parameters):
%
% Departure: The departure location, int the following format:
%     Departure = (DepName, DepLat, DepLon, DepTime)
%     DepName: The name of the departure location (and arrival)
%     DepLat: The latitude of the departure location
%     DepLon: The longitude of the departure location
%     DepName: The departure time (in minutes)
%
% Pharmacies: The pharmacies to deliver, in the following format:
%     Pharmacies = [ (PharName, PharLat, PharLon, LimitTime) | Tpha ]
%     PharName: The name of the pharmacy
%     PharLat: The latitude of the pharmacy
%     PharLon: The longitude of the pharmacy
%     LimitTime: The limit time for the deliver (0 in case there is no restriction)
%     Tpha: More pharmacies, tail of the pharmacies' list
%
% Output (return):
%
% Plan: The pharmacies ordered by deliver, the waypoints ordered by arrival,
%       and the pharmacies not visited (couldn't accomplish the restrictions):
%       Plan = ( PharmaciesOL , WaypointsOL , PharNotVisited )
%
% PharmaciesOL: The ordered list of the pharmacies to deliver.
%     PharmaciesOL = [ (DelPharName, DelPharLat, DelPharLon, DelPharTime), Tdelphar]
%     DelPharName: The name of the pharmacy to deliver
%     DelPharLat: The latitude of the pharmacy to deliver
%     DelPharLon: The longitude of the pharmacy to deliver
%     DelPharTime: The expected delivery time
%     Tdelphar: More pharmacies to deliver, tail of the deliveries pharmacies' list (ordered)
%
% WaypointsOL: The ordered list of the waypoints (including pharmacies points) to travel.
%     WaypointsOL = [ (WpLat, WpLon) | Twp ]
%     WpLat: The latitude of the point
%     WpLon: The longitude of the point
%     Twp: The tail with the other points
%
% PharNotVisited: The list of the pharmacies not visited
%     PharNotVisited = [PharName | Tpnv]
%     PharName: The pharmacy name
%     Tpnv: The tail with the other pharmacies not visited
%
%
planTravel( Departure, Pharmacies, Plan ) :-

    % divide pharmacies found and not found
    findPharmacies( Pharmacies, PharmaciesFound, PharmaciesNotFound ) ,

    % divide pharmacies with and without time restrictions
    divideByTimeRestrictions( PharmaciesFound, PharmaciesWithRestrictions, PharmaciesWithoutRestrictions ) ,

    Departure = (_, DepLat, DepLon, DepTime) ,

    % Compile output data
    Plan = ( PharmaciesOL , WaypointsOL , PharNotVisited ) ,

    % Adding origin to Waypoints
    WaypointsOL = [ (DepLat,DepLon) | _ ] ,
    % TODO go back to departure point

    % NotVisited will be filled later
    append(PharmaciesNotFound, NotVisited, PharNotVisited) ,

    greedyPlan(PharmaciesWithRestrictions, PharmaciesWithoutRestrictions, WaypointsOL, PharmaciesOL, NotVisited) ,

    % TODO make the way back to departure location

    ! .

%
% Input (parameters):
%
% PharRestricted: Ordered List of pharmacies with time restrictions
% PharNotRestricted: Pharmacies without time restrictions
%
%
% Output (return):
%
% WaypointsOL: The list of the waypoints (first one must be already filled by input)
% ResPhar: Order list of pharmacies plan
% ResNotVisited: Pharmacies not visited
%
greedyPlan( PharRestricted, PharNotRestricted, WaypointsOL, ResPhar, ResNotVisited) :-

    % TESTME make sure it works to receive 'half' initialized
    WaypointsOL = [ CurrentLocation | Twp ] ,
    CurrentLocation = (DepLat,DepLon) ,

    % TODO complete the following predicates
    %processRestricted( ) ,
    %processNotRestricted( ) .

%
% Process the pharmacies with time restrictions
%
% processRestricted( PharRestricted, PharNotRestricted, CurrentWp, Waypoints, CurrentTime, ResPhar, ResNotVisited)
%
processRestricted( [], _, _, [], [], [], _, _) .
processRestricted( PharRestricted, PharNotRestricted, CurrentWp, Waypoints, CurrentTime, ResPhar, ResNotVisited) :-

    % TODO fill params
    %goToRestr( ) ,

    % TODO process all data returned from goto

    processRestricted( Tpr, PharNotRestricted, CurrentWp, Waypoints, CurrentTime, ResPhar, ResNotVisited ) .

processRestricted( PharRestricted, PharNotRestricted, CurrentWp, Waypoints, CurrentTime, ResPhar, [Hpr|ResNotVisited] ) :-

    processRestricted( Tpr, PharNotRestricted, CurrentWp, Waypoints, CurrentTime, ResPhar, ResNotVisited ) .

%
% Tries to go from current waypoint to next pharmacy with time restriction.
%
% goToRestr( InitialPharRestr, CurrPharRestr, NewPharRestr,
%            InitialPharNotRestr, CurrPharNotRestr, NewPharNotRestr,
%            InitialWaypoints, CurrWaypoints, NewWaypoints,
%            InitialTime, CurrTime, NewTime,
%            InitialPharPlan, CurrPharPlan, NewPharPlan,
%            InitialPharNotVisited, NewPharNotVisited )
%
%
% Input:
%
% The initial states are used as 'snapshots' to restore in case
% it won't be possible to visit target pharmacies with restrictions
% InitialPharRestr
% InitialPharNotRestr
% InitialWaypoints
% InitialTime
% InitialPharPlan
% InitialPharNotVisited
%
% The current states are used changing over the recursive calls.
% CurrPharRestr
% CurrPharNotRestr
% CurrWaypoints
% CurrTime
% CurrPharPlan
%
%
% Output:
%
% NewPharRestr
% NewPharNotRestr
% NewWaypoints
% NewTime
% NewPharPlan
% NewPharNotVisited
%

%
% Case that finds the direct connection to
% the desirable pharmacy with a valid time.
%
goToRestr( _, CurrPharRestr, NewPharRestr,
          _, CurrPharNotRestr, NewPharNotRestr,
          _, CurrWaypoints, NewWaypoints,
          _, CurrTime, NewTime,
          _, CurrPharPlan, NewPharPlan,
          InitialPharNotVisited, NewPharNotVisited ) :-

    % Get current waypoint
    last(CurrWaypoints, CurrentWp) ,
    location(IDwp, CurrentWp) ,

    % Get destination point
    CurrPharRestr = [Hpr|Tpr] ,
    Hpr = ( PharName, PharLat, PharLon, LimitTime ) ,
    PharWP = ( PharLat, PharLon ) ,
    location( IDph, PharWP ) ,

    % There is time to seek and a direct connection
    CurrTime < LimitTime ,
    connection( IDwp, IDph ) ,

    % The new time must be sufficient to deliver
    calculateCost( IDwp, IDph, _, Time ) ,
    NewTime is CurrTime + Time ,
    NewTime =< LimitTime ,

    % Set results
    NewPharmacy = (PharName, PharLat, PharLon, NewTime) ,

    NewPharRestr is Tpr ,
    NewPharNotRestr is CurrPharNotRestr ,
    append( CurrWaypoints, [PharWP], NewWaypoints ) ,
    append( CurrPharPlan, [NewPharmacy], NewPharPlan) ,
    NewPharNotVisited is InitialPharNotVisited ,

    ! .

%
% Case that is not direct connected,
% but can go to a closer neighbor.
%
goToRestr( InitialPharRestr, CurrPharRestr, NewPharRestr,
           InitialPharNotRestr, CurrPharNotRestr, NewPharNotRestr,
           InitialWaypoints, CurrWaypoints, NewWaypoints,
           InitialTime, CurrTime, NewTime,
           InitialPharPlan, CurrPharPlan, NewPharPlan,
           InitialPharNotVisited, NewPharNotVisited ) :-

    % Get current waypoint
    last(CurrWaypoints, CurrentWp) ,
    location(IDwp, CurrentWp) ,

    % Get destination point
    CurrPharRestr = [Hpr|_] ,
    Hpr = ( _, PharLat, PharLon, LimitTime ) ,
    PharWP = ( PharLat, PharLon ) ,
    location( IDph, PharWP ) ,

    % There is enough time to seek but
    % there is not a direct connection
    CurrTime < LimitTime ,
    \+ connection( IDwp, IDph ) ,

    % Finds the closest available point
    findClosestPoint( CurrentWp, PharWP, CurrWaypoints, NextWp ) ,

    % The new time must be sufficient to deliver
    calculateCost( CurrentWp, PharWP, _, Time ) ,
    NextTime is CurrTime + Time ,
    NextTime =< LimitTime ,

    % If so we can visit it already!
    comparePointToPharmacies( NextWp,
                              CurrPharRestr, NextPharRestr,
                              CurrPharNotRestr, NextPharNotRestr,
                              CurrPharPlan, NextPharPlan) ,

    % Prepare data for the next call
    append(CurrWaypoints, [NextWp], NextWaypoints) ,

    % Recursive call
    goToRestr( InitialPharRestr, NextPharRestr, NewPharRestr,
               InitialPharNotRestr, NextPharNotRestr, NewPharNotRestr,
               InitialWaypoints, NextWaypoints, NewWaypoints,
               InitialTime, NextTime, NewTime,
               InitialPharPlan, NextPharPlan, NewPharPlan,
               InitialPharNotVisited, NewPharNotVisited) ,

    ! .

%
% Case that cannot go to the pharmacy restricted in time,
% either because there is no time or connections to reach.
%
% Restores initial states and moves destination pharmacy
% to not visited list.
%
goToRestr( InitialPharRestr, _, NewPharRestr,
           InitialPharNotRestr, _, InitialPharNotRestr,
           InitialWaypoints, _, InitialWaypoints,
           InitialTime, _, InitialTime,
           InitialPharPlan, _, InitialPharPlan,
           InitialPharNotVisited, NewPharNotVisited ) :-

    InitialPharRestr = [ NextPharRestr | NewPharRestr ] ,
    append( InitialPharNotVisited, [NextPharRestr], NewPharNotVisited ) ,
    ! .

%
% Checks if a given point is contained in
% one of the plans and updates the plans.
%
% comparePointToPharmacies( Point,
%                           PharRestr, NewPharRestr,
%                           PharNotRestr, NewPharNotRestr,
%                           PharPlan, NewPharPlan)
%
comparePointToPharmacies( Point,
                          PharRestr, NewPharRestr,
                          PharNotRestr, PharNotRestr,
                          PharPlan, NewPharPlan) :-

    removesPharmacyByCoordinate( Point, PharRestr, PharRestr, NewPharRestr, PharRem ) ,
    PharRestr \== NewPharRestr ,

    append(PharPlan, [PharRem], NewPharPlan) .
comparePointToPharmacies( Point,
                          PharRestr, PharRestr,
                          PharNotRestr, NewPharNotRestr,
                          PharPlan, NewPharPlan) :-

    removesPharmacyByCoordinate( Point, PharNotRestr, PharNotRestr, NewPharNotRestr, PharRem ) ,
    PharNotRestr \== NewPharNotRestr ,

    append(PharPlan, [PharRem], NewPharPlan) .
comparePointToPharmacies( _,
                          PharRestr, PharRestr,
                          PharNotRestr, PharNotRestr,
                          PharPlan, PharPlan) .

%
% removesPharmacyByCoordinate(
%     Coordinate,
%     InitialPharmacies, Pharmacies,
%     NewPharmacies, RemovedPharmacy )
%
removesPharmacyByCoordinate( _, InitialPharmacies, [], InitialPharmacies, 0) :-
    ! .
removesPharmacyByCoordinate( Coordinate, InitialPharmacies, [Phar|_], NewPharmacies, Phar ) :-
    Phar = ( _, PharLat, PharLon, _ ) ,
    Coordinate == (PharLat, PharLon) ,
    delete( InitialPharmacies, Phar, NewPharmacies) ,
    ! .
removesPharmacyByCoordinate( Coordinate, InitialPharmacies, [_|Tphar], NewPharmacies, RemovedPharmacy ) :-
    removesPharmacyByCoordinate( Coordinate, InitialPharmacies, Tphar, NewPharmacies, RemovedPharmacy ) ,
    ! .



%
% Given an origin coordinate, finds the best coordinate point
% which gets closer to destination coordinate, without moving
% to coordinates that are already visited.
%
findClosestPoint(Orig, Dest, Visited, Point) :-

    location( IDorig, Orig ) ,

    findall(
        Coordinate,
        ( connection(IDorig, IDneig), location(IDneig, Coordinate), \+ member(Coordinate, Visited) ),
        Neighbors ) ,

    % if is not empty
    Neighbors \== [] ,

    % choose closest neighbor
    chooseClosest( Dest, Neighbors, Point ) ,

    ! .

%
% chooseClosest( Dest, [Hneig|Tneig], SmallestDistance, SmallestCoordinate, Point )
%
chooseClosest( DestinationPoint, [Hneig|Tneig], ClosestPoint ) :-
    calculateCost( Hneig, DestinationPoint, Distance, _ ) ,
    chooseClosest( DestinationPoint, Tneig, Distance, Hneig, ClosestPoint ) .

chooseClosest( _, [], _, Point, Point ) .
chooseClosest( Dest, [Hneig|Tneig], ClosestDistance, _, Point ) :-
    calculateCost( Hneig, Dest, D, _ ) ,
    D < ClosestDistance ,
    chooseClosest( Dest, Tneig, D,  Hneig, Point ) ,
    ! .
chooseClosest( Dest, [_|Tneig], ClosestDistance, ClosestCoordinate, Point ) :-
    chooseClosest( Dest, Tneig, ClosestDistance, ClosestCoordinate, Point ) .



%
% Tries to find pharmacies and divide them in
% pharmacies found and pharmacies not found.
%
findPharmacies( [], [], [] ) .
findPharmacies( [Pharmacy|Tpha], [Pharmacy|Tfound], Notfound ) :-
    Pharmacy = (_, PharLat, PharLon, _) ,
    location( _, (PharLat, PharLon) ) ,
    findPharmacies( Tpha, Tfound, Notfound ) ,
    ! .
findPharmacies( [Pharmacy|Tpha], Found, [Pharmacy|Tnotfound] ) :-
    findPharmacies( Tpha, Found, Tnotfound ) .


%
% Given a list of pharmacies, reorganize by pharmacies with and without time restrictions.
% The pharmacies with time restriction are sorted by increasing order of time.
%
divideByTimeRestrictions( Pharmacies, PharmaciesWithRestrictions, PharmaciesWithoutRestrictions ) :-
    divideByTimeRestrictions_p( Pharmacies, PharWithRest, PharmaciesWithoutRestrictions ) ,
    sortByRestrictions(PharWithRest, PharmaciesWithRestrictions) .
divideByTimeRestrictions_p( [], [], [] ) .
divideByTimeRestrictions_p( [Pharmacy|Tpha], [Pharmacy|Tr], PharmaciesWithoutRestrictions ) :-
    Pharmacy = ( _, _, _, LimitTime ) ,
    LimitTime > 0 ,
    divideByTimeRestrictions_p( Tpha, Tr, PharmaciesWithoutRestrictions ) ,
    ! .
divideByTimeRestrictions_p( [Pharmacy|Tpha], PharmaciesWithRestrictions, [Pharmacy|Tnr] ) :-
    divideByTimeRestrictions_p( Tpha, PharmaciesWithRestrictions, Tnr ) .


%
% Sort pharmacies by increasing order of time restriction.
%
sortByRestrictions( Pharmacies, SortedPharmacies ) :-
    sortByRestrictions( Pharmacies, [], SortedPharmacies ) ,
    ! .

sortByRestrictions( [], Acc, Acc ) .
sortByRestrictions( [Pharmacy|T], Acc, SortedPharmacies ) :-
    pivotingPharmacies( Pharmacy, T, L1, L2 ) ,
    sortByRestrictions( L1, Acc, Sorted1 ) ,
    sortByRestrictions( L2, [Pharmacy|Sorted1], SortedPharmacies ) .

pivotingPharmacies( _, [], [], [] ) .
pivotingPharmacies( Pharmacy1, [Pharmacy2|T], [Pharmacy2|L], G ) :-
    Pharmacy1 = ( _, _, _, Time1 ) ,
    Pharmacy2 = ( _, _, _, Time2 ) ,
    Time1 =< Time2 ,
    pivotingPharmacies( Pharmacy1, T, L, G ) ,
    ! .
pivotingPharmacies( Pharmacy1, [Pharmacy2|T], L, [Pharmacy2|G] ) :-
    pivotingPharmacies( Pharmacy1, T, L, G ) .



% ########## CONSTANTS ########## %

%
% The velocity that the supplier travels in km/h.
%
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
