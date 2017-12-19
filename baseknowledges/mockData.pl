% location( {ID-NODE}, ({LAT} , {LONG}) ) .

location( 111111111, (40.1675639 , 40.1675639) ) .
location( 222222222, (35.1674262 , 35.1675639) ) .
location( 333333333, (40.1673558 , 30.6438343) ) .
location( 444444444, (35.1675639 , 25.1675639) ) .
location( 555555555, (40.1674262 , 20.6438462) ) .
location( 666666666, (45.1673558 , 39.6438343) ) .
location( 777777777, (46.1673558 , 27.6438343) ) .
location( 888888888, (44.1674262 , 19.6438462) ) .
location( 999999999, (50.1674262 , 37.6438462) ) .
location( 101010101, (49.1673558 , 20.6438343) ) .


% connection( {ID-NODE-1} , {ID-NODE-2} ) .

connection( 111111111, 222222222 ) .
connection( 111111111, 333333333 ) .
connection( 111111111, 666666666 ) .

connection( 222222222, 111111111 ) .
connection( 222222222, 444444444 ) .

connection( 333333333, 444444444 ) .
connection( 333333333, 555555555 ) .
connection( 333333333, 666666666 ) .

connection( 444444444, 222222222 ) .
connection( 444444444, 333333333 ) .
connection( 444444444, 555555555 ) .

connection( 555555555, 333333333 ) .
connection( 555555555, 444444444 ) .
connection( 555555555, 888888888 ) .

connection( 666666666, 111111111 ) .
connection( 666666666, 333333333 ) .
connection( 666666666, 777777777 ) .
connection( 666666666, 999999999 ) .

connection( 777777777, 555555555 ) .
connection( 777777777, 666666666 ) .
connection( 777777777, 999999999 ) .
connection( 777777777, 101010101 ) .

connection( 888888888, 555555555 ) .
connection( 888888888, 101010101 ) .

connection( 999999999, 666666666 ) .
connection( 999999999, 101010101 ) .

connection( 101010101, 777777777 ) .
connection( 101010101, 888888888 ) .
connection( 101010101, 999999999 ) .


% location 333333333, departure time 10:00h 
departure( (armazem_boa_vista, 40.1673558, 30.6438343, 600) ) .

pharmacies( [
    % location 999999999 (16:00h limit)
    (saude_primeiro, 50.1674262, 37.6438462, 960) ,

    % location 666666666
    (vida_saudavel, 45.1673558, 39.6438343, 0) ,

    % unkown location
    (fake_location, -1.1234567, -1.1234567, 0) ,

    % location 222222222 (12:00 limit)
    (cruz_da_Vida, 35.1674262, 35.1675639, 720) ,

    % location 555555555
    (anel_vital, 40.1674262, 20.6438462, 0)
] ) .