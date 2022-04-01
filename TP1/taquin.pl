%***************************
%DESCRIPTION DU JEU DU TAKIN
%***************************

   %********************
   % ETAT INITIAL DU JEU
   %********************   
   % format :  initial_state(+State) ou State est une matrice (liste de listes)
   
/*
initial_state([ [b, h, c],       % C'EST L'EXEMPLE PRIS EN COURS
                [a, f, d],       % 
                [g,vide,e] ]).   % h1=4,   h2=5,   f*=5
*/


% AUTRES EXEMPLES POUR LES TESTS DE  A*

/*
initial_state([ [ a, b, c],        
                [ g, h, d],
                [vide,f, e] ]). % h2=2, f*=2

initial_state([ [b, c, d],
                [a,vide,g],
                [f, h, e]  ]). % h2=10 f*=10

initial_state([ [f, g, a],
                [h,vide,b],
                [d, c, e]  ]). % h2=16, f*=20
*/
initial_state([ [e, f, g],
                [d,vide,h],
                [c, b, a]  ]). % h2=24, f*=30 
/*
initial_state([ [a, b, c],
                [g,vide,d],
                [h, f, e]]). % etat non connexe avec l'etat final (PAS DE SOLUTION)
*/


   %******************
   % ETAT FINAL DU JEU
   %******************
   % format :  final_state(+State) ou State est une matrice (liste de listes)
   
final_state([[a, b,  c],
             [h,vide, d],
             [g, f,  e]]).

			 
   %********************
   % AFFICHAGE D'UN ETAT
   %********************
   % format :  write_state(?State) ou State est une liste de lignes a afficher

write_state([]).
write_state([Line|Rest]) :-
   writeln(Line),
   write_state(Rest).
   

%**********************************************
% REGLES DE DEPLACEMENT (up, down, left, right)             
%**********************************************
   % format :   rule(+Rule_Name, ?Rule_Cost, +Current_State, ?Next_State)
   
rule(up,   1, S1, S2) :-
   vertical_permutation(_X,vide,S1,S2).

rule(down, 1, S1, S2) :-
   vertical_permutation(vide,_X,S1,S2).

rule(left, 1, S1, S2) :-
   horizontal_permutation(_X,vide,S1,S2).

rule(right,1, S1, S2) :-
   horizontal_permutation(vide,_X,S1,S2).

   %***********************
   % Deplacement horizontal            
   %***********************
    % format :   horizontal_permutation(?Piece1,?Piece2,+Current_State, ?Next_State)
	
horizontal_permutation(X,Y,S1,S2) :-
   append(Above,[Line1|Rest], S1),
   exchange(X,Y,Line1,Line2),
   append(Above,[Line2|Rest], S2).

   %***********************************************
   % Echange de 2 objets consecutifs dans une liste             
   %***********************************************
   
exchange(X,Y,[X,Y|List], [Y,X|List]).
exchange(X,Y,[Z|List1],  [Z|List2] ):-
   exchange(X,Y,List1,List2).

   %*********************
   % Deplacement vertical            
   %*********************
   
vertical_permutation(X,Y,S1,S2) :-
   append(Above, [Line1,Line2|Below], S1), % decompose S1
   delete(N,X,Line1,Rest1),    % enleve X en position N a Line1,   donne Rest1
   delete(N,Y,Line2,Rest2),    % enleve Y en position N a Line2,   donne Rest2
   delete(N,Y,Line3,Rest1),    % insere Y en position N dans Rest1 donne Line3
   delete(N,X,Line4,Rest2),    % insere X en position N dans Rest2 donne Line4
   append(Above, [Line3,Line4|Below], S2). % recompose S2 

   %***********************************************************************
   % Retrait d'une occurrence X en position N dans une liste L (resultat R) 
   %***********************************************************************
   % use case 1 :   delete(?N,?X,+L,?R)
   % use case 2 :   delete(?N,?X,?L,+R)   
   
delete(1,X,[X|L], L).
delete(N,X,[Y|L], [Y|R]) :-
   delete(N1,X,L,R),
   N is N1 + 1.

   %*******************
   % PARTIE A COMPLETER
   %*******************
   
   %*******************************************************************
   % Coordonnees X(colonne),Y(Ligne) d'une piece P dans une situation U
   %*******************************************************************
	% format : coordonnees(?Coord, +Matrice, ?Element)
	% Définit la relation entre des coordonnees [Ligne, Colonne] et un element de la matrice
	
coordonnees([Lig,Col],Etat,Piece ) :-
   nth1(Lig,Etat,L), 
   nth1(Col,L, Piece).

/* Tests unitaires coordonnees */
:- coordonnees([2,2],[[a,b,c],[d,e,f]],  e).
:- coordonnees([2,3], [[a,b,c],[d,e,f]],  f).

											 
   %*************
   % HEURISTIQUES
   %*************
   
heuristique(U,H) :-
%    heuristique1(U, H).  % au debut on utilise l'heuristique 1 
     heuristique2(U, H).  % ensuite utilisez plutot l'heuristique 2  
   
   
%****************
%HEURISTIQUE no 1
%****************
% Nombre de pieces mal placees dans l'etat courant U
% par rapport a l'etat final F

malplace(P,U,F) :-
   coordonnees([L,C],U,P),
   coordonnees([L,C],F,Q),
   P \= Q,
   P \= vide.

/* Test unitaires malplace */
:- malplace(a,[[a,b],[c,d]],[[b,c],[d,a]]).
:- malplace(c,[[a,b],[c,d]],[[b,c],[d,a]]).

heuristique1(U, H) :- 
   findall(P,(final_state(F),malplace(P,U,F)),Liste_mal_place),
   length(Liste_mal_place,H).

[[a, b,  c],
 [h,vide, d],
 [g, f,  e]]

:- heuristique1([[e, b,  c],
                [g, d, vide],
                [h, f,  a]],5).

%****************
%HEURISTIQUE no 2
%****************

% Somme des distances de Manhattan à parcourir par chaque piece
% entre sa position courante et sa positon dans l'etat final

sumlist([H|T],N) :- 
   sumlist(T,N1),
   N is (H+N1).
sumlist([],0).

/* Tests unitaires sumlist */
:- sumlist([1,2,3,4],10).
:- sumlist([10,20,30,9],69).

manhattan(P,U,M) :-
   final_state(F),
   coordonnees([L1,C1],U,P),
   coordonnees([L2,C2],F,P),
   P \= vide,
   M is (abs(L1-L2) + abs(C1-C2)).

/* Tests unitaires calcul manhattan */
:- S=[[c,b,_],
      [d,e,f],
      [g,h,a]],
   manhattan(a,S,4).
:- S=[[c,b,_],
      [d,e,f],
      [g,h,a]],
   manhattan(c,S,2).

heuristique2(U, H) :- 
   findall(M,manhattan(P,U,M),List2),
   sumlist(List2,H).

:- heuristique2([[e, b,  c],
                [g, d, vide],
                [h, f,  a]],11).						