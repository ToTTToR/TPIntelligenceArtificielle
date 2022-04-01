	/*
	Ce programme met en oeuvre l'algorithme Minmax (avec convention
	negamax) et l'illustre sur le jeu du TicTacToe (morpion 3x3)
	*/
	
:- [tictactoe].


	/****************************************************
  	ALGORITHME MINMAX avec convention NEGAMAX : negamax/5
  	*****************************************************/

	/*
	negamax(+J, +Etat, +P, +Pmax, [?Coup, ?Val])

	SPECIFICATIONS :

	retourne pour un joueur J donne, devant jouer dans
	une situation donnee Etat, de profondeur donnee P,
	le meilleur couple [Coup, Valeur] apres une analyse
	pouvant aller jusqu'a la profondeur Pmax.

	Il y a 3 cas a decrire (donc 3 clauses pour negamax/5)
	
	1/ la profondeur maximale est atteinte : on ne peut pas
	developper cet Etat ; 
	il n'y a donc pas de coup possible a jouer (Coup = rien)
	et l'evaluation de Etat est faite par l'heuristique.

	2/ la profondeur maximale n'est pas  atteinte mais J ne
	peut pas jouer ; au TicTacToe un joueur ne peut pas jouer
	quand le tableau est complet (totalement instancie) ;
	il n'y a pas de coup a jouer (Coup = rien)
	et l'evaluation de Etat est faite par l'heuristique.

	3/ la profondeur maxi n'est pas atteinte et J peut encore
	jouer. Il faut evaluer le sous-arbre complet issu de Etat ; 

	- on determine d'abord la liste de tous les couples
	[Coup_possible, Situation_suivante] via le predicat
	 successeurs/3 (deja fourni, voir plus bas).

	- cette liste est passee a un predicat intermediaire :
	loop_negamax/5, charge d'appliquer negamax sur chaque
	Situation_suivante ; loop_negamax/5 retourne une liste de
	couples [Coup_possible, Valeur]

	- parmi cette liste, on garde le meilleur couple, c-a-d celui
	qui a la plus petite valeur (cf. predicat meilleur/2);
	soit [C1,V1] ce couple optimal. Le predicat meilleur/2
	effectue cette selection.

	- finalement le couple retourne par negamax est [Coup, V2]
	avec : V2 is -V1 (cf. convention negamax vue en cours).

A FAIRE : ECRIRE ici les clauses de negamax/5
.....................................
	*/
/* Profondeur PMax atteint */
negamax(J,Etat,P,P,[_,Val]) :- 
	heuristique(J,Etat,Val),
	!.

/* Grille pleine, plus de coups possibles à jouer */
negamax(J,Etat,_,_,[_,Val]) :-
	situation_terminale(J,Etat),
	heuristique(J,Etat,Val),
	!.

/* Situation gagnante */
negamax(J,Etat,_,_,[_,10000]) :-
	heuristique(J,Etat,10000),
	!.

/* Situation perdante */
negamax(J,Etat,_,_,[_,-10000]) :-
	heuristique(J,Etat,-10000),
	!.

/* Situation "normale" */
negamax(J,Etat,P,Pmax,[Coup,Val]) :-
	successeurs(J,Etat,Liste_successeur),
	loop_negamax(J,P,Pmax,Liste_successeur,Liste_coups),
	meilleur(Liste_coups,[Coup,Val2]),
	Val is -Val2.


	/*******************************************
	 DEVELOPPEMENT D''UNE SITUATION NON TERMINALE
	 successeurs/3 
	 *******************************************/

	 /*
   	 successeurs(+J,+Etat, ?Succ)

   	 retourne la liste des couples [Coup, Etat_Suivant]
 	 pour un joueur donne dans une situation donnee 
	 */

successeurs(J,Etat,Succ) :-
	copy_term(Etat, Etat_Suiv),
	findall([Coup,Etat_Suiv],
		    successeur(J,Etat_Suiv,Coup),
		    Succ).

	/*************************************
         Boucle permettant d'appliquer negamax 
         a chaque situation suivante :
	*************************************/

	/*
	loop_negamax(+J,+P,+Pmax,+Successeurs,?Liste_Couples)
	retourne la liste des couples [Coup, Valeur_Situation_Suivante]
	a partir de la liste des couples [Coup, Situation_Suivante]
	*/

loop_negamax(_,_, _  ,[],                []).
loop_negamax(J,P,Pmax,[[Coup,Suiv]|Succ],[[Coup,Vsuiv]|Reste_Couples]) :-
	loop_negamax(J,P,Pmax,Succ,Reste_Couples),
	adversaire(J,A),
	Pnew is P+1,
	negamax(A,Suiv,Pnew,Pmax, [_,Vsuiv]).

	/*

A FAIRE : commenter chaque litteral de la 2eme clause de loop_negamax/5,
	en particulier la forme du terme [_,Vsuiv] dans le dernier
	litteral ?

- J : joueur actuel
- P : profondeur actuelle
- Pmax : profondeur max possible
- [Coup,Suiv] : couple représentant un noeud de l'arbre (le coup et coût correspondant)
- [[Coup,Suiv]|Succ] : permet d'itérer sur la liste de noeud d'une branche choisi
- [[Coup,Vsuiv]|Reste_Couples] : même fonctionnement que ci-dessus mais on remonte les noeuds (dans Reste_Couples) au lieu de les faire descendre

loop_negamax(J,P,Pmax,Succ,Reste_Couples) : pour la récursivité, on descend avec les noeuds restants et on remonte les resultats
adversaire(J,A) : quand un joueur joue un coup c'est ensuite à l'autre joueur de jouer, on inverse donc le joueur J ici devient A pour adversaire
Pnew représente la nouvelle profondeur (P+1), on est en effet un cran plus bas
negamax(A,Suiv,Pnew,Pmax, [_,Vsuiv]) : on regarde les coups que peut jouer l'adversaire et update l'arbre en fonction.
[_,Vsuiv] : représente le couple du noeud minimum que l'on va choisir ensuite


	*/

	/*********************************
	 Selection du couple qui a la plus
	 petite valeur V 
	 *********************************/

	/*
	meilleur(+Liste_de_Couples, ?Meilleur_Couple)

	SPECIFICATIONS :
	On suppose que chaque element de la liste est du type [C,V]
	- le meilleur dans une liste a un seul element est cet element
	- le meilleur dans une liste [X|L] avec L \= [], est obtenu en comparant
	  X et Y,le meilleur couple de L 
	  Entre X et Y on garde celui qui a la petite valeur de V.

A FAIRE : ECRIRE ici les clauses de meilleur/2
	*/

meilleur([Couple],Couple).

meilleur([[Coup,V_situation_suivante]|T],[Coup,V_situation_suivante]) :- 
	meilleur(T,[_,V_situation_suivante2]),
	compare(<,V_situation_suivante,V_situation_suivante2),
	!.

meilleur([_|T],[Coup2,V_situation_suivante2]) :- 
	meilleur(T,[Coup2,V_situation_suivante2]),
	!.

:- meilleur([[_,2],[_,6],[_,5]],[_,2]).
:- meilleur([[_,9],[_,2],[_,3]],[_,2]).
:- meilleur([[_,8],[_,2],[_,1]],[_,1]).

	/******************
  	PROGRAMME PRINCIPAL
  	*******************/

main(B,V, Pmax) :-
	situation_initiale(Etat),
	negamax(x,Etat,0,Pmax,[B,V]).
