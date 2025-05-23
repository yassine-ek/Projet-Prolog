%%%%%%%%%%%%%%%%%%%%%%%%
%  INSCRITS AU TOURNOI %
%%%%%%%%%%%%%%%%%%%%%%%%
% Liste des joueurs inscrits au tournoi
inscrits([random, titfortat, gambler]).

% Affichage ou non des détails de chaque partie (oui/non).
affichageDetails(oui).     % Indiquer oui pour voir les détails

%%%%%%%%%%%
% JOUEURS %
%%%%%%%%%%%

% Random
%%%%%%%%
% joue au hasard entre 1 et 5
joue(random, _, N) :- random_between(1,5,N).

% Tit for tat
%%%%%%%%%%%%
% joue au hasard la première fois puis le coup précédent de l'adversaire
joue(titfortat, [], N) :- random_between(1,5,N).
joue(titfortat, [[_,C]|_], C).

% Gambler
%%%%%%%%
% joue au hasard la première fois puis, soit son coup précédent avec une probabilité de 20% ou au hasard avec une probabilité de 80%
joue(gambler, [], N) :- random_between(1,5,N).
joue(gambler, [[Prec,_]|_], C) :- random(R), (R < 0.2 -> C = Prec ; random_between(1,5,C)).

%%%%%%%%%%%%%%%%%%%%%%
% GESTION DU TOURNOI %
%%%%%%%%%%%%%%%%%%%%%%

go :- inscrits(L), tournoi(L, R), predsort(comparePairs, R, RSorted),
      writef("Résultats : %t\n", [RSorted]).

% Lance le tournoi entre tous les joueurs de la liste
tournoi([], []).
tournoi([J|L], R) :- inscrits(Ins), member(J, Ins), !,
    matchs(J, [J|L], R1),
    tournoi(L, R2),
    fusionne(R1, R2, R).
tournoi([J|_], _) :- writef("Le joueur %t est inconnu.\n", [J]), fail.

% Fusionne les résultats partiels
fusionne([], L, L).
fusionne([[J,G]|L], L2, R) :- update(J, G, L2, R2), fusionne(L, R2, R).

% Joue tous les matchs de J contre les joueurs de la liste
matchs(_, [], []).
matchs(J, [J1|L1], R) :-
    run(J, J1, G1, G2),
    matchs(J, L1, R1),
    update(J, G1, R1, R2),
    update(J1, G2, R2, R).

% Met à jour le score total
update(J, Gain, [[J,Old]|R], [[J,New]|R]) :- !, New is Old + Gain.
update(J, Gain, [P|L], [P|L2]) :- update(J, Gain, L, L2).
update(J, Gain, [], [[J,Gain]]).

% Affichage des tours et des scores cumulés
affiche(J1, J2, C1, C2, S1, S2, TS1, TS2) :- affichageDetails(oui), !,
    writef("%t joue %t, %t joue %t : [%t,%t]. Cumul: [%t,%t]\n", [J1, C1, J2, C2, S1, S2, TS1, TS2]).
affiche(_,_,_,_,_,_,_,_).

% Lance un match de 100 tours entre J1 et J2
run(J1, J2, Pts1, Pts2) :- run(100, J1, J2, [], 0, 0, Pts1, Pts2).

% Base : plus de tours. Affiche le score final du match.
run(0, J1, J2, _, S1, S2, S1, S2) :- !,
    writef("%t %t - %t %t.\n", [J1, S1, S2, J2]).

% Récursif : joue un tour et accumule les scores
run(N, J1, J2, Hist, S1, S2, P1, P2) :-
    joue(J1, Hist, C1),
    inversePaires(Hist, IHist),
    joue(J2, IHist, C2),
    score(C1, C2, Sc1, Sc2),
    NS1 is S1 + Sc1,
    NS2 is S2 + Sc2,
    affiche(J1, J2, C1, C2, Sc1, Sc2, NS1, NS2),
    N1 is N - 1,
    run(N1, J1, J2, [[C1,C2]|Hist], NS1, NS2, P1, P2).

% Calcul des scores - VERSION 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
score(C1, C2, Score1, Score2) :-
    D is abs(C1-C2), D =:= 1, C1 < C2,
    Score1 is C1 + C2, Score2 is 0.
score(C1, C2, Score1, Score2) :-
    D is abs(C1-C2), D =:= 1, C2 < C1,
    Score1 is 0, Score2 is C1 + C2.
score(C1, C2, C1, C2) :-
    D is abs(C1-C2), D =\= 1.

% UTILITAIRES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
inversePaires([], []).
inversePaires([[X,Y]|R], [[Y,X]|R2]) :- inversePaires(R, R2).

comparePairs(=,[_,X],[_,X]) :- !.
comparePairs(<,[_,X],[_,Y]) :- X > Y, !.
comparePairs(>,_,_).













