%*******************************************************************************
%                                    AETOILE
%*******************************************************************************

/*
Rappels sur l'algorithme
 
- structures de donnees principales = 2 ensembles : P (etat pendants) et Q (etats clos)
- P est dedouble en 2 arbres binaires de recherche equilibres (AVL) : Pf et Pu
 
   Pf est l'ensemble des etats pendants (pending states), ordonnes selon
   f croissante (h croissante en cas d'egalite de f). Il permet de trouver
   rapidement le prochain etat a developper (celui qui a f(U) minimum).
   
   Pu est le meme ensemble mais ordonne lexicographiquement (selon la donnee de
   l'etat). Il permet de retrouver facilement n'importe quel etat pendant

   On gere les 2 ensembles de fa�on synchronisee : chaque fois qu'on modifie
   (ajout ou retrait d'un etat dans Pf) on fait la meme chose dans Pu.

   Q est l'ensemble des etats deja developpes. Comme Pu, il permet de retrouver
   facilement un etat par la donnee de sa situation.
   Q est modelise par un seul arbre binaire de recherche equilibre.

Predicat principal de l'algorithme :

   aetoile(Pf,Pu,Q)

   - reussit si Pf est vide ou bien contient un etat minimum terminal
   - sinon on prend un etat minimum U, on genere chaque successeur S et les valeurs g(S) et h(S)
	 et pour chacun
		si S appartient a Q, on l'oublie
		si S appartient a Ps (etat deja rencontre), on compare
			g(S)+h(S) avec la valeur deja calculee pour f(S)
			si g(S)+h(S) < f(S) on reclasse S dans Pf avec les nouvelles valeurs
				g et f 
			sinon on ne touche pas a Pf
		si S est entierement nouveau on l'insere dans Pf et dans Ps
	- appelle recursivement etoile avec les nouvelles valeurs NewPF, NewPs, NewQs

*/

%*******************************************************************************

:- ['avl.pl'].       % predicats pour gerer des arbres bin. de recherche   
:- ['taquin.pl'].    % predicats definissant le systeme a etudier

%*******************************************************************************

avl1(Avl) :- 
	initial_state(U0),
	heuristique(U0,H),
	empty(Empty),
	insert([[H,0,H],U0],Empty,Avl).

avl2(Avl) :- 
	initial_state(U0),
	heuristique(U0,H),
	empty(Empty),
	insert([U0,[H,0,H],nil,nil],Empty,Avl).

main :-
	avl1(Pf),
	avl2(Pu),
	empty(Q),
	statistics(walltime, [TimeSinceStart | [TimeSinceLastCall]]),
	aetoile(Pf,Pu,Q),
   	statistics(walltime, [NewTimeSinceStart | [ExecutionTime]]),
   	write('L\'execution a pris '), 
	write(ExecutionTime), 
	write(' ms.'), 
	nl.




%*******************************************************************************

/* Les 2 arbres avl sont vides */
aetoile(Empty,Empty,_) :- 
	empty(Empty),
	writeln('Pas de solution : etat final nest pas ateignable.'),
	!.

/* Solution trouvée */
aetoile(Pf,_,Qs) :-
	final_state(F),
	suppress_min([_,F],Pf,_),
	get_solution(F,Qs,L),
	reverse(L,Sol,[]),
	affiche_solution(Sol),
	!.

/* Cas générale */
aetoile(Pf,Pu,Qs) :-
	suppress_min([[_,_,G],U],Pf,Pf2),
	suppress([U,Info,Pere,A],Pu,Pu2),
	findall([U2,Cost,Move],rule(Move,Cost,U,U2),List_successors),
	expand(U,List_successors,G,[Qs,Q2],[Pf2,Pf3],[Pu2,Pu3]),
	insert([U,Info,Pere,A],Q2,Q3),
	aetoile(Pf3,Pu3,Q3).

/* Plus de successeurs */
expand(_,[],_,[Q,Q],[Pf,Pf],[Pu,Pu]).

/* Opération sur successeur */
expand(Ancetre,[[U,Cost,Move]|T],G,[Q,Q3],[Pf,Pf3],[Pu,Pu3]) :-
	heuristique(U,H),
	G2 is (Cost + G),
	F is (H+G2),
	loop_successors(Ancetre,[U,Cost,Move],[Q,Q2],[Pf,Pf2],[Pu,Pu2],[F,G2,H]),
	expand(Ancetre,T,G,[Q2,Q3],[Pf2,Pf3],[Pu2,Pu3]).

/* Evaluation du successeur moins bonne que le père */
loop_successors(_,[U|_],[Q,Q],[Pf,Pf],[Pu,Pu],[F1,_,_]) :-
	suppress([U,[F2,H2,G2],Pere,A],Pu,_),
	compare(>,F1,F2),
	!.

/* Evaluation du successeur meilleure que le père */
loop_successors(Ancetre,[U,_,Move],[Q,Q],[Pf,Pf3],[Pu,Pu3],[F1,G1,H1]) :-
	suppress([U,[F2,H2,G2],_,_],Pu,Pu2),
	suppress([[F2,H2,G2],U],Pf,Pf2),
	insert([[F1,H1,G1],U],Pf2,Pf3),
	insert([U,[F1,H1,G1],Ancetre,Move],Pu2,Pu3).

/* Situation nouvelle */
loop_successors(Ancetre,[U,_,Move],[Q,Q],[Pf,Pf3],[Pu,Pu3],[F1,G1,H1]) :-
	insert([U,[F1,H1,G1],Ancetre,Move],Pu,Pu3),
	insert([[F1,H1,G1],U],Pf,Pf3).

/* Situation connue */
loop_successors(_,[U,_,_],[Q,Q],[Pf,Pf],[Pu,Pu],_) :- belongs([U,_,_,_],Q).

get_solution(nil,_,[]).
get_solution(U,Q,[[U,Move]|T]):-
	belongs([U, _, _, _], Q),
	suppress([U, _, Ancetre, Move], Q, Q2),
	get_solution(Ancetre,Q2,T).

reverse([],L,L).
reverse([H|T],L,Acc) :- reverse(T,L,[H|Acc]).

affiche_solution([]).
affiche_solution([[U,Move]|T]):-
	write('Mouvement : '),
	write(Move),
	write(', Etat : '),
	writeln(U),
	affiche_solution(T).


/* TESTS UNITAIRES */

:- initial_state(Ini),coordonnees([2,1],Ini,a). % Coordonees
:- initial_state(Ini),final_state(Final),malplace(b,Ini,Final). % Malplace
:- initial_state(Ini),heuristique1(Ini,4). % Heuristique1
:- initial_state(Ini),manhattan(h,Ini,2). % Manhattan
:- initial_state(Ini),heuristique2(Ini,5). % Heuristique2