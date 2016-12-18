:- dynamic onBoard/2.

onBoard(red, 0).
onBoard(red, 1).
onBoard(red, 2).
onBoard(red, 3).
onBoard(red, 4).
onBoard(red, 5).
onBoard(red, 6).
onBoard(red, 7).

onBoard(blue, 56).
onBoard(blue, 57).
onBoard(blue, 58).
onBoard(blue, 59).
onBoard(blue, 60).
onBoard(blue, 61).
onBoard(blue, 62).
onBoard(blue, 63).

/* color red = 1, blue = 2 */
countPiece(_, [], 0) :- !.

countPiece(X, [X|T], N) :-
    countPiece(X, T, N2),
    N is N2 + 1.

countPiece(X, [Y|T], N) :-
    X \= Y,
    countPiece(X, T, N).

% heuristic blue - red
getValue(Board, Value) :-
    countPiece(1, Board, Red),
    countPiece(2, Board, Blue),
    Value is Blue - Red.

% replace atom at List[Place] with Val
replace( List, Place, Val, NewList) :-
         replace(List, Place, Val, NewList, 0).

replace( [], _, _, [], _).

replace( [_|Xs], Place, Val, [Val|Ys], Place) :-
         NewCounter is Place + 1, !,
         replace(Xs, Place, Val, Ys, NewCounter).

replace( [X|Xs], Place, Val, [X|Ys], Counter) :-
         NewCounter is Counter + 1,
         replace(Xs, Place, Val, Ys, NewCounter).

% move piece at pos1 to pos2 Move is always valid
checkMove(Board, Pos1, Pos2, Color, NewBoard) :-
    replace(Board, Pos1, 0, NewBoard1), %remove piece from old pos
    replace(NewBoard1, Pos2, Color, NewBoard). %put piece in new place

eatPieces(Board, [], Board) :- !.

eatPieces(Board, [Pos|T], NewBoard) :-
    Position is Pos ,
    replace(Board, Position, 0, NewBoard1),
    eatPieces(NewBoard1, T, NewBoard).

% Color = red/blueâ€¨
getPieces(Color, ResList) :-
    findall(Output, onBoard(Color, Output), ResList).

getPieces(ResList) :-
    findall(Output, onBoard(red, Output), RedList),
    findall(Output, onBoard(blue, Output), BlueList),
    append(RedList, BlueList, ResList).


getUpMoves(AllPieces, Coord, Up) :-
    getUpMoves(AllPieces, Coord, [], Up).

getUpMoves(_, Coord, L, L):-
	Coord < 0, !.

getUpMoves(AllPieces, Coord, Temp, Up) :-
	One_up is Coord - 8,
	(
         (One_up >= 0,\+member(One_up, AllPieces)) ->
         getUpMoves(AllPieces, One_up, [One_up|Temp], Up);
         Up = Temp, !
	).

getDownMoves(AllPieces, Coord, Up) :-
    getDownMoves(AllPieces, Coord, [], Up).

getDownMoves(_, Coord, L, L):-
	Coord > 63, !.

getDownMoves(AllPieces, Coord, Temp, Up) :-
	One_up is Coord + 8,
	(
         ( One_up < 64, \+member(One_up, AllPieces) ) ->
         getDownMoves(AllPieces, One_up, [One_up|Temp], Up);
         Up = Temp, !
	).

getLeftMoves(AllPieces, Coord, Up) :-
    getLeftMoves(AllPieces, Coord, [], Up).

getLeftMoves(_, Coord, L, L):-
    One_up is Coord - 1,
	Coord//8 =\= One_up//8, !.

getLeftMoves(AllPieces, Coord, Temp, Up) :-
	One_up is Coord - 1,
	(
         ( Coord//8 =:= One_up//8, One_up >= 0, \+member(One_up, AllPieces) ) ->
         getLeftMoves(AllPieces, One_up, [One_up|Temp], Up);
         Up = Temp, !
	).

getRightMoves(AllPieces, Coord, Up) :-
    getRightMoves(AllPieces, Coord, [], Up).

getRightMoves(_, Coord, L, L):-
    One_up is Coord + 1,
	Coord//8 =\= One_up//8, !.

getRightMoves(AllPieces, Coord, Temp, Up) :-
	One_up is Coord + 1,
	(
         ( Coord//8 =:= One_up//8, One_up < 64, \+member(One_up, AllPieces) ) ->
         getRightMoves(AllPieces, One_up, [One_up|Temp], Up);
         Up = Temp, !
	).

getPosMoves(PiecePos, ResList):-
    getPieces(AllPieces),
    getUpMoves(AllPieces, PiecePos, UpMoves),
    getDownMoves(AllPieces, PiecePos, DownMoves),
    getLeftMoves(AllPieces, PiecePos, LeftMoves),
    getRightMoves(AllPieces, PiecePos, RightMoves),
    append(UpMoves,DownMoves,Res1),
    append(Res1, LeftMoves,Res2),
    append(Res2, RightMoves, AllMoves),
    sort(AllMoves, ResList).

check_insert_horizontal(Enemy, Ally, Coord, Eat_list):-
    check_insert_left(Enemy, Ally, Coord, Coord, [], Eat_list).

check_insert_left(_, _, Coord, Cur, _, []):-
    One_up is Cur - 1,
	Coord//8 =\= One_up//8, !.

check_insert_left(Enemy, Ally, Coord, Cur, Temp_eat, Eat_list):-
    One_up is Cur - 1,
    (
     (Coord//8 =:= One_up//8, One_up >= 0, member(One_up, Ally), check_insert_left(Enemy, Ally, Coord, One_up, Temp_eat, Eat_list), !);
     (Coord//8 =:= One_up//8, One_up >= 0, member(One_up, Enemy), check_insert_right(Enemy, Ally, Coord, Cur, [One_up|Temp_eat], Eat_list), !);
     Eat_list = [], !
    ).

check_insert_right(_, _, Coord, Cur, _, []):-
    One_up is Cur + 1,
	Coord//8 =\= One_up//8, !.

check_insert_right(Enemy, Ally, Coord, Cur, Temp_eat, Eat_list):-
    One_up is Cur + 1,
    (
     (Coord//8 =:= One_up//8, One_up =< 63, member(One_up, Ally), check_insert_right(Enemy, Ally, Coord, One_up, Temp_eat, Eat_list), !);
     (Coord//8 =:= One_up//8, One_up =< 63, member(One_up, Enemy), Eat_list = [One_up|Temp_eat], !);
     Eat_list = [], !
    ).

check_insert_vertical(Enemy, Ally, Coord, Eat_list):-
    check_insert_up(Enemy, Ally, Coord, Coord, [], Eat_list).

check_insert_up(_, _, Cur, _, []):-
    One_up is Cur - 8,
    One_up < 0, !.

check_insert_up(Enemy, Ally, Coord, Cur, Temp_eat, Eat_list):-
    One_up is Cur - 8,
    (
     (One_up >= 0, member(One_up, Ally), check_insert_up(Enemy, Ally, Coord, One_up, Temp_eat, Eat_list), !);
     (One_up >= 0, member(One_up, Enemy), check_insert_down(Enemy, Ally, Coord, Cur, [One_up|Temp_eat], Eat_list), !);
     Eat_list = [], !
    ).

check_insert_down(_, _, Cur, _, []):-
    One_up is Cur + 8,
    One_up > 63, !.

check_insert_down(Enemy, Ally, Coord, Cur, Temp_eat, Eat_list):-
    One_up is Cur + 8,
    (
     (One_up =< 63, member(One_up, Ally), check_insert_down(Enemy, Ally, Coord, One_up, Temp_eat, Eat_list), !);
     (One_up =< 63, member(One_up, Enemy), Eat_list = [One_up|Temp_eat], !);
     Eat_list = [], !
    ).

% case neep
is_burger_eat(Enemy, Ally, Coord, Eat_list):-
    check_burger_left(Enemy, Ally, Coord, Eat_left),
    check_burger_right(Enemy, Ally, Coord, Eat_right),
    check_burger_up(Enemy, Ally, Coord, Eat_up),
    check_burger_down(Enemy, Ally, Coord, Eat_down),
    Temp_eat = [],
    ((is_list(Eat_left) , append(Eat_left , Temp_eat, Eat1)    , !); Eat1 = Temp_eat),
    ((is_list(Eat_right), append(Eat_right, Eat1    , Eat2)    , !); Eat2 = Eat1),
    ((is_list(Eat_up)   , append(Eat_up   , Eat2    , Eat3)    , !); Eat3 = Eat2),
    ((is_list(Eat_down) , append(Eat_down , Eat3    , Eat_list), !); Eat_list = Eat3).

check_burger_left(Enemy, Ally, Coord, Eat_list):-
    check_burger_left(Enemy, Ally, Coord, [], Eat_list).

% found something on left
check_burger_left(Enemy, Ally, Cur, Temp_eat, Eat_list):-
    One_up is Cur - 1,
    (
     (Cur//8 =:= One_up//8, One_up >= 0, member(One_up, Enemy), check_burger_left(Enemy, Ally, One_up, [One_up|Temp_eat], Eat_list), !);
     (Cur//8 =:= One_up//8, One_up >= 0, member(One_up, Ally), Temp_eat \== [], Eat_list = Temp_eat, !);
     Eat_list = [], !
    ).

check_burger_right(Enemy, Ally, Coord, Eat_list):-
    check_burger_right(Enemy, Ally, Coord, [], Eat_list).

% found something on right
check_burger_right(Enemy, Ally, Cur, Temp_eat, Eat_list):-
    One_up is Cur + 1,
    (
     (Cur//8 =:= One_up//8, One_up =< 63, member(One_up, Enemy), check_burger_right(Enemy, Ally, One_up, [One_up|Temp_eat], Eat_list), !);
     (Cur//8 =:= One_up//8, One_up =< 63, member(One_up, Ally), Temp_eat \== [], Eat_list = Temp_eat, !);
     Eat_list = [], !
    ).

check_burger_up(Enemy, Ally, Coord, Eat_list):-
    check_burger_up(Enemy, Ally, Coord, [], Eat_list).

% found something on up
check_burger_up(Enemy, Ally, Cur, Temp_eat, Eat_list):-
    One_up is Cur - 8,
    (
     (One_up >= 0, member(One_up, Enemy), check_burger_up(Enemy, Ally, One_up, [One_up|Temp_eat], Eat_list), !);
     (One_up >= 0, member(One_up, Ally), Temp_eat \== [], Eat_list = Temp_eat, !);
     Eat_list = [], !
    ).

check_burger_down(Enemy, Ally, Coord, Eat_list):-
    check_burger_down(Enemy, Ally, Coord, [], Eat_list).

% found something on down
check_burger_down(Enemy, Ally, Cur, Temp_eat, Eat_list):-
    One_up is Cur + 8,
    (
     (One_up =< 63, member(One_up, Enemy), check_burger_down(Enemy, Ally, One_up, [One_up|Temp_eat], Eat_list), !);
     (One_up =< 63, member(One_up, Ally), Temp_eat \== [], Eat_list = Temp_eat, !);
     Eat_list = [], !
    ).

check_to_eat(Enemy, Ally, Coord, Eat_list) :-
    check_insert_horizontal(Enemy, Ally, Coord, HoriEat),
    check_insert_vertical(Enemy, Ally, Coord, VertiEat),
    is_burger_eat(Enemy, Ally, Coord, BurgerEat),
    append(HoriEat, VertiEat, InsertEat),
    append(InsertEat, BurgerEat, Together),
    sort(Together, Eat_list).

getColorNum(Col, ColNum) :-
    (Col == red,
     ColNum = 1, ! );
     ColNum = 2.

getColorName(ColNum, ColName) :-
    (ColNum is 1,
     ColName = red, ! );
     ColName = blue.

getEnemyColorName(ColNum, EnemyCol) :-
    (ColNum is 1,
     EnemyCol = blue, ! );
     EnemyCol = red.


getPieceMove(Ally, Enemy, ResList) :-
    getPieceMove(Ally, Ally, Enemy,[], ResList).

getPieceMove([], _, _, L, L) :- !.

getPieceMove([H|T], Ally, Enemy, Temp, Acc) :-
    append(Ally, Enemy, AllPieces),
    getUpMoves(AllPieces, H, UpMoves),
    getDownMoves(AllPieces, H, DownMoves),
    getLeftMoves(AllPieces, H, LeftMoves),
    getRightMoves(AllPieces, H, RightMoves),
    append(UpMoves,DownMoves,Res1),
    append(Res1, LeftMoves,Res2),
    append(Res2, RightMoves, AllMoves),
    sort(AllMoves, PosMoves),
    (
     (
      \+length(PosMoves, 0),
      getPieceMoveHelper(PosMoves, H, [], Acc2),
      append(Acc2, Temp, Result),
      getPieceMove(T, Ally, Enemy, Result, Acc ), !
     );
     getPieceMove(T, Ally, Enemy, Temp, Acc ), !
    ).

getPieceMoveHelper([], _, L, L) :- !.

getPieceMoveHelper([H|T], Pos, Temp, Acc) :-
    getPieceMoveHelper(T, Pos, [[Pos,H]|Temp], Acc).

getRed(Board, Result):-
	getRed(Board, 0, [], Result).
getRed([], _, L, L):-
	!.
getRed([H|T], Cur, Temp, Result):-
	NewCur is Cur + 1,
	(
	 H == 1, getRed(T, NewCur, [Cur|Temp], Result), !;
	 getRed(T, NewCur, Temp, Result)
	).

getBlue(Board, Result):-
	getBlue(Board, 0, [], Result).
getBlue([], _, L, L):-
	!.
getBlue([H|T], Cur, Temp, Result):-
	NewCur is Cur + 1,
	(
	 H == 2, getBlue(T, NewCur, [Cur|Temp], Result), !;
	 getBlue(T, NewCur, Temp, Result)
	).

getPieceNum([H|T], Cur, Result):-
	NewCur is Cur - 1,
	(
	 Cur == 0, Result = H, !;
	 getPieceNum(T, NewCur, Result)
	).

getPosBoards([], _, Temp, Temp, _, _) :- !.

getPosBoards([[Pos1,Pos2]|T], Board, Temp, NewBoards, Ally, Enemy) :-
    getPieceNum(Board, Pos1, Col),
    checkMove(Board, Pos1, Pos2, Col, TempBoard),
    subtract(Ally, [Pos1], NewAlly),
    check_to_eat(Enemy, NewAlly, Pos2, Eat_list),
    eatPieces(TempBoard, Eat_list, NewBoard),
    getPosBoards(T, Board, [NewBoard|Temp], NewBoards, Ally, Enemy).

getEatMoves([],_,_,L,L) :- !.

getEatMoves([[Pos1,Pos2]|T], Ally, Enemy, Temp, EatMoves) :-
    subtract(Ally, [Pos1], NewAlly),
    check_to_eat(Enemy, NewAlly, Pos2, Eat_list),
    (
        \+length(Eat_list, 0),
        getEatMoves(T, Ally, Enemy, [[Pos1,Pos2]|Temp], EatMoves), !);
    getEatMoves(T, Ally, Enemy, Temp, EatMoves).

getBoardHelper([], Moves, Board, NewBoards, Ally, Enemy) :-
    getPosBoards(Moves, Board, [], NewBoards, Ally, Enemy), !.

getBoardHelper(EatMoves, _,  Board, NewBoards, Ally, Enemy):-
    getPosBoards(EatMoves, Board, [], NewBoards, Ally, Enemy).



alphabeta(Board, Alpha, Beta, GoodBoard, Val, Depth ) :-
    (Depth > 0,
    getRed(Board, RedPieces), getBlue(Board, BluePieces),
    (
        (1 is mod(Depth,2), getPieceMove(RedPieces, BluePieces, Moves), getEatMoves(Moves, RedPieces, BluePieces, [], MoveToEat),
         getBoardHelper(MoveToEat, Moves, Board, NewBoards, RedPieces, BluePieces), !);
        (
            getPieceMove(BluePieces, RedPieces, Moves), getEatMoves(Moves, BluePieces, RedPieces, [], MoveToEat),
            getBoardHelper(MoveToEat, Moves, Board, NewBoards, BluePieces, RedPieces))
    ),
    boundedBest(NewBoards, Alpha, Beta, GoodBoard, Val, Depth), !);
    getValue(Board, Val).

boundedBest([Board|T], Alpha, Beta, GoodBoard, GoodVal, Depth ) :-
    Depth1 is Depth - 1,
    alphabeta(Board, Alpha, Beta, _, Val, Depth1),
    goodenough(T, Alpha, Beta, Board, Val, GoodBoard, GoodVal, Depth).

goodenough( [], _, _, Pos, Val, Pos, Val, _) :- !.     % No other candidate

goodenough( _, Alpha, Beta, _, Val, _, Val, Depth) :-
            0 is mod(Depth, 2), Val > Beta, !;       % Maximizer attained upper bound
            1 is mod(Depth, 2), Val < Alpha, !.      % Minimizer attained lower bound

goodenough( BoardList, Alpha, Beta, Board, Val, GoodBoard, GoodVal, Depth) :-
            newbounds( Alpha, Beta, Board, Val, NewAlpha, NewBeta, Depth),        % Refine bounds
            boundedBest( BoardList, NewAlpha, NewBeta, Board1, Val1, Depth),
            betterof( Board, Val, Board1, Val1, GoodBoard, GoodVal, Depth).

newbounds( Alpha, Beta, _, Val, Val, Beta, Depth) :-
           0 is mod(Depth, 2), Val > Alpha, !.        % Maximizer increased lower bound

newbounds( Alpha, Beta, _, Val, Alpha, Val, Depth) :-
           1 is mod(Depth, 2), 0 is mod(Depth, 2), Val < Beta, !.         % Minimizer decreased upper bound

newbounds( Alpha, Beta, _, _, Alpha, Beta, _).          % Otherwise bounds unchanged

betterof( Pos, Val, _, Val1, Pos, Val, Depth) :-         % Pos better then Pos1
          0 is mod(Depth, 2), Val > Val1, !;
          1 is mod(Depth, 2), Val < Val1, !.

betterof( _, _, Pos1, Val1, Pos1, Val1, _).             % Otherwise Pos1 better

getAItoMove(Board, NewBoard, [Pos1, Pos2]):-
    getRed(Board, OldAlly),
    getRed(NewBoard, NewAlly),
    subtract(OldAlly, NewAlly, Pos1),
    subtract(NewAlly, OldAlly, Pos2).
