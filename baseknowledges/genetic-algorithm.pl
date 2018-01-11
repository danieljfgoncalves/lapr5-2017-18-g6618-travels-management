% ########## DYNAMIC FACTS ########## %
% Imports random lib
:- use_module(library(random)).
% Consults mockData
% FIXME: remove after testing
:- (consult(mockData2)).
% directions(Orig, Dest, Route, Distance)
:- (dynamic directions/4).
% departure(ID, Name, (Lat,Lon),Time)
:- (dynamic departure/4).
% pharmacy(ID, Name, (Lat,Lon), Shift) [Shift: 0 - Morning, 1 - Afternoon]
:- (dynamic pharmacy/4).
% pharmacies(Number)
:- (dynamic pharmacies/1).
% location(NodeID, (Lat, Lon))
:- (dynamic location/2).
% connection(from (NodeID), to (NodeID)) -> unidirected
:- (dynamic connection/2).

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %

% ########## CONSTANTS ########## %
% ---- MISC ---- %
% The constant velocity in km/h.
velocity(50).
% Algorithm search limit
search_limit(2000).
% Morning/Afternoon Separation (Hour of day)
shift_change(12).

% ---- GENETIC ALGORITHM ---- %
% Starting Population
population(20).
% # of generations
generations(1000).
% Crossing Probability
crossing_prob(0.3).
% Mutation Probability
mutation_prob(0.04).

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %

% ########## ALGORITHM PREPARATION ########## %

% Delivery Plan
% planTravel(  ,
%             [(PharName, PharLat, PharLon, LimitTime) | Tpha] ,
%             Plan ).
% planTravel( -Departure, -Pharmacies, +Plan )
%
% Departure = ( DepName, DepLat, DepLon, DepTime )
% Pharmacies = [ (PharName, PharLat, PharLon, TimeWindow) | T ]
%
planTravel(Departure, Pharmacies, Plan) :-
    assert_departure(Departure),
    assert_pharmacies(Pharmacies, NotFound),
    genetic_algorithm(PharmacyIDsRoute, TotalDistance),
    route_with_waypoints(PharmacyIDsRoute, WaypointIDs),
    route_output(PharmacyIDsRoute, Route),
    waypoints_output(WaypointIDs, Waypoints),
    Plan=(TotalDistance, Route, Waypoints, NotFound),!.

% Build Plan Output
route_output(IDs,List):-
    IDs=[DepID|Others],
    departure(DepID,DepName,(DepLat,DepLon),_),
    append(Others1,[DepID],Others),
    Orig=(DepName,DepLat,DepLon,0),
    pharmacies_output2(Others1,[],List1),
    append([Orig],List1,List2),
    append(List2,[(DepName,DepLat,DepLon,1)],List),!.
pharmacies_output2([ID|[]],Aux,List):-
    pharmacy(ID,Name,Coord,Shift),
    Coord=(Lat,Lon),
    Output=(Name,Lat,Lon,Shift),
    append(Aux,[Output],List1),
    List=List1.
pharmacies_output2([ID,ID2|Other], Aux, List) :-
    pharmacy(ID,Name,Coord,Shift),
    Coord=(Lat,Lon),
    Output=(Name,Lat,Lon,Shift),
    append(Aux,[Output],Aux2),
    pharmacies_output2([ID2|Other],Aux2,List),! .

waypoints_output(IDs,List):-
    waypoints_output2(IDs,[],List).
waypoints_output2([],List,List):-!.
waypoints_output2([ID|Other],Aux,List) :-
    location(ID,Output),
    append(Aux,[Output],Aux2),
    waypoints_output2(Other,Aux2,List),!.

% Check & assert departure location
assert_departure(Dep) :-
    retractall(departure(_, _, _, _)),
    Dep=(Name, (Lat, Lon), Time),
    location(ID,  (Lat, Lon)),
    assertz(departure(ID, Name,  (Lat, Lon), Time)).

% Assert all pharmacies with orders, and list if not found
assert_pharmacies(PharmacyList, NotFound) :-
    retractall(pharmacy(_, _, _, _)),
    assert_pharmacies2(PharmacyList, NotFound).
assert_pharmacies2([], []) :- !.
assert_pharmacies2([Pharmacy|T], NotFound) :-
    Pharmacy=(Name, (Lat, Lon), Time),
    location(ID,  (Lat, Lon)),
    decide_shift(Time, Shift),
    assertz(pharmacy(ID, Name,  (Lat, Lon), Shift)),
    assert_pharmacies2(T, NotFound), !.
assert_pharmacies2([Pharmacy|T], [Pharmacy|NotFound]) :-
    assert_pharmacies2(T, NotFound).

% Decides the shift of delivery.
decide_shift(TimeWindow, Shift) :-
    shift_change(SC1),
    SC is SC1*60,
    (
        TimeWindow < SC,!,
        Shift is 0
        ;
        Shift is 1
    ).

% Counts all pharmacy facts
count_pharmacies(Num) :-
    findall(X, pharmacy(X,_,_,_), PL),
    length(PL, Num).

% Add waypoints to route
route_with_waypoints(Route, Route2) :-
    route_with_waypoints2(Route, [], Route2).
route_with_waypoints2([Last], R1, Route) :- !,
    append(R1, [Last], Route).
route_with_waypoints2([H1, H2|T], R1, Route) :-
    shortest_route(H1, H2, RAux),
    reverse(RAux, [H2|RAux2]),
    reverse(RAux2, RAux3),
    append(R1, RAux3, R2),
    route_with_waypoints2([H2|T], R2, Route).

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %

% ########## GENETIC ALGORITHM ########## %
genetic_algorithm(Route, Distance) :-
    count_pharmacies(N),
    retractall(pharmacies(_)),
    assert(pharmacies(N)),
    generate_pop(Pop),
    evaluate_pop(Pop, PopEv),
    sort(PopEv, PopOrd),
    fit_selection(PopOrd,FitPop),
    generations(NG),
    generate_gen(NG, FitPop, Best),
    Best=_*RouteAux,
    delete(RouteAux,'*',Route1),
    departure(Dep,_,_,_),
    append([Dep|Route1], [Dep], Route),
    calculate_route_distance(Route,Distance), !.

% Generate population of individuals (random solutions)
generate_pop(Pop) :-
    population(SizePop),
    % ########## Generate 1Ind from the greedy heuristic ########## %
    greedy_individual(GreedyInd),
    % ########## Generate 1Ind from the greedy heuristic ########## %
    findall(Pharmacy, pharmacy(Pharmacy,_,_,0), MorningList),
    findall(Pharmacy, pharmacy(Pharmacy,_,_,1), AfternoonList),
    generate_pop2(SizePop-1, MorningList, AfternoonList, Pop1),
    append(Pop1,[GreedyInd],Pop),!.
generate_pop2(0, _,_, []) :- !.
generate_pop2(SizePop, MorningList, AfternoonList, [Ind|Others]) :-
    SizePop1 is SizePop-1,
    generate_pop2(SizePop1, MorningList, AfternoonList, Others),
    repeat,
    generate_ind(MorningList, AfternoonList, Ind),
    \+ member(Ind, Others).
generate_ind(MorningList, AfternoonList, Ind) :-
    random_permutation(MorningList, Ind1),
    random_permutation(AfternoonList, Ind2),
    append(Ind1,['*'],Ind3),
    append(Ind3, Ind2, Ind).
% Greedy individual (solution)
greedy_individual(Ind) :-
    count_pharmacies(CAux),
    Count is CAux+1,
    departure(Orig,_,_,_),
    greedy_tsp2(Count, Orig,  (0, [Orig]), [_|Ind1], _),
    separate_route_shifts(Ind1,'*',Ind).

separate_route_shifts(Route,Sep,New):-
    append(M,A,Route),
    A=[First|_],
    pharmacy(First,_,_,1),!,
    append(M,[Sep],Route1),
    append(Route1,A,New).

% Crossover
crossover([], []).
crossover([_*Ind], [Ind]).
crossover([_*Ind1, _*Ind2|Other], [NInd1, NInd2|Other1]) :-
    split(Ind1, '*', Ind1M, Ind1A),
    split(Ind2, '*', Ind2M, Ind2A),
    findall(0, pharmacy(_, _, _, 0), MorningList),
    length(MorningList,NM),
    pharmacies(TP),
    NA is TP - NM,
    generate_cutpoints(P1M, P2M, NM),
    generate_cutpoints(P1A, P2A, NA),
    crossing_prob(Pcross),
    (   maybe(Pcross), !,
        cross(Ind1M, Ind2M, P1M, P2M, NM, NInd1M),
        cross(Ind1A, Ind2A, P1A, P2A, NA, NInd1A),
        cross(Ind2M, Ind1M, P1M, P2M, NM, NInd2M),
        cross(Ind2A, Ind1A, P1A, P2A, NA, NInd2A),
        append(NInd1M,['*'],NInd1M1),
        append(NInd1M1,NInd1A,NInd1),
        append(NInd2M,['*'],NInd2M1),
        append(NInd2M1,NInd2A,NInd2)
    ;   NInd1=Ind1,
        NInd2=Ind2
    ),
    crossover(Other, Other1).
% crossover utility function [ ordered crossover ]
cross(Ind1, Ind2, P1, P2, NumT, NInd1) :-
    sublist(Ind1, P1, P2, Sub1),
    R is NumT-P2-1,
    rotate_right(Ind2, R, Ind21),
    delete_elements(Ind21, Sub1, Sub2),
    insert_list(Sub2, Sub1, P2-P1+1, NIndAux),
    rotate_right(NIndAux, P1, NInd1).

% Mutation [ Swap Mutation ]
mutation([], []).
mutation([Ind|Rest], [NInd|Rest1]) :-
    split(Ind, '*', IndM, IndA),
    mutation_prob(Pmut),
    (   maybe(Pmut), !,
        mutation1(IndM, NIndM),
        mutation1(IndA, NIndA),
        append(NIndM,['*'],NIndM1),
        append(NIndM1,NIndA,NInd)
    ;   NInd=Ind
    ),
    mutation(Rest, Rest1).
mutation1(Ind, NInd) :-
    length(Ind,NP),
    random_indexes(P1, P2, NP),
    mutation2(Ind, P1, P2, NInd).
mutation2([G1|Ind], 1, P2, [G2|NInd]) :- !,
    P21 is P2-1,
    mutation3(G1, P21, Ind, G2, NInd).
mutation2([G|Ind], P1, P2, [G|NInd]) :-
    P11 is P1-1,
    P21 is P2-1,
    mutation2(Ind, P11, P21, NInd).
mutation3(G1, 1, [G2|Ind], G2, [G1|Ind]) :- !.
mutation3(G1, P, [G|Ind], G2, [G|NInd]) :-
    P1 is P-1,
    mutation3(G1, P1, Ind, G2, NInd).

% Evaluate population
evaluate_pop([], []).
evaluate_pop([Ind|Other], [D*Ind|Other1]) :-
    delete(Ind,'*',Ind1),
    eval(Ind1, D),
    evaluate_pop(Other, Other1).
eval(Route, D) :-
    departure(Dep,_,_,_),
    append([Dep|Route], [Dep], Route1),
    estimate_route_distance(Route1, D), !.
eval(_, 'NA').

% Generate generations (iterations)
generate_gen(0, [Best|_], Best) :- !.
generate_gen(G, Pop, Best) :-
    crossover(Pop, NPop1),
    mutation(NPop1, NPop),
    evaluate_pop(NPop, NPopEv),
    append(Pop, NPopEv, New),
    sort(New, NPopEvOrd),
    fit_selection(NPopEvOrd,FitPop),
    G1 is G-1,
    generate_gen(G1, FitPop, Best).

% Generates random cutpoints for individual
generate_cutpoints(P1, P2, NP) :-
    mod(NP, 2, Mod),
    Alt is abs(Mod-1),
    Max1 is NP div 2,
    random_between(0, Max1, P1),
    P2 is P1+NP div 2-Alt.

% Generates random indexes for individual genes
random_indexes(P1, P2, NP) :-
    repeat,
    random_between(1, NP, P1),
    random_between(1, NP, P2),
    P1<P2, !.

% Select the N Fittest Population Only.
fit_selection(OrdPop,FitPop) :-
    population(Size),
    sublist(OrdPop,0,Size-1,FitPop).

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %

% ########## GREEDY ALGORITHM ########## %

% Greedy TSP [Based on bestFS with no estimation]
greedy_tsp(Route, Distance) :-
    count_pharmacies(CAux),
    Count is CAux+1,
    departure(Orig,_,_,_),
    greedy_tsp2(Count, Orig,  (0, [Orig]), Route1, _),
    append(Route1,[Orig],Route),
    calculate_route_distance(Route,Distance),
    !.
greedy_tsp2(Count, _,  (Distance, LAux), Route, Distance) :-
    length(LAux, CountAux),
    Count=CountAux, !,
    reverse(LAux, Route).
greedy_tsp2(Count, Orig,  (Da, LAux), Route, Distance) :-
    LAux=[Curr|_],
    findall((Shift,DaX, [X|LAux]),
            ( pharmacy(X,_,_,Shift),
              \+ member(X, LAux),
              calculate_distance(Curr, X, DX),
              DaX is DX+Da
            ),
            New),
    sort(New, OrdNew),
    OrdNew=[(_,DBetter, Better)|_],
    greedy_tsp2(Count, Orig,  (DBetter, Better), Route, Distance).

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %

% ########## A* ALGORITHM [SHORTEST PATH] ########## %

% finds the shortest path between 2 locations
a_star(Orig, Dest, Route, Distance) :-
    a_star2(0, Dest, [(_, 0, [Orig])], Route, Distance).
% stop condition [ Destination being the last selected node ]
a_star2(_, Dest, [(_, Distance, [Dest|T])|_], Route, Distance) :-
    reverse([Dest|T], Route), !.
% stops if algorithm reaches a search limit and applies a estimation to the destination
a_star2(It, Dest, [(_, DAux, [H|T])|_], Route, Distance) :-
    search_limit(SL),
    SL=It,
    calculate_distance(H, Dest, DAux2),
    Distance is DAux+DAux2,
    reverse([Dest|[H|T]], Route), !.
% main a* search loop
a_star2(C, Dest, [(_, DAux, LAux)|Others], Route, Distance) :-
    LAux=[Curr|_],
    findall((DeX, DaX, [X|LAux]),
            ( Dest\==Curr,
              connection(Curr, X),
              \+ member(X, LAux),
              calculate_distance(Curr, X, DistX),
              DaX is DistX+DAux,
            % euclidean_heuristic(X, Dest, EstX), [ optional heuristic ]
              calculate_distance(X, Dest, EstX),
              DeX is DaX+EstX
            ),
            New),
    append(Others, New, All),
    sort(All, OrdAll),
    C1 is C+1,
    a_star2(C1, Dest, OrdAll, Route, Distance), !.
% in case algorithm enters a loop on the map, applies estimation to destination
a_star2(_, Dest, [(_, DAux, LAux)|Others], Route, Distance) :-
    search_limit(SL),
    a_star2(SL, Dest, [(_, DAux, LAux)|Others], Route, Distance).

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %

% ########## DISTANCE CALCULATORS ########## %

% Euclidean Distante Heurstics:
% Admissable heuristic to estimate a cost to the destination location.
euclidean_heuristic(Orig, Dest, Estimate) :-
    location(Orig,  (X1, Y1)),
    location(Dest,  (X2, Y2)),
    Estimate is sqrt((X1-X2)^2+(Y1-Y2)^2).

% Estimates the route distance [ from node to node ].
estimate_route_distance(Route, Distance) :-
    estimate_route_distance2(Route, 0, Distance).
estimate_route_distance2([_], Distance, Distance) :- !.
estimate_route_distance2([A, B|Others], DAux, Distance) :-
    calculate_distance(A, B, DAux2),
    DAux3 is DAux+DAux2,
    estimate_route_distance2([B|Others], DAux3, Distance).

% Calculates the route distance and records the route as a
% fact [directions(Orig, Dest, Route, Distance)]
calculate_route_distance(Route, Distance) :-
    calc_route_dist2(Route, 0, Distance).
calc_route_dist2([_], Distance, Distance) :- !.
calc_route_dist2([A, B|Others], DAux, Distance) :-
    shortest_distance(A, B, DAux2),
    DAux3 is DAux+DAux2,
    calc_route_dist2([B|Others], DAux3, Distance).

% Consult shortest path [distance & directions] between nodes or calculate path.
shortest_route(Orig, Dest, Route) :-
    directions(Orig, Dest, Route, _),!.
shortest_route(Orig, Dest, Distance) :-
    a_star(Orig, Dest, Route, Distance),
    assertz(directions(Orig, Dest, Route, Distance)).
shortest_distance(Orig, Dest, Distance) :-
    directions(Orig, Dest, _, Distance), !.
shortest_distance(Orig, Dest, Distance) :-
    a_star(Orig, Dest, Route, Distance),
    assertz(directions(Orig, Dest, Route, Distance)).

% Calculates the distance (meters) between two locations.
calculate_distance(ID1, ID2, Distance) :-
    location(ID1,  (Lat1, Lon1)),
    location(ID2,  (Lat2, Lon2)),
    calculate_distance((Lat1, Lon1),  (Lat2, Lon2), Distance).
calculate_distance((Lat1, Lon1),  (Lat2, Lon2), Distance) :-
    distance(Lat1, Lon1, Lat2, Lon2, Distance).
% Calculates distance in meters between two linear coordinates
distance(Lat1, Lon1, Lat2, Lon2, Dis) :-
    degrees2radians(Lat1, Psi1),
    degrees2radians(Lat2, Psi2),
    DifLat is Lat2-Lat1,
    DifLon is Lon2-Lon1,
    degrees2radians(DifLat, DeltaPsi),
    degrees2radians(DifLon, DeltaLambda),
    A is sin(DeltaPsi/2)*sin(DeltaPsi/2)+cos(Psi1)*cos(Psi2)*sin(DeltaLambda/2)*sin(DeltaLambda/2),
    C is 2*atan2(sqrt(A), sqrt(1-A)),
    Dis1 is 6371000*C,
    Dis is round(Dis1).
degrees2radians(Deg, Rad) :-
    Rad is Deg*0.0174532925.
% FIXME: Review if conversion to linear coords are necessary
linearCoord(IDlocation, X, Y) :-
    location(IDlocation,  (Lat, Lon)),
    geo2linear(Lat, Lon, X, Y).
geo2linear(Lat, Lon, X, Y) :-
    degrees2radians(Lat, LatR),
    degrees2radians(Lon, LonR),
    X is round(6371*cos(LatR)*cos(LonR)),
    Y is round(6371*cos(LatR)*sin(LonR)).

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %

% ########## UTILITY FUNCTIONS ########## %

% ---- TIME CONVERSION ---- %
% Calculates how much time (minutes) it takes to
% travel a given distance (meters).
travel_time(Distance, Time) :-
    velocity(Velocity),
    km_per_hour_to_meter_per_minute(Velocity, VelocityMetersPerMinute),
    Time is Distance/VelocityMetersPerMinute.
% Converts from kilometers per hour to
% meters per minute.
%
% 1 km/h ~~ 16.6667 m/min
km_per_hour_to_meter_per_minute(KmH, MMin) :-
    MMin is KmH*16.6666667.

% ---- MATH FUNCTIONS ---- %
mod(Num1, Num2, NumR) :-
    NumR is Num1-Num1 div Num2*Num2.

% ---- DATA STRUCTURES FUNCTION ---- %
sublist(L, M, N, S) :-
    sublist2(1, L, M, N, S).
sublist2(_, [], _, _, []) :- !.
sublist2(I, [X|Xs], M, N, [X|Ys]) :-
    M1 is M+1,
    N1 is N+1,
    between(M1, N1, I),
    J is I+1, !,
    sublist2(J, Xs, M, N, Ys).
sublist2(I, [_|Xs], M, N, Ys) :-
    J is I+1,
    sublist2(J, Xs, M, N, Ys).

split(List, E, P, S) :-
    append(P, S1, List),
    S1=[E|S], !.

rotate_left(List, Num, Rotated) :-
    length(List, Length),
    mod(Num, Length, Num1),
    rotate_left2(List, Num1, Rotated).
rotate_left2(List, 0, Rotated) :- !,
    Rotated=List.
rotate_left2(List, Num, Rotated) :-
    Num1 is Num-1,
    rotate_left_once(List, Rotated1),
    rotate_left2(Rotated1, Num1, Rotated).
rotate_left_once([H|T], R) :-
    append(T, [H], R).

rotate_right(List, Num, Rotated) :-
    length(List, Length),
    mod(Num, Length, Num1),
    rotate_right2(List, Num1, Rotated).
rotate_right2(List, 0, Rotated) :- !,
    Rotated=List.
rotate_right2(List, Num, Rotated) :-
    Num1 is Num-1,
    rotate_right_once(List, Rotated1),
    rotate_right2(Rotated1, Num1, Rotated).
rotate_right_once(List, Rotated) :-
    append(LeftPrefix, [Last], List),
    Rotated=[Last|LeftPrefix], !.

% insert_list(Sub,List,Pos,R)
insert_list([], R, _, R).
insert_list([E|T], List, Pos, R) :-
    Pos1 is Pos+1,
    insert_element(E, List, Pos1, Aux),
    insert_list(T, Aux, Pos1, R).
% insert_element(Element,List,Pos,Result)
insert_element(E, [H|List], Pos, [H|Res]) :-
    Pos>1, !,
    Pos1 is Pos-1,
    insert_element(E, List, Pos1, Res).
insert_element(E, List, 1, [E|List]).

% delete_elements(List,Sub,R)
delete_elements(R, [], R).
delete_elements(List, [E|T], R) :-
    delete(List, E, R1),
    delete_elements(R1, T, R), !.

% ---- DEBUGING ---- %
% Test Algorithm's Execution Time.
test_algorithm(Algorithm) :-
    get_time(TimeStampA),
    Algorithm,
    get_time(TimeStampB),
    ElapsedTimeStamp is TimeStampB-TimeStampA,
    ansi_format([faint], '~s', ['~exec_time = ']),
    time_color(ElapsedTimeStamp).
time_color(Time) :-
    Time>5,
    atomics_to_string([Time, ' secs'], Text),
    ansi_format([bold, fg(red)], '~s', [Text]), !.
time_color(Time) :-
    Time=<5,
    Time>1,
    atomics_to_string([Time, ' secs'], Text),
    ansi_format([bold, fg(yellow)], '~s', [Text]), !.
time_color(Time) :-
    Time=<1,
    atomics_to_string([Time, ' secs'], Text),
    ansi_format([bold, fg(green)], '~s', [Text]), !.

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ %
