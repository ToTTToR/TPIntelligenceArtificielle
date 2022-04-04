from pyswip import Prolog
import os 

prolog = Prolog()
prolog.consult('./TP2/negamax.pl')

res = list(prolog.query("main(B,V, 3)"))[0]
print('meilleur coup : ', res['B'])
print('valeur : ', res['V'])