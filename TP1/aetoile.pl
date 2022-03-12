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
	aetoile(Pf,Pu,Q).



%*******************************************************************************

aetoile(Empty,Empty,_) :- 
	empty(Empty),
	writeln("Pas de solution : l'état final n'est pas ateignable.").

aetoile(Pf,Pu,Qs) :-
	suppress_min([[_,_,G],U],Pf,Pf2),
	suppress([U,Info,Pere,A],Pu,Pu2),
	writeln(U),
	findall([U2,Cost,Move],rule(Move,Cost,U,U2),List_successors),
	writeln(List_successors),
	expand(U,List_successors,G,[Qs,Q2],[Pf2,Pf3],[Pu2,Pu3]),
	writeln("expand over"),
	insert([U,Info,Pere,A],Q2,Q3),
	aetoile(Pf3,Pu3,Q3).

aetoile(Pf,_,Qs) :-
	final_state(F),
	suppress_min([_,F],Pf,_),
	writeln("On a trouvé la solution!!!!! Youpi!!!!"),
	get_solution(F,Qs,L),
	reverse(L,Sol,[]),
	affiche_solution(Sol),
	!.

expand(_,[],_,[Q,Q],[Pf,Pf],[Pu,Pu]) :- writeln("Fin de la liste de successeurs.").

expand(Ancetre,[[U,Cost,Move]|T],G,[Q,Q3],[Pf,Pf3],[Pu,Pu3]) :-
	heuristique(U,H),
	G2 is (Cost + G),
	F is (H+G2),
	writeln(""),
	writeln("Accès à un successeur"),
	loop_successors(Ancetre,[U,Cost,Move],[Q,Q2],[Pf,Pf2],[Pu,Pu2],[F,G2,H]),
	writeln("expanding"),
	expand(Ancetre,T,G,[Q2,Q3],[Pf2,Pf3],[Pu2,Pu3]).

loop_successors(_,[U|_],[Q,Q],[Pf,Pf],[Pu,Pu3],[F1,_,_]) :-
	suppress([U,[F2,H2,G2],Pere,A],Pu,Pu2),
	compare(>,F1,F2),
	writeln("S est connu dans Pu, mais S à une évaluation moins bonne."),
	insert([U,[F2,H2,G2],Pere,A],Pu2,Pu3),
	write("Renvoie : "),
	writeln(Pu3).

loop_successors(Ancetre,[U,_,Move],[Q,Q],[Pf,Pf3],[Pu,Pu3],[F1,G1,H1]) :-
	suppress([U,[F2,H2,G2],_,_],Pu,Pu2),
	compare(>,F2,F1),
	writeln("S est connu dans Pu, et S a une évaluation meilleure."),
	suppress([[F2,H2,G2],U],Pf,Pf2),
	insert([[F1,H1,G1],U],Pf2,Pf3),
	insert([U,[F1,H1,G1],Ancetre,Move],Pu2,Pu3).

loop_successors(Ancetre,[U,_,Move],[Q,Q],[Pf,Pf3],[Pu,Pu3],[F1,G1,H1]) :-
	writeln("S est une situation nouvelle."),
	insert([U,[F1,H1,G1],Ancetre,Move],Pu,Pu3),
	insert([[F1,H1,G1],U],Pf,Pf3),
	writeln(Pu3).

loop_successors(_,[U,_,_],[Q,Q],[Pf,Pf],[Pu,Pu],_) :-
	belongs([U,_,_,_],Q),
	writeln("S is in Q").

get_solution(nil,_,[]).
get_solution(U,Q,[[U,Move]|T]):-
	belongs([U, _, _, _], Q),
	suppress([U, _, Ancetre, Move], Q, Q2),
	get_solution(Ancetre,Q2,T).

reverse([],L,L).
reverse([H|T],L,Acc) :- reverse(T,L,[H|Acc]).

affiche_solution([]).
affiche_solution([[U,Move]|T]):-
	write("Mouvement : "),
	write(Move),
	write(", Etat : "),
	writeln(U),
	affiche_solution(T).