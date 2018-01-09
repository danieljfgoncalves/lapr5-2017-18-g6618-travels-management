% ########## DEBUG ######### %
start(R, C, D) :-
    % a_star(0,4,R,D).
%     % cross([1, 2, 3, 4, 5, 6, 7, 8, 9], [4, 5, 2, 1, 8, 7, 6, 9, 3], 3, 6, R)
%     % cross([8,4,7,3,6,2,5,1,9,0],[0,1,2,3,4,5,6,7,8,9],3,7,R),
%     % mutation1([m1,2,3,4,5],R),
%     % write(R).
    % greedy_tsp(292355485,R,C,D).
    % generate(R,D),
    a_star(292355485,4446126375,R,D),
    % a_star(5275395620,2232230089,R,D),
    % a_star(130218797,2232230089,R,D),
    C is 1.

% ########## TESTING KNOWLEDGE BASE ########## %

% location(NodeID, (Lat, Lon))
% connection(from (NodeID), to (NodeID)) -> unidirected

departure(292355485).
pharmacy(292622149). % Good
pharmacy(292622257). % Good
pharmacy(3029190238). % Good
pharmacy(1295095796). % Good
pharmacy(292782840). % Good
pharmacy(3029278619). % Good
pharmacy(1520378731).
pharmacy(2232230230).
pharmacy(130219240).
pharmacy(2232230277).
pharmacy(278487441).
pharmacy(3397148312).
pharmacy(130218795).
pharmacy(130219244).
pharmacy(277374296).


% [3,6,7,10]

% ########## DYNAMIC FACTS ########## %
 :-
    (consult(mockData2)).
 :-
    (dynamic directions/4).
 :-
    (dynamic pharmacy/1).
 :-
    (dynamic pharmacies/1).
 :-
    (dynamic location/2).
 :-
    (dynamic connection/2).

% ########## CONSTANTS ########## %

% The velocity that the supplier travels in km/h.
velocity(50).

% ########## ALGORITHMS ########## %

% Euclidean Distante Heurstics:
% Admissable heuristic to estimate a cost to the destination location.
euclidean_heuristic(Orig, Dest, Estimate) :-
    location(Orig,  (X1, Y1)),
    location(Dest,  (X2, Y2)),
    Estimate is sqrt((X1-X2)^2+(Y1-Y2)^2).

% A* Algorithm to find shortest path between 2 locations
a_star(Orig, Dest, Route, Distance) :-
    a_star2(0,Dest, [(_, 0, [Orig])], Route, Distance).
a_star2(_, Dest, [(_, Distance, [Dest|T])|_], Route, Distance) :-
    reverse([Dest|T], Route), !.
a_star2(5000, Dest, [(_, DAux, [H|T])|_], Route, Distance) :-
    calculate_distance(H, Dest, DAux2),
    Distance is DAux+DAux2,
    reverse([Dest|T], Route),!.
a_star2(C,Dest, [(_, DAux, LAux)|Others], Route, Distance) :-
    LAux=[Curr|_],
    findall((DeX, DaX, [X|LAux]),
            ( Dest\==Curr,
              connection(Curr, X),
              \+ member(X, LAux),
              calculate_distance(Curr, X, DistX),
              DaX is DistX+DAux,
            % euclidean_heuristic(X, Dest, EstX),
              calculate_distance(X, Dest, EstX),
              DeX is DaX+EstX
            ),
            New),
    append(Others, New, All),
    sort(All, OrdAll),
    C1 is C + 1,
    a_star2(C1,Dest, OrdAll, Route, Distance), !.
a_star2(_,Dest, [(_, DAux, LAux)|Others], Route, Distance) :-
    a_star2(5000,Dest, [(_, DAux, LAux)|Others], Route, Distance).

% Consult shortest path [distance & directions] between pharmacies or calculate path.
shortest_distance(Orig, Dest, Distance) :-
    directions(Orig, Dest, _, Distance), !.
shortest_distance(Orig, Dest, Distance) :-
    a_star(Orig, Dest, Route, Distance),
    assertz(directions(Orig, Dest, Route, Distance)).

% Assert all pharmacies with orders
assert_pharmacies([]):- !.
assert_pharmacies([H|T]):-
    assertz(pharmacy(H)),
    assert_pharmacies(T).

route_with_directions(Route, Route2) :-
    route_with_directions2(Route, [], Route2).
route_with_directions2([Last|[]], R1, Route):- !,
    append(R1,[Last],Route).
route_with_directions2([H1, H2|T], R1, Route) :-
    directions(H1, H2, RAux, _),
    reverse(RAux, [H2|RAux2]),
    reverse(RAux2, RAux3),
    append(R1, RAux3, R2),
    route_with_directions2([H2|T], R2, Route).

% % Plan delivery
% plan(Orig, Pharmacies, Route, Distance, Time) :-
%     retractall(pharmacy(_)),
%     assert_pharmacies(Pharmacies),
%     greedy_tsp(Orig, Route1, Distance),
%     travel_time(Distance, Time),
%     route_with_directions(Route1, Route).
%     % TODO: Convert ids to coords

count_pharmacies(Num) :-
    findall(X, pharmacy(X), PL),
    length(PL, Num).

% Greedy TSP [Based on bestFS with no estimation]
greedy_tsp(Orig, Route, CompleteRoute, Distance) :-
    count_pharmacies(CAux),
    Count is CAux+1,
    greedy_tsp2(Count, Orig,  (0, [Orig]), Route),
    calculate_route_distance(Route,Distance),
    route_with_directions(Route, CompleteRoute),!.

% greedy_tsp2(Count, Orig, (_, LAux), Route, Distance) :-
greedy_tsp2(Count, Orig, (_, LAux), Route) :-
    length(LAux,CountAux),
    Count=CountAux, !,
    % LAux=[Last|_],
    % shortest_distance(Last, Orig, DLast),
    % Distance is Da+DLast,
    reverse([Orig|LAux], Route).
    % calculate_route_distance(Route,Distance).
% greedy_tsp2(Count, Orig, (Da, LAux), Route, Distance) :-
greedy_tsp2(Count, Orig, (Da, LAux), Route) :-
    LAux=[Curr|_],
    findall(
        (DaX, [X|LAux]),
        (
            pharmacy(X),
            \+ member(X, LAux),
            %
            % TODO: Check if time window is still valid,
            % if not, retract pharmacy. [later consider not visited]
            %
            %shortest_distance(Curr, X, DX),
            calculate_distance(Curr, X, DX),
            DaX is DX+Da
        ),
        New
    ),
    sort(New, OrdNew),
    OrdNew=[(DBetter, Better)|_],
    % greedy_tsp2(Count, Orig, (DBetter, Better), Route, Distance).
    greedy_tsp2(Count, Orig, (DBetter, Better), Route).

% ########## UTILITY FUNCTIONS ########## %

%
%   Calculate the routes distance.
%
calculate_pharmacies_distance(Route, Distance) :-
    calculate_pharmacies_distance2(Route, 0, Distance).
calculate_pharmacies_distance2([_], DAux, Distance) :- !,
    Distance is DAux.
calculate_pharmacies_distance2(Route, DAux, Distance) :-
    Route=[A, B|Others],
    calculate_distance(A, B, DAux2),
    DAux3 is DAux+DAux2,
    calculate_pharmacies_distance2([B|Others], DAux3, Distance).


calculate_route_distance(Route, Distance) :-
    calc_route_dist2(Route, 0, Distance).
calc_route_dist2([_], DAux, Distance) :- !,
    Distance is DAux.
calc_route_dist2(Route, DAux, Distance) :-
    Route=[A, B|Others],
    shortest_distance(A, B, DAux2),
    DAux3 is DAux+DAux2,
    calc_route_dist2([B|Others], DAux3, Distance).

%
% Calculates the distance (meters) between two locations.
%
calculate_distance(ID1, ID2, Distance) :-
    location(ID1,  (Lat1, Lon1)),
    location(ID2,  (Lat2, Lon2)),
    calculate_distance((Lat1, Lon1),  (Lat2, Lon2), Distance).

calculate_distance((Lat1, Lon1),  (Lat2, Lon2), Distance) :-
    distance(Lat1, Lon1, Lat2, Lon2, Distance).

%
% Calculates distance in meters between two linear coordinates
%
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
% FIXME: Review if conversion to linear coords are necessary
geo2linear(Lat, Lon, X, Y) :-
    degrees2radians(Lat, LatR),
    degrees2radians(Lon, LonR),
    X is round(6371*cos(LatR)*cos(LonR)),
    Y is round(6371*cos(LatR)*sin(LonR)).

%
% Calculates how much time (minutes) it takes to
% travel a given distance (meters).
%
travel_time(Distance, Time) :-
    velocity(Velocity),
    km_per_hour_to_meter_per_minute(Velocity, VelocityMetersPerMinute),
    Time is Distance/VelocityMetersPerMinute.

%
% Converts from kilometers per hour to
% meters per minute.
%
% 1 km/h ~~ 16.6667 m/min
%
km_per_hour_to_meter_per_minute(KmH, MMin) :-
    MMin is KmH*16.6666667.

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

mod(Num1, Num2, NumR):-
    NumR is Num1 - (Num1 div Num2) * Num2.

sublist(L,M,N,S) :- sublist2(1,L,M,N,S).
sublist2(_,[],_,_,[]):- !.
sublist2(I,[X|Xs],M,N,[X|Ys]) :-
    M1 is M+1,
    N1 is N+1,
    between(M1,N1,I),
    J is I + 1,
    !, sublist2(J,Xs,M,N,Ys).
sublist2(I,[_|Xs],M,N,Ys) :-
    J is I + 1,
    sublist2(J,Xs,M,N,Ys).

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
rotate_left_once([H|T],R) :-
    append(T,[H],R).

rotate_right(List, Num, Rotated) :-
    length(List, Length),
    mod(Num, Length, Num1),
    rotate_right2(List, Num1, Rotated).
rotate_right2(List, 0, Rotated ) :- !,
    Rotated=List.
rotate_right2( List, Num, Rotated ) :-
    Num1 is Num-1,
    rotate_right_once( List, Rotated1 ),
    rotate_right2( Rotated1, Num1, Rotated ).
rotate_right_once( List, Rotated ) :-
    append( LeftPrefix , [Last] , List),
    Rotated = [Last|LeftPrefix], !.

% insert_list(Sub,List,Pos,R)
insert_list([],R,_,R).
insert_list([E|T],List,Pos,R):-
    Pos1 is Pos+1,
    insert_element(E, List, Pos1, Aux),
    insert_list(T,Aux,Pos1,R).
% insert_element(Element,List,Pos,Result)
insert_element(E,[H|List],Pos,[H|Res]):-
    Pos > 1, !,
    Pos1 is Pos - 1,
    insert_element(E,List,Pos1,Res).
insert_element(E, List, 1, [E|List]).

% delete_elements(List,Sub,R)
delete_elements(R,[],R).
delete_elements(List,[E|T],R) :-
    delete(List, E, R1),
    delete_elements(R1,T,R), !.

% ########## GENETIC ALGORITHM ########## %
:- use_module(library(random)).

population(5).
generations(10).
crossing_prob(0.3).
mutation_prob(0.01).

% pharmacies(5).

%  /** Genetic algorithm **/
generate(Route, Distance) :-
    count_pharmacies(N),
    retractall(pharmacies(_)),
    assert(pharmacies(N)),
    generate_pop(Pop),
    evaluate_pop(Pop, PopEv),
    msort(PopEv, PopOrd),
    generations(NG),
    generate_gen(NG, PopOrd, Best),
    Best=Distance*Route1,
    departure(Dep),
    append([Dep|Route1],[Dep], Route),!.

%
% Generate population of individuals (random solutions)
%
generate_pop(Pop) :-
    population(SizePop),
    % ########## Generate 1Ind from the greedy heuristic ########## %
    % FIXME: Decide if necessary
    % ########## Generate 1Ind from the greedy heuristic ########## %
    findall(Pharmacy, pharmacy(Pharmacy), PharmacyList),
    generate_pop(SizePop-1, PharmacyList, Pop).
    %departure(Dep),
    %greedy_tsp(Dep,R,_,_),
    %R=[_|R1],
    %reverse(R1,R2),
    %R2=[_|R3],
    %reverse(R3,R4),
   % append(R4,Pop1,Pop).
generate_pop(0, _, []) :- !.
generate_pop(SizePop, PharmacyList, [Ind|Others]) :-
    SizePop1 is SizePop-1,
    generate_pop(SizePop1, PharmacyList, Others),
    generate_ind(PharmacyList, Ind),
    \+ member(Ind, Others).
generate_ind(PharmacyList, Ind) :-
    random_permutation(PharmacyList, Ind).

%
% Crossover [Ordered crossover]
%
crossover([], []).
crossover([_*Ind], [Ind]).
crossover([_*Ind1, _*Ind2|Other], [NInd1, NInd2|Other1]) :-
    generate_cutpoints(P1, P2),
    crossing_prob(Pcross),
    Pc is random(1),
    (   Pc=<Pcross, !,
        cross(Ind1, Ind2, P1, P2, NInd1),
        cross(Ind2, Ind1, P1, P2, NInd2)
    ;   NInd1=Ind1,
        NInd2=Ind2
    ),
    crossover(Other, Other1).

%
% order 1 crossover
%
cross(Ind1, Ind2, P1, P2, NInd1) :-
    sublist(Ind1, P1, P2, Sub1),
    pharmacies(NumT),
    R is NumT-P2-1,
    rotate_right(Ind2, R, Ind21),
    delete_elements(Ind21, Sub1, Sub2),
    insert_list(Sub2, Sub1, P2-P1+1, NIndAux),
    rotate_right(NIndAux, P1, NInd1).

mutation([], []).
mutation([Ind|Rest], [NInd|Rest1]) :-
    mutation_prob(Pmut),
    (   maybe(Pmut), !,
        mutation1(Ind, NInd)
    ;
        NInd=Ind
    ),
    mutation(Rest, Rest1).
mutation1(Ind, NInd) :-
    random_indexes(P1, P2),
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

%
% Generates random cutpoints for individual
%
generate_cutpoints(P1,P2) :-
    pharmacies(NP),
    mod(NP,2, Mod),
    Alt is abs(Mod - 1),
    Max1 is (NP div 2),
    random_between(0, Max1, P1),
    P2 is P1 + (NP div 2) - Alt.

%
% Generates random indexes for individual genes
%
random_indexes(P1, P2) :-
    pharmacies(NP1),
    NP is NP1,
    repeat,
    random_between(1, NP, P1),
    random_between(1, NP, P2),
    P1 < P2, !.

evaluate_pop([], []).
evaluate_pop([Ind|Other], [D*Ind|Other1]) :-
    eval(Ind, D),
    evaluate_pop(Other, Other1).
eval(Route, D) :-
    departure(Dep),
    append([Dep|Route], [Dep], Route1),
    calculate_pharmacies_distance(Route1, D), !.
    % calculate_route_distance(Route1, D), !.
    % TODO: Review restrictions and add time window criteria
eval(_,'NA'):-write('N-A ').

% /* Selects the best of N pseudo-randomly-chosen routes.                    */
% select(N, PopSize, Pop, Route) :-
%     select_1(N, PopSize, Pop, c(32767, []), c(_, Route)).

% select_1(0, _, _, Tour, Tour) :- !.
% select_1(N,PopulationSize, Population, Tour0, Tour) :-
%     member_rand(Population, PopulationSize, Tour1),
%     better(Tour0, Tour1, Tour2),
%     N1 is N-1,
%     select_1(N1, PopulationSize, Population, Tour2, Tour).

%
% Generate generations (iterations)
%
generate_gen(0, [Best|_], Best) :- !.
    % write('Generation '),
    % write(0),
    % write(:),
    % nl,
    % write([Best|Others]),
    % nl.
generate_gen(G,Pop, Best) :-
%    write('Generation '), write(G), write(':'), nl,
%    write(Pop), nl,
   crossover(Pop,NPop1),
   mutation(NPop1,NPop),
   evaluate_pop(NPop,NPopEv),
   append(Pop,NPopEv, New),
   sort(New,NPopEvOrd),
   G1 is G-1,
   generate_gen(G1,NPopEvOrd, Best).
