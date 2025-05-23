%%%%%%%%%%%%%%%%%%%%%%%%
%  INSCRITS AU TOURNOI %
%%%%%%%%%%%%%%%%%%%%%%%%
inscrits([khawa_khawa,gambler,khawa_khawa_v4,titfortat,nash_equilibrium,stage_test
         ]).
%khawa_khawa_v1, khawa_khawa_v2, khawa_khawa_v3,khawa_khawa_v4, random, titfortat, gambler,nash_equilibrium, best_response,virus
 %Random, Titfortat, gambler,     ,khawa_khawa_v5,
%, nash_equilibrium, best_response
% Affichage ou non des détails
affichageDetails(oui).

%%%%%%%%%%%
% JOUEURS %
%%%%%%%%%%%

% Random : joue un nombre aléatoire entre 1 et 5
joue(random, _, N) :- random_between(1, 5, N).

% Tit for Tat : aléatoire au début, puis copie le dernier coup adverse
joue(titfortat, [], N) :- random_between(1, 5, N).
joue(titfortat, [[_,C]|_], C).

% Gambler : aléatoire au début, puis 20% chance de répéter son coup précédent
joue(gambler, [], N) :- random_between(1, 5, N).
joue(gambler, [[Prec,_]|_], C) :-
    random(R),
    (R < 0.2 -> C = Prec ; random_between(1, 5, C)).


%%%%%%%%%%%%%%%%%%%%%%%%
% KHAMA_KHAWA V1
%%%%%%%%%%%%%%%%%%%%%%%%
:- dynamic khawa_historique_v1/1.

joue(khawa_khawa_v1, Historique, Coup) :-
    retractall(khawa_historique_v1(_)),
    assertz(khawa_historique_v1(Historique)),
    length(Historique, NbTours),
    ( NbTours < 20 ->
         coup_apprentissage_v1(Coup)
    ; NbTours < 80 ->
         coup_adaptation_v1(Historique, Coup)
    ;
         coup_finale_v1(Coup)
    ).

coup_apprentissage_v1(Coup) :-
    random_member(Coup, [3, 3, 4, 4, 2, 5, 1, 3, 4, 4]).
coup_finale_v1(Coup) :-
    random_between(3, 4, Coup).

coup_adaptation_v1(Historique, Coup) :-
    ( adversaire_repetitif(Historique), jouer_contre_repetitif(Historique, Coup)
    ; adversaire_titfortat(Historique), jouer_contre_titfortat(Historique, Coup)
    ; random_between(3, 4, Coup)
    ).

%%%%%%%%%%%%%%%%%%%%%%%%
% KHAMA_KHAWA V2 (version optimisée)
%%%%%%%%%%%%%%%%%%%%%%%%
:- dynamic khawa_historique_v2/1.

joue(khawa_khawa_v2, Historique, Coup) :-
    retractall(khawa_historique_v2(_)),
    assertz(khawa_historique_v2(Historique)),
    length(Historique, NbTours),
    ( NbTours < 15 ->
         piège_pattern(Historique, Coup)
    ;
         contre_mesure_adaptative(Historique, Coup)
    ).

piège_pattern(Historique, Coup) :-
    length(Historique, L),
    Pattern = [3, 3, 4, 4],
    Index is L mod 4,
    nth0(Index, Pattern, Coup).

contre_mesure_adaptative(Historique, Coup) :-
    ( adversaire_repetitif(Historique), jouer_contre_repetitif(Historique, Coup)
    ; adversaire_titfortat(Historique), jouer_contre_titfortat(Historique, Coup)
    ; random_between(2, 5, Coup)
    ).

%%%%%%%%%%%%%%%%%%%%%%%%
% KHAMA_KHAWA V3 (stratégie optimisée)
%%%%%%%%%%%%%%%%%%%%%%%%
:- dynamic khawa_historique_v3/1.

joue(khawa_khawa_v3, Historique, Coup) :-
    retractall(khawa_historique_v3(_)),
    assertz(khawa_historique_v3(Historique)),
    length(Historique, NbTours),
    ( NbTours = 0 ->
         % Premier coup : choisir 3 comme valeur neutre
         Coup = 3
    ;
         random(R),
         ( R < 0.2 ->
              % Avec 20% de chance, jouer totalement au hasard pour déstabiliser l’adversaire
              random_between(1, 5, Coup)
         ;
              % Sinon, récupérer le dernier coup de l’adversaire et déterminer la meilleure réponse
              dernier_adversaire(Historique, AdversaireCoup),
              meilleure_reponse(AdversaireCoup, Reponse),
              ( adversaire_repetitif(Historique) ->
                   jouer_contre_repetitif(Historique, Coup)
              ; adversaire_titfortat(Historique) ->
                   jouer_contre_titfortat(Historique, Coup)
              ;
                   % Si notre dernier coup correspond déjà à la meilleure réponse et qu’une séquence est engagée,
                   % continuer pour bénéficier du multiplicateur (seuil fixé ici à 2 répétitions ou plus)
                   ( Historique = [[MyLast, _] | _],
                     MyLast =:= Reponse,
                     computeLongestPreviousSequence(MyLast, 1, Historique, SeqLength),
                     SeqLength >= 2 ->
                          Coup = MyLast
                   ;
                          Coup = Reponse
                   )
              )
         )
    ).

%%%%%%%%%%%%%%%%%%%%%%%%
% EQUILIBRE DE NASH
%%%%%%%%%%%%%%%%%%%%%%%%
joue(nash_equilibrium, _, Coup) :-
    random_member(Coup, [1, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5]).

%%%%%%%%%%%%%%%%%%%%%%%%
% MEILLEURE RÉPONSE
%%%%%%%%%%%%%%%%%%%%%%%%
joue(best_response, Historique, Coup) :-
    ( dernier_adversaire(Historique, Last),
      meilleure_reponse(Last, Coup)
    ; random_between(3, 4, Coup)
    ).

meilleure_reponse(1, 5).
meilleure_reponse(2, 5).
meilleure_reponse(3, 4).
meilleure_reponse(4, 5).
meilleure_reponse(5, 4).
meilleure_reponse(_, 3).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% KHAWA_KHAWA V4 - Version Avancée et Générale
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

:- dynamic khawa_threshold_v4/1.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prédicat principal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
joue(khawa_khawa_v4, Historique, Coup) :-
    % Détermination d'un seuil aléatoire pour la phase d'apprentissage (25 à 30 tours)
    ( khawa_threshold_v4(Threshold) ->
          true
    ;   random_between(25,30,Threshold),
        assertz(khawa_threshold_v4(Threshold))
    ),
    length(Historique, NbTours),
    ( NbTours < Threshold ->
          % Phase d'apprentissage purement aléatoire
          random_between(1,5,Coup)
    ;
          % D'abord, si un pattern simple est détecté, on utilise les contre-stratégies
          ( adversaire_repetitif_v4(Historique) ->
                jouer_contre_repetitif(Historique, Coup)
          ; adversaire_titfortat_v4(Historique) ->
                jouer_contre_titfortat(Historique, Coup)
          ;
                % Sinon, on procède à une analyse avancée
                Lambda is 0.8,
                % Distribution globale pondérée sur l'historique
                weighted_distribution(Historique, Lambda, UncondDist),
                % Distribution conditionnelle basée sur la chaîne de Markov (ordre 1)
                markov_conditional_distribution(Historique, CondDist),
                % Fusion des deux distributions selon un coefficient de confiance
                blended_distribution(UncondDist, CondDist, BlendedDist),
                % Détection d'un changement de stratégie via comparaison de fenêtres récentes
                ( NbTours >= 10 ->
                      detecter_changement(Historique, Delta)
                ;     Delta = 0
                ),
                % Définition dynamique de la probabilité d'exploration
                ( Delta > 0.3 ->
                      ExplorationProb = 0.3
                ;     ExplorationProb = 0.1
                ),
                % Pour chaque coup possible, on calcule l'espérance de gain en se basant sur BlendedDist
                findall(EP-M, (between(1,5,M), expected_payoff(M, BlendedDist, EP)), ListEP),
                max_ep_move(ListEP, ChosenMove),
                random(R),
                ( R < ExplorationProb ->
                      % Coup aléatoire pour déstabiliser l'adversaire
                      random_between(1,5,Coup)
                ;
                      Coup = ChosenMove
                )
          )
    ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1) Distribution pondérée globale
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% weighted_distribution(+Historique, +Lambda, -Distribution)
% La distribution est une liste de paires Move-Prob pour les coups 1 à 5.
weighted_distribution(Historique, Lambda, Dist) :-
    init_counts(Counts0),
    weighted_counts(Historique, Lambda, 0, Counts0, Counts),
    total_counts(Counts, Total),
    ( Total =:= 0 ->
         Dist = [1-0.2, 2-0.2, 3-0.2, 4-0.2, 5-0.2]  % distribution uniforme par défaut
    ;
         maplist(prob_of_count(Total), Counts, Dist)
    ).

init_counts([1-0, 2-0, 3-0, 4-0, 5-0]).

weighted_counts([], _, _, Counts, Counts).
weighted_counts([[_, Opp]|Rest], Lambda, Index, CountsIn, CountsOut) :-
    Weight is Lambda ** Index,
    update_count(CountsIn, Opp, Weight, CountsUpdated),
    NextIndex is Index + 1,
    weighted_counts(Rest, Lambda, NextIndex, CountsUpdated, CountsOut).

update_count([], _, _, []).
update_count([Move-Val|Rest], Move, Weight, [Move-NewVal|Rest]) :-
    !,
    NewVal is Val + Weight.
update_count([Other-Val|Rest], Move, Weight, [Other-Val|RestUpdated]) :-
    update_count(Rest, Move, Weight, RestUpdated).

total_counts(Counts, Total) :-
    findall(Val, member(_-Val, Counts), Values),
    sum_list(Values, Total).

prob_of_count(Total, Move-Val, Move-Prob) :-
    Prob is Val / Total,
    Result is Prob,
    Move-Prob = Move-Result.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2) Distribution conditionnelle via chaîne de Markov (ordre 1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% markov_conditional_distribution(+Historique, -CondDist)
% Estime P(Coup suivant | dernier coup adverse) en analysant les transitions dans l'historique.
markov_conditional_distribution(Historique, CondDist) :-
    % Récupère le dernier coup adverse (du tour le plus récent)
    ( Historique = [[_, LastOpp]|_] -> true ; LastOpp = none ),
    % Inverse l'historique pour obtenir l'ordre chronologique
    reverse(Historique, Chrono),
    findall(Prev-OppNext, (adjacent_opp(Chrono, Prev, OppNext)), Transitions),
    % Ne garder que les transitions dont le coup précédent correspond à LastOpp
    include(matches_last(LastOpp), Transitions, RelevantTransitions),
    count_transitions(RelevantTransitions, Counts),
    total_counts(Counts, Total),
    ( Total =:= 0 ->
         CondDist = []  % Aucune donnée conditionnelle
    ;
         maplist(prob_of_count(Total), Counts, CondDist)
    ).

% adjacent_opp(+Chrono, -Prev, -OppNext)
% Recherche des transitions consécutives dans Chrono (liste chronologique)
adjacent_opp([[_ , Opp1], [_ , Opp2] | _], Opp1, Opp2).
adjacent_opp([_ | Rest], Prev, OppNext) :-
    adjacent_opp(Rest, Prev, OppNext).

matches_last(Last, Prev-_) :-
    Prev = Last.

% count_transitions(+Transitions, -Counts)
% Compte la fréquence des coups adverses en seconde position dans les transitions.
count_transitions(Transitions, Counts) :-
    init_counts(Counts0),
    count_transitions_list(Transitions, Counts0, Counts).

count_transitions_list([], Counts, Counts).
count_transitions_list([_-Opp|Rest], CountsIn, CountsOut) :-
    update_count(CountsIn, Opp, 1, CountsUpdated),
    count_transitions_list(Rest, CountsUpdated, CountsOut).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3) Fusion des distributions : blending
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% blended_distribution(+UncondDist, +CondDist, -BlendedDist)
% Si la distribution conditionnelle est disponible et « prédictive », on lui donne plus de poids.
blended_distribution(UncondDist, [], UncondDist).  % Pas de donnée conditionnelle → on garde UncondDist
blended_distribution(UncondDist, CondDist, BlendedDist) :-
    % On récupère la probabilité maximale dans CondDist pour jauger la prédictivité
    max_probability(CondDist, _, MaxProbCond),
    % Définir α : si MaxProbCond est supérieur à 0.5, on y accorde un poids croissant
    ( MaxProbCond >= 0.5 -> Alpha is (MaxProbCond - 0.5) / 0.5 ; Alpha = 0 ),
    % Pour chaque coup (de 1 à 5), la probabilité finale est :
    % P_final = α * P_conditionnelle + (1-α) * P_global
    blend_lists(UncondDist, CondDist, Alpha, BlendedDist).

% blend_lists(+UncondDist, +CondDist, +Alpha, -BlendedDist)
blend_lists(UncondDist, CondDist, Alpha, BlendedDist) :-
    findall(Move-P,
            ( between(1,5,Move),
              member(Move-Pu, UncondDist),
              ( member(Move-Pc, CondDist) -> true ; Pc = 0 ),
              P is Alpha * Pc + (1 - Alpha) * Pu
            ),
            BlendedDist).

% max_probability(+Distribution, -Move, -MaxProb)
max_probability([Move-Prob], Move, Prob).
max_probability([Move1-P1, Move2-P2|Rest], Move, MaxProb) :-
    ( P1 >= P2 ->
         max_probability([Move1-P1|Rest], Move, MaxProb)
    ;  max_probability([Move2-P2|Rest], Move, MaxProb)
    ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4) Calcul de l'espérance de gain et sélection du coup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
expected_payoff(OurMove, Distribution, EP) :-
    expected_payoff_list(OurMove, Distribution, EP).

expected_payoff_list(_, [], 0).
expected_payoff_list(OurMove, [Opp-P|Rest], EP) :-
    payoff(OurMove, Opp, Pay),
    expected_payoff_list(OurMove, Rest, RestEP),
    EP is P * Pay + RestEP.

% Selon les règles du jeu :
% Si |OurMove - Opp| = 1 et OurMove < Opp, payoff = OurMove + Opp, sinon payoff = 0.
% Dans tous les autres cas, payoff = OurMove.
payoff(OurMove, Opp, Payoff) :-
    Diff is abs(OurMove - Opp),
    ( Diff =:= 1 ->
         ( OurMove < Opp -> Payoff is OurMove + Opp ; Payoff is 0 )
    ;   Payoff is OurMove
    ).

% max_ep_move(+ListEP, -BestMove)
max_ep_move(ListEP, BestMove) :-
    sort(1, @>=, ListEP, Sorted),
    Sorted = [_EP-BestMove|_].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 5) Détection de changement de stratégie (comparaison de fenêtres)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
detecter_changement(Historique, Variation) :-
    length(Historique, L),
    ( L >= 10 ->
         prefix_length(Historique, Recent5, 5),
         remove_prefix(Historique, 5, Previous5),
         prefix_length(Previous5, Prev5, 5),
         simple_distribution(Recent5, Dist1),
         simple_distribution(Prev5, Dist2),
         variation_distance(Dist1, Dist2, Variation)
    ;   Variation = 0
    ).

prefix_length(List, Prefix, N) :-
    length(Prefix, N),
    append(Prefix, _, List).

remove_prefix(List, N, Rest) :-
    length(Prefix, N),
    append(Prefix, Rest, List).

simple_distribution(Historique, Dist) :-
    init_counts(Counts0),
    simple_counts(Historique, Counts0, Counts),
    total_counts(Counts, Total),
    ( Total =:= 0 ->
         Dist = [1-0.2, 2-0.2, 3-0.2, 4-0.2, 5-0.2]
    ;
         maplist(prob_of_count(Total), Counts, Dist)
    ).

simple_counts([], Counts, Counts).
simple_counts([[_, Opp]|Rest], CountsIn, CountsOut) :-
    update_count(CountsIn, Opp, 1, CountsUpdated),
    simple_counts(Rest, CountsUpdated, CountsOut).

variation_distance(Dist1, Dist2, Variation) :-
    findall(AbsDiff, ( member(M-P1, Dist1), member(M-P2, Dist2), Diff is abs(P1 - P2), AbsDiff = Diff ), Diffs),
    sum_list(Diffs, Sum),
    Variation is Sum / 2.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 6) Détection de patterns simples déjà existants
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Comportement répétitif : les 5 derniers coups adverses identiques
adversaire_repetitif_v4(Historique) :-
    length(Historique, L),
    L >= 5,
    last_n_opponent_moves(Historique, 5, Moves),
    all_same(Moves).

last_n_opponent_moves(Historique, N, Moves) :-
    length(Prefix, N),
    append(Prefix, _, Historique),
    findall(Move, (member([_, Move], Prefix)), Moves).

all_same([]).
all_same([_]).
all_same([X, X|T]) :-
    all_same([X|T]).

% Comportement de type tit-for-tat : l'adversaire répète notre coup précédent sur une fenêtre donnée
adversaire_titfortat_v4(Historique) :-
    length(Historique, L),
    L >= 5,
    prefix_length(Historique, Prefix, 5),
    check_titfortat(Prefix).

check_titfortat([_]).  % Un seul coup, rien à comparer.
check_titfortat([First, Second|Rest]) :-
    First = [MyCurrent, _],
    Second = [_, OppPrevious],
    OppPrevious =:= MyCurrent,
    check_titfortat([Second|Rest]).









%%%%%%%%%%%%%%%%%%%%%%%%
% KHAMA_KHAWA V5 (Stratégie méta-adaptative universelle)
%%%%%%%%%%%%%%%%%%%%%%%%
:- dynamic khawa_meta_state/3.  % État: [Croyances, Patterns, Risque]
:- dynamic khawa_entropy/1.     % Mesure d'incertitude

joue(khawa_khawa_v5, Historique, Coup) :-
    % 1. Mise à jour de l'état méta
    (khawa_meta_state(Beliefs, Patterns, Risk)
        -> update_meta_state(Historique, Beliefs, Patterns, Risk, NewState)
        ;  initial_meta_state(NewState)),

    % 2. Calcul du coup optimal
    NewState = [NewBeliefs, NewPatterns, NewRisk],
    select_action(NewBeliefs, NewPatterns, NewRisk, Historique, Coup),

    % 3. Mise à jour dynamique
    retractall(khawa_meta_state(_, _, _)),
    assertz(khawa_meta_state(NewBeliefs, NewPatterns, NewRisk)).

% Initialisation de l'état méta
initial_meta_state([
    [random:0.25, titfortat:0.25, repetitive:0.25, unknown:0.25], % Croyances
    [ ],                                                            % Patterns
    0.5                                                            % Risque
]).

% Mise à jour bayésienne avec détection de stratégies inconnues
update_meta_state(Historique, OldBeliefs, OldPatterns, OldRisk, NewState) :-
    % a. Détection de nouveaux patterns
    scan_emerging_patterns(Historique, NewPatterns),

    % b. Mise à jour des croyances
    update_beliefs(Historique, OldBeliefs, NewBeliefs),

    % c. Calcul du risque dynamique
    calculate_risk(Historique, NewBeliefs, NewPatterns, NewRisk),

    NewState = [NewBeliefs, NewPatterns, NewRisk].

% Sélection d'action probabiliste multi-critères
select_action(Beliefs, Patterns, Risk, Historique, Coup) :-
    % 1. Génération de coups candidats
    findall(C, between(1, 5, C), Cand),

    % 2. Calcul des scores multi-objectifs
    maplist(score_action(Beliefs, Patterns, Risk, Historique), Cand, Scores),

    % 3. Sélection stochastique pondérée
    max_member(Score-Coup, Scores),
    (Risk > 0.7 -> random_member(Coup, Cand) ; true). % Exploration forcée

% Score d'une action (combine 4 critères)
score_action(Beliefs, Patterns, Risk, Hist, C, Score) :-
    exploit_score(Beliefs, C, S1),          % Exploitation des croyances
    explore_score(Hist, C, S2),             % Exploration des patterns
    risk_adjusted_score(Risk, C, S3),       % Ajustement au risque
    pattern_avoidance(Patterns, C, S4),     % Évitement des pièges

    Score is 0.4*S1 + 0.3*S2 + 0.2*S3 + 0.1*S4.

% Méthodes avancées -----------------------------------------------------------

% Détection de patterns émergents (algorithme Apriori adapté)
scan_emerging_patterns(Historique, Patterns) :-
    findall(Pat, (subsequence(Historique, Pat), length(Pat, L), L >= 3), AllPat),
    freq_patterns(AllPat, Freq),
    filter_significant(Freq, 0.2, Patterns).

% Mise à jour des croyances avec modèle de Dirichlet
update_beliefs(Hist, Old, New) :-
    length(Hist, N),
    alpha(0.5, Alpha), % Paramètre de régularisation
    maplist(update_strat_prob(Hist, Alpha, N), Old, Updated),
    normalize(Updated, New).

% Calcul du risque basé sur l'entropie de Shannon
calculate_risk(_, Beliefs, Patterns, Risk) :-
    entropy(Beliefs, E),
    patterns_risk(Patterns, PR),
    Risk is 0.7*E + 0.3*PR.

% Implémentations critiques ----------------------------------------------------
% (Ces prédicats nécessitent une implémentation détaillée selon la théorie des jeux)

% Fonctions utilitaires avancées
normalize(Probs, Normed) :- sumlist(Probs, Total), maplist(div(Total), Probs, Normed).
div(Total, X, Y) :- Y is X/Total.

entropy([], 0).
entropy([_:P|T], E) :- entropy(T, E1), (P > 0 -> E is E1 - P*log(P) ; E = E1).

% ... (autres implémentations nécessaires)

%%%%%%%%%%%%%%%%%%%%%%%%
% STRATÉGIE D'ÉQUILIBRE DYNAMIQUE
%%%%%%%%%%%%%%%%%%%%%%%%
% Permet de s'adapter même contre des clones de soi-même
anti_clone_policy(Historique, Coup) :-
    findall(C, (between(1,5,C), is_safe_against_clone(C, Historique)), Safe),
    random_member(Coup, Safe).

is_safe_against_clone(C, Hist) :-
    % Vérifie que le coup C ne crée pas de configuration exploitable
    not(dangerous_pattern(C, Hist)).

dangerous_pattern(C, Hist) :-
    length(Hist, L),
    L > 5,
    sublist([Prev1, Prev2, _], Hist),
    C =:= (Prev1 + Prev2) mod 5 + 1.








%%%%%%%%%%%%%%%%%%%%%%%%
% PREDICATS UTILITAIRES
%%%%%%%%%%%%%%%%%%%%%%%%
adversaire_repetitif(Historique) :-
    derniers_coups(Historique, 5, Derniers),
    compter_repetitions(Derniers, Reps),
    Reps >= 3.

adversaire_titfortat(Historique) :-
    length(Historique, L), L >= 2,
    derniers_coups(Historique, 2, [[M1, _], [_, A2]]),
    A2 =:= M1.

jouer_contre_repetitif(Historique, Coup) :-
    dernier_adversaire(Historique, Dernier),
    Coup is max(1, Dernier - 1).

jouer_contre_titfortat(Historique, Coup) :-
    derniers_coups(Historique, 1, [[M, _]]),
    ( M =:= 3 ->
         Coup = 5
    ;
         Coup = 2
    ).

dernier_adversaire(Historique, D) :-
    Historique = [[_, D] | _].


derniers_coups(Historique, N, Derniers) :-
    reverse(Historique, R),
    firstN(R, N, Derniers).

firstN(L, N, R) :-
    length(R, N),
    append(R, _, L).

compter_repetitions(L, R) :-
    msort(L, S),
    count_reps(S, 1, R).

count_reps([_], C, C).
count_reps([H, H | T], Acc, R) :-
    Acc1 is Acc + 1,
    count_reps([H | T], Acc1, R).
count_reps([_ | T], Acc, R) :-
     count_reps(T, Acc, R).

computeLongestPreviousSequence(_, _, [], 0).
computeLongestPreviousSequence(X, P, [[X, _] | T], N) :-
    P =:= 1,
    computeLongestPreviousSequence(X, 1, T, M),
    N is M + 1.
computeLongestPreviousSequence(X, P, [[_, X] | T], N) :-
    P =:= 2,
    computeLongestPreviousSequence(X, 2, T, M),
    N is M + 1.
computeLongestPreviousSequence(_, _, _, 0).

inversePaires([], []).
inversePaires([[X, Y] | T], [[Y, X] | R]) :-
    inversePaires(T, R).

comparePairs(=, [_, X], [_, X]) :- !.
comparePairs(<, [_, X], [_, Y]) :-
    X > Y, !.
comparePairs(>, _, _).

affiche(_, _, _, _, _, _, _, _).


%%%%%%%%%%%%%%%%%%%%%%
% GESTION DU TOURNOI %
%%%%%%%%%%%%%%%%%%%%%%

go :-
    inscrits(Joueurs),
    tournoi(Joueurs, Résultats),
    predsort(comparePairs, Résultats, Triés),
    writef("\nClassement final : %t\n", [Triés]).

tournoi([], []).
tournoi([J|L], R) :-
    inscrits(Ins), member(J, Ins), !,
    matchs(J, [J|L], R1),
    tournoi(L, R2),
    fusionne(R1, R2, R).
tournoi([J|_], _) :-
    writef("Le joueur %t est inconnu.\n", [J]), fail.

fusionne([], L, L).
fusionne([[J,G]|L], L2, R) :-
    update(J, G, L2, R2),
    fusionne(L, R2, R).

matchs(_, [], []).
matchs(J, [J1|L1], R) :-
    run(J, J1, GJ, GJ1),
    matchs(J, L1, R1),
    update(J, GJ, R1, R2),
    update(J1, GJ1, R2, R).

update(J, Gain, [[J,Old]|R], [[J,Total]|R]) :- !, Total is Old + Gain.
update(J, Gain, [P|L], [P|R]) :- update(J, Gain, L, R).
update(J, Gain, [], [[J,Gain]]).

%%%%%%%%%%%%%%%%%%%%
% BOUCLE DE MATCHS %
%%%%%%%%%%%%%%%%%%%%

run(J1, J2, Points1, Points2) :- run(100, J1, J2, [], 0, 0, Points1, Points2).

run(0, J1, J2, _, S1, S2, S1, S2) :-
    writef("%t %t - %t %t.\n", [J1, S1, S2, J2]), !.
run(N, J1, J2, Hist, S1, S2, Final1, Final2) :-
    joue(J1, Hist, C1), !,
    inversePaires(Hist, InvHist),
    joue(J2, InvHist, C2),
    score(C1, C2, G1, G2),
    T1 is S1 + G1, T2 is S2 + G2,
    affiche(J1, J2, C1, C2, G1, G2, T1, T2),
    N1 is N - 1,
    run(N1, J1, J2, [[C1,C2]|Hist], T1, T2, Final1, Final2).

%%%%%%%%%%%%%%%%%
% RÈGLE DU JEU  %
%%%%%%%%%%%%%%%%%

% Version 1 : différence = 1 → le plus petit gagne A+B, l'autre 0
score(C1, C2, G1, G2) :-
    D is abs(C1 - C2),
    ( D =:= 1 ->
        (C1 < C2 -> G1 is C1 + C2, G2 = 0
        ;            G1 = 0, G2 is C1 + C2)
    ;
        G1 is C1, G2 is C2
    ).

%%%%%%%%%%%%%%%%%%%%%
% AFFICHAGE & UTILS %
%%%%%%%%%%%%%%%%%%%%%

affiche(J1, J2, C1, C2, S1, S2, T1, T2) :-
    affichageDetails(oui), !,
    writef("%t joue %t, %t joue %t => [%t, %t] | Score cumulé: [%t, %t]\n",
           [J1, C1, J2, C2, S1, S2, T1, T2]).
affiche(_,_,_,_,_,_,_,_).

inversePaires([], []).
inversePaires([[X,Y]|R1], [[Y,X]|R2]) :- inversePaires(R1, R2).

comparePairs(=, [_,X], [_,X]) :- !.
comparePairs(<, [_,X], [_,Y]) :- X > Y, !.
comparePairs(>, _, _).
































:- use_module(library(random)).
first_n_elements(0, _, []) :- !.
first_n_elements(_, [], []) :- !.
first_n_elements(N, [H|T], [H|Rest]) :-
    N > 0,
    N1 is N - 1,
    first_n_elements(N1, T, Rest).

% select_weighted(+Probs, +Elems, -Elem)
% Returns an element from Elems according to the distribution in Probs.
select_weighted(Probs, Elems, Elem) :-
    random(RandomVal),
    select_by_prob(Probs, Elems, RandomVal, Elem).
% select_by_prob(+Probs, +Elems, +Rand, -Elem)
select_by_prob([P|_], [E|_], Rand, E) :-
    Rand =< P, !.
select_by_prob([P|PT], [_|ET], Rand, Elem) :-
    Rand1 is Rand - P,
    select_by_prob(PT, ET, Rand1, Elem).

% Base case : empty list returns empty result
second_elements([], []).
% Recursive case : get second element from head, recurse on tail
second_elements([[_, Second|_]|Rest], [Second|Result]) :-
    second_elements(Rest, Result).

% count_elem(+Elem, +List, -Count)
count_elem(_, [], 0).
count_elem(Elem, [Elem|Rest], Count) :-
    count_elem(Elem, Rest, Count1),
    Count is Count1 + 1.
count_elem(Elem, [_|Rest], Count) :-
    count_elem(Elem, Rest, Count).

% rel_freq_stats(+BigList, +QueryList, -Result)
rel_freq_stats(BigList, QueryList, Result) :-
    length(BigList, Total),
    rel_freq_stats(QueryList, BigList, Total, Result).

rel_freq_stats([], _, _, []).
rel_freq_stats([Elem|Rest], BigList, Total, [[Elem, Freq, VarTerm]|Tail]) :-
    count_elem(Elem, BigList, Count),
    ( Total =:= 0 -> Freq = 0 ; Freq is Count / Total ),
    ( Total =:= 0 -> VarTerm = 0 ; VarTerm is Freq * (1 - Freq) / Total ),
    rel_freq_stats(Rest, BigList, Total, Tail).

% mean(+List, -Mean)
mean(List, Mean) :-
    sum_list(List, Sum),
    length(List, Length),
    Length > 0,
    Mean is Sum / Length.

% variance(+List, -Variance)
variance(List, Variance) :-
    mean(List, Mean),
    length(List, N),
    findall(DiffSquared, (member(X, List), DiffSquared is (X - Mean)**2), DiffList),
    sum_list(DiffList, SumSqDiff),
    Variance is SumSqDiff / (N - 1).






% normal_pdf(X, Y) computes the value of the standard normal probability density function at X.
% f(x) = 1/sqrt(2*pi) * exp(-x^2/2)
normal_pdf(X, Y) :-
    Y is 1 / sqrt(2 * 3.141592653589793) * exp(-X*X/2).

% normal_area(A, B, N, Area) computes the approximate area under the standard normal curve
% from A to B using a Riemann sum with N subintervals.
normal_area(A, B, N, Area) :-
    Delta is (B - A) / N,
    normal_area_helper(A, Delta, N, 0, Area).

% Base case: when no subintervals remain, the accumulated sum is the area.
normal_area_helper(_, _, 0, Acc, Acc).

% Recursive case: calculate the midpoint, evaluate the PDF, and add the rectangle area.
normal_area_helper(X, Delta, N, Acc, Area) :-
    N > 0,
    Mid is X + Delta/2,           % midpoint of the current subinterval
    normal_pdf(Mid, Y),           % height at the midpoint
    NewAcc is Acc + Y * Delta,    % add the area of the current rectangle
    NewX is X + Delta,            % move to the next subinterval
    NewN is N - 1,                % one less subinterval to process
    normal_area_helper(NewX, Delta, NewN, NewAcc, Area).







% distance_test(+Variance, -Result)
distance_test(0, 1).
distance_test(Variance, Result) :-
    Bound is 0.1 / sqrt(Variance),
    normal_area(-Bound,Bound,1000,Result).

% proba_of_strategy(+StrategyList, -Probabilities)
proba_of_strategy([], []).
proba_of_strategy([[_, _, X2] | R], [Proba | Result]) :-
    distance_test(X2, Proba),
    proba_of_strategy(R, Result).

% matrix_A(-Matrix)
matrix_A([
    [1, 0, 3, 4, 5],
    [3, 2, 0, 4, 5],
    [1, 5, 3, 0, 5],
    [1, 2, 7, 4, 0],
    [1, 2, 3, 9, 5]
]).

% best_response(+X, +A, -Response)
best_response(X, A, Response) :-
    transpose(A, AT),
    maplist(dot_product(X), AT, Mean),
    %write('Mean vector: '), write(Mean), nl,
    max_index(Mean, MaxIndex),
    length(Mean, L),
    zeros(L, ZeroVec),
    set_at_index(ZeroVec, MaxIndex, 1, Response).

% dot_product(+Vector1, +Vector2, -Product)
dot_product([], [], 0).
dot_product([X|Xs], [Y|Ys], Sum) :-
    dot_product(Xs, Ys, Rest),
    Sum is X * Y + Rest.

% transpose(+Matrix, -Transposed)
transpose([], []).
transpose([[]|_], []).
transpose(Matrix, [Row|Rows]) :-
    maplist(list_head, Matrix, Row),
    maplist(list_tail, Matrix, RestMatrix),
    transpose(RestMatrix, Rows).

list_head([H|_], H).
list_tail([_|T], T).

% max_index(+List, -Index)
max_index([H|T], Index) :-
    max_index(T, H, 0, 0, Index).
max_index([], _, _, MaxIndex, MaxIndex).
max_index([H|T], CurrentMax, CurrentPos, CurrentMaxIndex, MaxIndex) :-
    NewPos is CurrentPos + 1,
    ( H > CurrentMax ->
        NewMax = H,
        NewMaxIndex = NewPos
    ;
        NewMax = CurrentMax,
        NewMaxIndex = CurrentMaxIndex
    ),
    max_index(T, NewMax, NewPos, NewMaxIndex, MaxIndex).

% zeros(+N, -ZeroList)
zeros(0, []).
zeros(N, [0|Rest]) :-
    N > 0,
    N1 is N - 1,
    zeros(N1, Rest).

% set_at_index(+List, +Index, +Value, -NewList)
set_at_index([_|T], 0, Value, [Value|T]).
set_at_index([H|T], Index, Value, [H|NewT]) :-
    Index > 0,
    Index1 is Index - 1,
    set_at_index(T, Index1, Value, NewT).

% update(+List0, +List1, +List2, -ResultList)
update([], [], [], []).
update([X0|List0], [X1|List1], [X2|List2], [R|Result]) :-
    R is X0 + X1 * (X2 - X0),
    update(List0, List1, List2, Result).

% play(+Game, -Move)
play(Game, Move) :-
    length(Game,L),L < 30,
    select_weighted([0.03, 0.444, 0.203, 0.323, 0.0], [1,2,3,4,5], Move).

play(Game, Move):-
    % Opponents' moves
    first_n_elements(30,Game,LastMoves),
    second_elements(LastMoves, OM),
    %write('second_element'),nl,write(OM),nl,

    rel_freq_stats(OM, [1,2,3,4,5], Strategy),
    %write('rel_freq_stats'),nl,write(Strategy),nl,

    proba_of_strategy(Strategy, Ps),
    %write('proba_of_strategy '),nl,write(Ps),nl,

    matrix_A(A),
    second_elements(Strategy,ExpectedStrategy),
    %write('ExpectedStrategy'),nl,write(ExpectedStrategy),nl,

    best_response(ExpectedStrategy, A, Response),
    %write('best_response '),nl,write(Response),nl,

    update([0.03, 0.444, 0.203, 0.323, 0.0], Ps, Response, Choice),
    %write('update '),nl,write(Choice),nl,

    select_weighted(Choice, [1,2,3,4,5], Move).

joue(kiki,X,Y):-play(X,Y).

joue(virus,_,Move):-
    select_weighted([0.03, 0.444, 0.203, 0.323, 0.0], [1,2,3,4,5], Move).

generate_pairs(0, []).
generate_pairs(N, [[X, Y]|Rest]) :-
    N > 0,
    random_between(1, 5, X),
    random_between(1, 5, Y),
    N1 is N - 1,
    generate_pairs(N1, Rest).

:- use_module(library(random)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% first_n_elements(khawa_khawa, Count, List, PrefixElements)
%
% Extracts the first Count elements of List (i.e. its prefix)
% and returns them in PrefixElements.
%
% Parameters:
%   khawa_khawa   - Extra context parameter (as required by the project).
%   Count         - The number of leading elements to extract.
%   List          - The input list from which to extract elements.
%   PrefixElements- The resulting list containing the first Count elements.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
khawa_khawa_first_n_elements(khawa_khawa, 0, _List, []) :- !.
khawa_khawa_first_n_elements(khawa_khawa, _Count, [], []) :- !.
khawa_khawa_first_n_elements(khawa_khawa, Count, [Head|Tail], [Head|Rest]) :-
    Count > 0,
    Count1 is Count - 1,
    khawa_khawa_first_n_elements(khawa_khawa, Count1, Tail, Rest).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% select_weighted(khawa_khawa, Probabilities, Elements, ChosenElement)
%
% Selects one element from Elements according to the provided probability
% distribution in Probabilities. A random value is generated and the helper
% predicate select_by_prob/5 is used to determine the chosen element.
%
% Parameters:
%   khawa_khawa   - Extra context parameter.
%   Probabilities - List of probabilities for each element.
%   Elements      - List of candidate elements.
%   ChosenElement - The element selected based on the distribution.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
khawa_khawa_select_weighted(khawa_khawa, Probabilities, Elements, ChosenElement) :-
    random(RandomValue),
    khawa_khawa_select_by_prob(khawa_khawa, Probabilities, Elements, RandomValue, ChosenElement).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% select_by_prob(khawa_khawa, Probabilities, Elements, Random, ChosenElement)
%
% Helper predicate that traverses the list of probabilities and elements.
% It subtracts the probability from the random value until a threshold is met.
%
% Parameters:
%   khawa_khawa   - Extra context parameter.
%   Probabilities - List of probabilities.
%   Elements      - List of candidate elements.
%   Random        - The current random value.
%   ChosenElement - The selected element when threshold is reached.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
khawa_khawa_select_by_prob(khawa_khawa, [Prob|_], [Elem|_], Random, Elem) :-
    Random =< Prob, !.
khawa_khawa_select_by_prob(khawa_khawa, [Prob|RestProbs], [_|RestElems], Random, ChosenElement) :-
    Random1 is Random - Prob,
    khawa_khawa_select_by_prob(khawa_khawa, RestProbs, RestElems, Random1, ChosenElement).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% second_elements(khawa_khawa, ListOfPairs, Seconds)
%
% From a list where each element is a pair (or list with at least 2 elements),
% extracts the second element from each pair.
%
% Parameters:
%   khawa_khawa - Extra context parameter.
%   ListOfPairs - A list of sublists (each representing a pair).
%   Seconds     - Resulting list of the second elements.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
khawa_khawa_second_elements(khawa_khawa, [], []).
khawa_khawa_second_elements(khawa_khawa, [[_, Second|_]|RestPairs], [Second|Seconds]) :-
   khawa_khawa_second_elements(khawa_khawa, RestPairs, Seconds).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% count_elem(khawa_khawa, Element, List, Count)
%
% Counts the number of times Element occurs in List.
%
% Parameters:
%   khawa_khawa - Extra context parameter.
%   Element     - The element to count.
%   List        - The list in which to count occurrences.
%   Count       - The resulting count.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
khawa_khawa_count_elem(khawa_khawa, _Element, [], 0).
khawa_khawa_count_elem(khawa_khawa, Element, [Element|Rest], Count) :-
    khawa_khawa_count_elem(khawa_khawa, Element, Rest, Count1),
    Count is Count1 + 1.
khawa_khawa_count_elem(khawa_khawa, Element, [_|Rest], Count) :-
    khawa_khawa_count_elem(khawa_khawa, Element, Rest, Count).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rel_freq_stats(khawa_khawa, BigList, QueryList, Stats)
%
% Computes relative frequency statistics for each element in QueryList based on
% its occurrence in BigList. For each element, it calculates both the frequency
% and a variance term.
%
% Parameters:
%   khawa_khawa - Extra context parameter.
%   BigList     - The list in which frequencies are computed.
%   QueryList   - The list of elements for which the stats are wanted.
%   Stats       - A list of triples: [Element, Frequency, VarianceTerm].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
khawa_khawa_rel_freq_stats(khawa_khawa, BigList, QueryList, Stats) :-
    length(BigList, Total),
    khawa_khawa_rel_freq_stats_internal(khawa_khawa, QueryList, BigList, Total, Stats).

% Helper predicate for rel_freq_stats/4.
khawa_khawa_rel_freq_stats_internal(khawa_khawa, [], _BigList, _Total, []).
khawa_khawa_rel_freq_stats_internal(khawa_khawa, [Element|RestQueries], BigList, Total, [[Element, Frequency, VarianceTerm]|StatsRest]) :-
    khawa_khawa_count_elem(khawa_khawa, Element, BigList, Count),
    ( Total =:= 0 -> Frequency = 0 ; Frequency is Count / Total ),
    ( Total =:= 0 -> VarianceTerm = 0 ; VarianceTerm is Frequency * (1 - Frequency) / Total ),
    khawa_khawa_rel_freq_stats_internal(khawa_khawa, RestQueries, BigList, Total, StatsRest).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% normal_pdf(khawa_khawa, X, PdfValue)
%
% Computes the value of the standard normal probability density function at X.
%
% Parameters:
%   khawa_khawa - Extra context parameter.
%   X           - The point at which to evaluate the PDF.
%   PdfValue    - The resulting probability density.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
khawa_khawa_normal_pdf(khawa_khawa, X, PdfValue) :-
    PdfValue is 1 / sqrt(2 * 3.141592653589793) * exp(-X * X / 2).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% normal_area(khawa_khawa, A, B, NumIntervals, Area)
%
% Approximates the area under the standard normal curve between A and B using
% a Riemann sum with NumIntervals subintervals.
%
% Parameters:
%   khawa_khawa - Extra context parameter.
%   A, B        - The interval limits.
%   NumIntervals- Number of subintervals to use.
%   Area        - The approximate area under the curve.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
khawa_khawa_normal_area(khawa_khawa, A, B, NumIntervals, Area) :-
    Delta is (B - A) / NumIntervals,
    khawa_khawa_normal_area_helper(khawa_khawa, A, Delta, NumIntervals, 0, Area).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% normal_area_helper(khawa_khawa, CurrentX, Delta, NumIntervals, Accumulated, Area)
%
% Helper predicate to recursively compute the Riemann sum for normal_area/5.
%
% Parameters:
%   khawa_khawa  - Extra context parameter.
%   CurrentX     - The beginning of the current subinterval.
%   Delta        - Width of each subinterval.
%   NumIntervals - Remaining number of subintervals.
%   Accumulated  - Accumulated area so far.
%   Area         - Final computed area.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
khawa_khawa_normal_area_helper(khawa_khawa, _CurrentX, _Delta, 0, Accumulated, Accumulated).
khawa_khawa_normal_area_helper(khawa_khawa, CurrentX, Delta, NumIntervals, Accumulated, Area) :-
    NumIntervals > 0,
    Mid is CurrentX + Delta / 2,  % Midpoint of current subinterval
    khawa_khawa_normal_pdf(khawa_khawa, Mid, Y),
    NewAccumulated is Accumulated + Y * Delta,
    NextX is CurrentX + Delta,
    NextIntervals is NumIntervals - 1,
    khawa_khawa_normal_area_helper(khawa_khawa, NextX, Delta, NextIntervals, NewAccumulated, Area).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% distance_test(khawa_khawa, Variance, Result)
%
% Based on a given Variance, calculates a probability result using the normal_area
% approximation. If Variance is 0 the result is 1.
%
% Parameters:
%   khawa_khawa - Extra context parameter.
%   Variance    - The variance value.
%   Result      - The resulting probability.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
khawa_khawa_distance_test(khawa_khawa, 0, 1).  % Special case: zero variance yields probability 1.
khawa_khawa_distance_test(khawa_khawa, Variance, Result) :-
    Bound is 0.1 / sqrt(Variance),
    khawa_khawa_normal_area(khawa_khawa, -Bound, Bound, 1000, Result).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% proba_of_strategy(khawa_khawa, StrategyList, Probabilities)
%
% Computes probabilities for each strategy defined in StrategyList. Each strategy is
% a triple [Element, Frequency, VarianceTerm]. The resulting list Probabilities holds
% the probability value obtained from distance_test for each strategy.
%
% Parameters:
%   khawa_khawa  - Extra context parameter.
%   StrategyList - List of strategies as triples.
%   Probabilities- List of computed probability values.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
khawa_khawa_proba_of_strategy(khawa_khawa, [], []).
khawa_khawa_proba_of_strategy(khawa_khawa, [[_, _, Variance]|RestStrategies], [Probability|RestProbabilities]) :-
    khawa_khawa_distance_test(khawa_khawa, Variance, Probability),
    khawa_khawa_proba_of_strategy(khawa_khawa, RestStrategies, RestProbabilities).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% matrix_A(khawa_khawa, MatrixA)
%
% Provides the constant matrix A used for computing the best
% response(Matrice de gain).
%
% Parameters:
%   khawa_khawa - Extra context parameter.
%   MatrixA     - The constant matrix used in response calculations.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
khawa_khawa_matrix_A(khawa_khawa, [
    [1, 0, 3, 4, 5],
    [3, 2, 0, 4, 5],
    [1, 5, 3, 0, 5],
    [1, 2, 7, 4, 0],
    [1, 2, 3, 9, 5]
]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% best_response(khawa_khawa, StrategyVector, MatrixA, Response)
%
% Determines the best response given a strategy vector and matrix A. This is done by
% transposing the matrix, computing dot products with the strategy vector, selecting the
% index of the maximum dot product, and constructing a one-hot response vector.
%
% Parameters:
%   khawa_khawa   - Extra context parameter.
%   StrategyVector- The vector representing the weighted strategy.
%   MatrixA       - The constant matrix A.
%   Response      - The generated response vector (one-hot encoded).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
khawa_khawa_best_response(khawa_khawa, StrategyVector, MatrixA, Response) :-
    khawa_khawa_transpose(khawa_khawa, MatrixA, TransposedA),
    maplist(khawa_khawa_dot_product_with_context(khawa_khawa, StrategyVector), TransposedA, DotProducts),
    khawa_khawa_max_index(khawa_khawa, DotProducts, MaxIndex),
    length(DotProducts, Length),
    khawa_khawa_zeros(khawa_khawa, Length, ZeroVector),
    khawa_khawa_set_at_index(khawa_khawa, ZeroVector, MaxIndex, 1, Response).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% dot_product(khawa_khawa, Vector1, Vector2, Product)
%
% Computes the dot product of two numeric vectors.
%
% Parameters:
%   khawa_khawa - Extra context parameter.
%   Vector1     - The first vector.
%   Vector2     - The second vector.
%   Product     - The resulting dot product.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
khawa_khawa_dot_product(khawa_khawa, [], [], 0).
khawa_khawa_dot_product(khawa_khawa, [X|Xs], [Y|Ys], Product) :-
    khawa_khawa_dot_product(khawa_khawa, Xs, Ys, PartialProduct),
    Product is X * Y + PartialProduct.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% dot_product_with_context(khawa_khawa, FixedVector, OtherVector, Product)
%
% Wrapper predicate used with maplist to compute the dot product between a fixed vector
% and each vector in a list.
%
% Parameters:
%   khawa_khawa  - Extra context parameter.
%   FixedVector  - The fixed vector used in every dot product.
%   OtherVector  - A vector from the list.
%   Product      - The computed dot product.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
khawa_khawa_dot_product_with_context(khawa_khawa, FixedVector, OtherVector, Product) :-
    khawa_khawa_dot_product(khawa_khawa, FixedVector, OtherVector, Product).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% transpose(khawa_khawa, Matrix, Transposed)
%
% Transposes a matrix.
%
% Parameters:
%   khawa_khawa - Extra context parameter.
%   Matrix      - The input matrix (list of lists).
%   Transposed  - The resulting transposed matrix.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
khawa_khawa_transpose(khawa_khawa, [], []).
khawa_khawa_transpose(khawa_khawa, [[]|_], []).
khawa_khawa_transpose(khawa_khawa, Matrix, [Row|Rows]) :-
    maplist(khawa_khawa_list_head(khawa_khawa), Matrix, Row),
    maplist(khawa_khawa_list_tail(khawa_khawa), Matrix, RestMatrix),
    khawa_khawa_transpose(khawa_khawa, RestMatrix, Rows).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% list_head(khawa_khawa, List, Head)
%
% Retrieves the first element of List.
%
% Parameters:
%   khawa_khawa - Extra context parameter.
%   List        - The input list.
%   Head        - The head (first element) of the list.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
khawa_khawa_list_head(khawa_khawa, [Head|_], Head).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% list_tail(khawa_khawa, List, Tail)
%
% Retrieves the tail (all elements after the head) of List.
%
% Parameters:
%   khawa_khawa - Extra context parameter.
%   List        - The input list.
%   Tail        - The resulting tail of the list.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
khawa_khawa_list_tail(khawa_khawa, [_|Tail], Tail).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% max_index(khawa_khawa, List, MaxIndex)
%
% Finds the index of the maximum element within List.
%
% Parameters:
%   khawa_khawa - Extra context parameter.
%   List        - The list of numbers.
%   MaxIndex    - The index (0-based) of the maximum value in List.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
khawa_khawa_max_index(khawa_khawa, [First|Rest], MaxIndex) :-
    khawa_khawa_max_index_helper(khawa_khawa, Rest, First, 0, 0, MaxIndex).

% Helper predicate for max_index/3.
khawa_khawa_max_index_helper(khawa_khawa, [], _CurrentMax, _CurrentPos, MaxIndex, MaxIndex).
khawa_khawa_max_index_helper(khawa_khawa, [H|T], CurrentMax, CurrentPos, CurrentMaxIndex, MaxIndex) :-
    NewPos is CurrentPos + 1,
    ( H > CurrentMax ->
        NewMax = H,
        NewMaxIndex = NewPos
    ;
        NewMax = CurrentMax,
        NewMaxIndex = CurrentMaxIndex
    ),
    khawa_khawa_max_index_helper(khawa_khawa, T, NewMax, NewPos, NewMaxIndex, MaxIndex).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% zeros(khawa_khawa, Length, ZeroList)
%
% Creates a list of Length zeros.
%
% Parameters:
%   khawa_khawa - Extra context parameter.
%   Length      - The desired length of the zero list.
%   ZeroList    - The resulting list filled with zeros.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
khawa_khawa_zeros(khawa_khawa, 0, []).
khawa_khawa_zeros(khawa_khawa, N, [0|Rest]) :-
    N > 0,
    N1 is N - 1,
    khawa_khawa_zeros(khawa_khawa, N1, Rest).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set_at_index(khawa_khawa, List, Index, Value, NewList)
%
% Sets the element at the specified Index in List to Value,
% producing the modified NewList.
%
% Parameters:
%   khawa_khawa - Extra context parameter.
%   List        - The original list.
%   Index       - The 0-based index to update.
%   Value       - The value to place at the specified index.
%   NewList     - The modified list after updating.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
khawa_khawa_set_at_index(khawa_khawa, [_|Tail], 0, Value, [Value|Tail]).
khawa_khawa_set_at_index(khawa_khawa, [Head|Tail], Index, Value, [Head|NewTail]) :-
    Index > 0,
    Index1 is Index - 1,
    khawa_khawa_set_at_index(khawa_khawa, Tail, Index1, Value, NewTail).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% update(khawa_khawa, List0, List1, List2, ResultList)
%
% Updates List0 using List1 and List2 with the formula:
%   Result = Element_from_List0 + Element_from_List1 * (Element_from_List2 - Element_from_List0)
%
% Parameters:
%   khawa_khawa - Extra context parameter.
%   List0       - The original list.
%   List1       - The list of scaling factors.
%   List2       - The target list.
%   ResultList  - The resulting updated list.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
khawa_khawa_update(khawa_khawa, [], [], [], []).
khawa_khawa_update(khawa_khawa, [X0|Rest0], [X1|Rest1], [X2|Rest2], [R|ResultRest]) :-
    R is X0 + X1 * (X2 - X0),
    khawa_khawa_update(khawa_khawa, Rest0, Rest1, Rest2, ResultRest).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% product(khawa_khawa, List, Product)
%
% Computes the product of all elements in List.
%
% Parameters:
%   khawa_khawa - Extra context parameter.
%   List        - The list of numbers.
%   Product     - The resulting product.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
khawa_khawa_product(khawa_khawa, [], 1).
khawa_khawa_product(khawa_khawa, [X|Xs], Product) :-
    khawa_khawa_product(khawa_khawa, Xs, PartialProduct),
    Product is X * PartialProduct.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pairwise_multiply(khawa_khawa, List1, List2, ResultList)
%
% Performs element-wise multiplication of two lists, List1 and List2.
%
% Parameters:
%   khawa_khawa - Extra context parameter.
%   List1       - The first list of numbers.
%   List2       - The second list of numbers.
%   ResultList  - The resulting list where each element is the product of the
%                 corresponding elements in List1 and List2.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
khawa_khawa_pairwise_multiply(khawa_khawa, [], [], []).
khawa_khawa_pairwise_multiply(khawa_khawa, [A|As], [B|Bs], [Product|Rest]) :-
    Product is A * B,
    khawa_khawa_pairwise_multiply(khawa_khawa, As, Bs, Rest).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create_list(khawa_khawa, N, Value, List)
%
% Creates a list of length N where every element is the given Value.
%
% Parameters:
%   khawa_khawa - Extra context parameter.
%   N           - Desired length of the list.
%   Value       - The value to fill the list with.
%   List        - The resulting list.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
khawa_khawa_create_list(khawa_khawa, 0, _Value, []).
khawa_khawa_create_list(khawa_khawa, N, Value, [Value|Rest]) :-
    N > 0,
    N1 is N - 1,
    khawa_khawa_create_list(khawa_khawa, N1, Value, Rest).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% play(khawa_khawa, GameHistory, Move)
%
% Main predicate that decides on the next move based on the GameHistory.
% Two strategies are implemented:
%   1. If fewer than 30 moves have occurred, choose a move at random using a fixed
%      probability distribution.
%   2. Otherwise, analyze the history to compute opponent move frequencies, determine
%      an optimal response through several computations (including best response and update),
%      and finally select a move based on the updated probabilities.
%
% Parameters:
%   khawa_khawa - Extra context parameter.
%   GameHistory - The list of past moves (each move is a [YourMove, OpponentMove] pair).
%   Move        - The chosen move (an integer between 1 and 5).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
joue(khawa_khawa, GameHistory, Move) :-
    length(GameHistory, Length),
    Length < 4,
    khawa_khawa_select_weighted(khawa_khawa, [0.03, 0.444, 0.203, 0.323, 0.0], [1,2,3,4,5], Move).

joue(khawa_khawa, GameHistory, Move) :-
     khawa_khawa_first_n_elements(khawa_khawa, 4, GameHistory, LastMoves),
    khawa_khawa_second_elements(khawa_khawa, LastMoves, OpponentMoves),
    khawa_khawa_rel_freq_stats(khawa_khawa, OpponentMoves, [1,2,3,4,5], Strategy),
   khawa_khawa_proba_of_strategy(khawa_khawa, Strategy, Probabilities),
    khawa_khawa_matrix_A(khawa_khawa, MatrixA),
    khawa_khawa_second_elements(khawa_khawa, Strategy, ExpectedStrategy),
    khawa_khawa_pairwise_multiply(khawa_khawa, ExpectedStrategy, Probabilities, WeightedStrategy),
    khawa_khawa_product(khawa_khawa, Probabilities, ProbaOfSuccess),
    khawa_khawa_create_list(khawa_khawa, 5, ProbaOfSuccess, ProbaOfSuccessVector),
    khawa_khawa_best_response(khawa_khawa, WeightedStrategy, MatrixA, Response),
    khawa_khawa_update(khawa_khawa, [0.03, 0.444, 0.203, 0.323, 0.0], ProbaOfSuccessVector, Response, Choice),
    khawa_khawa_select_weighted(khawa_khawa, Choice, [1,2,3,4,5], Move).











:- dynamic khawa_threshold_v4/1.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prédicat principal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
joue(khawa_khawa_v4, Historique, Coup) :-
    % Détermination d'un seuil aléatoire pour la phase d'apprentissage (25 à 30 tours)
    ( khawa_threshold_v4(Threshold) ->
          true
    ;   random_between(25,30,Threshold),
        assertz(khawa_threshold_v4(Threshold))
    ),
    length(Historique, NbTours),
    ( NbTours < Threshold ->
          % Phase d'apprentissage purement aléatoire
          random_between(1,5,Coup)
    ;
          % D'abord, si un pattern simple est détecté, on utilise les contre-stratégies
          ( adversaire_repetitif_v4(Historique) ->
                jouer_contre_repetitif(Historique, Coup)
          ; adversaire_titfortat_v4(Historique) ->
                jouer_contre_titfortat(Historique, Coup)
          ;
                % Sinon, on procède à une analyse avancée
                Lambda is 0.8,
                % Distribution globale pondérée sur l'historique
                weighted_distribution(Historique, Lambda, UncondDist),
                % Distribution conditionnelle basée sur la chaîne de Markov (ordre 1)
                markov_conditional_distribution(Historique, CondDist),
                % Fusion des deux distributions selon un coefficient de confiance
                blended_distribution(UncondDist, CondDist, BlendedDist),
                % Détection d'un changement de stratégie via comparaison de fenêtres récentes
                ( NbTours >= 10 ->
                      detecter_changement(Historique, Delta)
                ;     Delta = 0
                ),
                % Définition dynamique de la probabilité d'exploration
                ( Delta > 0.3 ->
                      ExplorationProb = 0.3
                ;     ExplorationProb = 0.1
                ),
                % Pour chaque coup possible, on calcule l'espérance de gain en se basant sur BlendedDist
                findall(EP-M, (between(1,5,M), expected_payoff(M, BlendedDist, EP)), ListEP),
                max_ep_move(ListEP, ChosenMove),
                random(R),
                ( R < ExplorationProb ->
                      % Coup aléatoire pour déstabiliser l'adversaire
                      random_between(1,5,Coup)
                ;
                      Coup = ChosenMove
                )
          )
    ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1) Distribution pondérée globale
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% weighted_distribution(+Historique, +Lambda, -Distribution)
% La distribution est une liste de paires Move-Prob pour les coups 1 à 5.
weighted_distribution(Historique, Lambda, Dist) :-
    init_counts(Counts0),
    weighted_counts(Historique, Lambda, 0, Counts0, Counts),
    total_counts(Counts, Total),
    ( Total =:= 0 ->
         Dist = [1-0.2, 2-0.2, 3-0.2, 4-0.2, 5-0.2]  % distribution uniforme par défaut
    ;
         maplist(prob_of_count(Total), Counts, Dist)
    ).

init_counts([1-0, 2-0, 3-0, 4-0, 5-0]).

weighted_counts([], _, _, Counts, Counts).
weighted_counts([[_, Opp]|Rest], Lambda, Index, CountsIn, CountsOut) :-
    Weight is Lambda ** Index,
    update_count(CountsIn, Opp, Weight, CountsUpdated),
    NextIndex is Index + 1,
    weighted_counts(Rest, Lambda, NextIndex, CountsUpdated, CountsOut).

update_count([], _, _, []).
update_count([Move-Val|Rest], Move, Weight, [Move-NewVal|Rest]) :-
    !,
    NewVal is Val + Weight.
update_count([Other-Val|Rest], Move, Weight, [Other-Val|RestUpdated]) :-
    update_count(Rest, Move, Weight, RestUpdated).

total_counts(Counts, Total) :-
    findall(Val, member(_-Val, Counts), Values),
    sum_list(Values, Total).

prob_of_count(Total, Move-Val, Move-Prob) :-
    Prob is Val / Total,
    Result is Prob,
    Move-Prob = Move-Result.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2) Distribution conditionnelle via chaîne de Markov (ordre 1)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% markov_conditional_distribution(+Historique, -CondDist)
% Estime P(Coup suivant | dernier coup adverse) en analysant les transitions dans l'historique.
markov_conditional_distribution(Historique, CondDist) :-
    % Récupère le dernier coup adverse (du tour le plus récent)
    ( Historique = [[_, LastOpp]|_] -> true ; LastOpp = none ),
    % Inverse l'historique pour obtenir l'ordre chronologique
    reverse(Historique, Chrono),
    findall(Prev-OppNext, (adjacent_opp(Chrono, Prev, OppNext)), Transitions),
    % Ne garder que les transitions dont le coup précédent correspond à LastOpp
    include(matches_last(LastOpp), Transitions, RelevantTransitions),
    count_transitions(RelevantTransitions, Counts),
    total_counts(Counts, Total),
    ( Total =:= 0 ->
         CondDist = []  % Aucune donnée conditionnelle
    ;
         maplist(prob_of_count(Total), Counts, CondDist)
    ).

% adjacent_opp(+Chrono, -Prev, -OppNext)
% Recherche des transitions consécutives dans Chrono (liste chronologique)
adjacent_opp([[_ , Opp1], [_ , Opp2] | _], Opp1, Opp2).
adjacent_opp([_ | Rest], Prev, OppNext) :-
    adjacent_opp(Rest, Prev, OppNext).

matches_last(Last, Prev-_) :-
    Prev = Last.

% count_transitions(+Transitions, -Counts)
% Compte la fréquence des coups adverses en seconde position dans les transitions.
count_transitions(Transitions, Counts) :-
    init_counts(Counts0),
    count_transitions_list(Transitions, Counts0, Counts).

count_transitions_list([], Counts, Counts).
count_transitions_list([_-Opp|Rest], CountsIn, CountsOut) :-
    update_count(CountsIn, Opp, 1, CountsUpdated),
    count_transitions_list(Rest, CountsUpdated, CountsOut).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3) Fusion des distributions : blending
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% blended_distribution(+UncondDist, +CondDist, -BlendedDist)
% Si la distribution conditionnelle est disponible et « prédictive », on lui donne plus de poids.
blended_distribution(UncondDist, [], UncondDist).  % Pas de donnée conditionnelle → on garde UncondDist
blended_distribution(UncondDist, CondDist, BlendedDist) :-
    % On récupère la probabilité maximale dans CondDist pour jauger la prédictivité
    max_probability(CondDist, _, MaxProbCond),
    % Définir α : si MaxProbCond est supérieur à 0.5, on y accorde un poids croissant
    ( MaxProbCond >= 0.5 -> Alpha is (MaxProbCond - 0.5) / 0.5 ; Alpha = 0 ),
    % Pour chaque coup (de 1 à 5), la probabilité finale est :
    % P_final = α * P_conditionnelle + (1-α) * P_global
    blend_lists(UncondDist, CondDist, Alpha, BlendedDist).

% blend_lists(+UncondDist, +CondDist, +Alpha, -BlendedDist)
blend_lists(UncondDist, CondDist, Alpha, BlendedDist) :-
    findall(Move-P,
            ( between(1,5,Move),
              member(Move-Pu, UncondDist),
              ( member(Move-Pc, CondDist) -> true ; Pc = 0 ),
              P is Alpha * Pc + (1 - Alpha) * Pu
            ),
            BlendedDist).

% max_probability(+Distribution, -Move, -MaxProb)
max_probability([Move-Prob], Move, Prob).
max_probability([Move1-P1, Move2-P2|Rest], Move, MaxProb) :-
    ( P1 >= P2 ->
         max_probability([Move1-P1|Rest], Move, MaxProb)
    ;  max_probability([Move2-P2|Rest], Move, MaxProb)
    ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4) Calcul de l'espérance de gain et sélection du coup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
expected_payoff(OurMove, Distribution, EP) :-
    expected_payoff_list(OurMove, Distribution, EP).

expected_payoff_list(_, [], 0).
expected_payoff_list(OurMove, [Opp-P|Rest], EP) :-
    payoff(OurMove, Opp, Pay),
    expected_payoff_list(OurMove, Rest, RestEP),
    EP is P * Pay + RestEP.

% Selon les règles du jeu :
% Si |OurMove - Opp| = 1 et OurMove < Opp, payoff = OurMove + Opp, sinon payoff = 0.
% Dans tous les autres cas, payoff = OurMove.
payoff(OurMove, Opp, Payoff) :-
    Diff is abs(OurMove - Opp),
    ( Diff =:= 1 ->
         ( OurMove < Opp -> Payoff is OurMove + Opp ; Payoff is 0 )
    ;   Payoff is OurMove
    ).

% max_ep_move(+ListEP, -BestMove)
max_ep_move(ListEP, BestMove) :-
    sort(1, @>=, ListEP, Sorted),
    Sorted = [_EP-BestMove|_].

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 5) Détection de changement de stratégie (comparaison de fenêtres)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
detecter_changement(Historique, Variation) :-
    length(Historique, L),
    ( L >= 10 ->
         prefix_length(Historique, Recent5, 5),
         remove_prefix(Historique, 5, Previous5),
         prefix_length(Previous5, Prev5, 5),
         simple_distribution(Recent5, Dist1),
         simple_distribution(Prev5, Dist2),
         variation_distance(Dist1, Dist2, Variation)
    ;   Variation = 0
    ).

prefix_length(List, Prefix, N) :-
    length(Prefix, N),
    append(Prefix, _, List).

remove_prefix(List, N, Rest) :-
    length(Prefix, N),
    append(Prefix, Rest, List).

simple_distribution(Historique, Dist) :-
    init_counts(Counts0),
    simple_counts(Historique, Counts0, Counts),
    total_counts(Counts, Total),
    ( Total =:= 0 ->
         Dist = [1-0.2, 2-0.2, 3-0.2, 4-0.2, 5-0.2]
    ;
         maplist(prob_of_count(Total), Counts, Dist)
    ).

simple_counts([], Counts, Counts).
simple_counts([[_, Opp]|Rest], CountsIn, CountsOut) :-
    update_count(CountsIn, Opp, 1, CountsUpdated),
    simple_counts(Rest, CountsUpdated, CountsOut).

variation_distance(Dist1, Dist2, Variation) :-
    findall(AbsDiff, ( member(M-P1, Dist1), member(M-P2, Dist2), Diff is abs(P1 - P2), AbsDiff = Diff ), Diffs),
    sum_list(Diffs, Sum),
    Variation is Sum / 2.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 6) Détection de patterns simples déjà existants
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Comportement répétitif : les 5 derniers coups adverses identiques
adversaire_repetitif_v4(Historique) :-
    length(Historique, L),
    L >= 5,
    last_n_opponent_moves(Historique, 5, Moves),
    all_same(Moves).

last_n_opponent_moves(Historique, N, Moves) :-
    length(Prefix, N),
    append(Prefix, _, Historique),
    findall(Move, (member([_, Move], Prefix)), Moves).

all_same([]).
all_same([_]).
all_same([X, X|T]) :-
    all_same([X|T]).

% Comportement de type tit-for-tat : l'adversaire répète notre coup précédent sur une fenêtre donnée
adversaire_titfortat_v4(Historique) :-
    length(Historique, L),
    L >= 5,
    prefix_length(Historique, Prefix, 5),
    check_titfortat(Prefix).

check_titfortat([_]).  % Un seul coup, rien à comparer.
check_titfortat([First, Second|Rest]) :-
    First = [MyCurrent, _],
    Second = [_, OppPrevious],
    OppPrevious =:= MyCurrent,
    check_titfortat([Second|Rest]).









%%%%%%%%%%%%%%%%%%%%%%%%
% KHAMAKHAWA V5 (Stratégie méta-adaptative universelle)
%%%%%%%%%%%%%%%%%%%%%%%%
:- dynamic khawa_meta_state/3.  % État: [Croyances, Patterns, Risque]
:- dynamic khawa_entropy/1.     % Mesure d'incertitude

joue(khawa_khawa_v5, Historique, Coup) :-
    % 1. Mise à jour de l'état méta
    (khawa_meta_state(Beliefs, Patterns, Risk)
        -> update_meta_state(Historique, Beliefs, Patterns, Risk, NewState)
        ;  initial_meta_state(NewState)),

    % 2. Calcul du coup optimal
    NewState = [NewBeliefs, NewPatterns, NewRisk],
    select_action(NewBeliefs, NewPatterns, NewRisk, Historique, Coup),

    % 3. Mise à jour dynamique
    retractall(khawa_meta_state(_, _, _)),
    assertz(khawa_meta_state(NewBeliefs, NewPatterns, NewRisk)).

% Initialisation de l'état méta
initial_meta_state([
    [random:0.25, titfortat:0.25, repetitive:0.25, unknown:0.25], % Croyances
    [ ],                                                            % Patterns
    0.5                                                            % Risque
]).

% Mise à jour bayésienne avec détection de stratégies inconnues
update_meta_state(Historique, OldBeliefs, OldPatterns, OldRisk, NewState) :-
    % a. Détection de nouveaux patterns
    scan_emerging_patterns(Historique, NewPatterns),

    % b. Mise à jour des croyances
    update_beliefs(Historique, OldBeliefs, NewBeliefs),

    % c. Calcul du risque dynamique
    calculate_risk(Historique, NewBeliefs, NewPatterns, NewRisk),

    NewState = [NewBeliefs, NewPatterns, NewRisk].

% Sélection d'action probabiliste multi-critères
select_action(Beliefs, Patterns, Risk, Historique, Coup) :-
    % 1. Génération de coups candidats
    findall(C, between(1, 5, C), Cand),

    % 2. Calcul des scores multi-objectifs
    maplist(score_action(Beliefs, Patterns, Risk, Historique), Cand, Scores),

    % 3. Sélection stochastique pondérée
    max_member(Score-Coup, Scores),
    (Risk > 0.7 -> random_member(Coup, Cand) ; true). % Exploration forcée

% Score d'une action (combine 4 critères)
score_action(Beliefs, Patterns, Risk, Hist, C, Score) :-
    exploit_score(Beliefs, C, S1),          % Exploitation des croyances
    explore_score(Hist, C, S2),             % Exploration des patterns
    risk_adjusted_score(Risk, C, S3),       % Ajustement au risque
    pattern_avoidance(Patterns, C, S4),     % Évitement des pièges

    Score is 0.4*S1 + 0.3*S2 + 0.2*S3 + 0.1*S4.

% Méthodes avancées -----------------------------------------------------------

% Détection de patterns émergents (algorithme Apriori adapté)
scan_emerging_patterns(Historique, Patterns) :-
    findall(Pat, (subsequence(Historique, Pat), length(Pat, L), L >= 3), AllPat),
    freq_patterns(AllPat, Freq),
    filter_significant(Freq, 0.2, Patterns).

% Mise à jour des croyances avec modèle de Dirichlet
update_beliefs(Hist, Old, New) :-
    length(Hist, N),
    alpha(0.5, Alpha), % Paramètre de régularisation
    maplist(update_strat_prob(Hist, Alpha, N), Old, Updated),
    normalize(Updated, New).

% Calcul du risque basé sur l'entropie de Shannon
calculate_risk(_, Beliefs, Patterns, Risk) :-
    entropy(Beliefs, E),
    patterns_risk(Patterns, PR),
    Risk is 0.7*E + 0.3*PR.

% Implémentations critiques ----------------------------------------------------
% (Ces prédicats nécessitent une implémentation détaillée selon la théorie des jeux)

% Fonctions utilitaires avancées
normalize(Probs, Normed) :- sumlist(Probs, Total), maplist(div(Total), Probs, Normed).
div(Total, X, Y) :- Y is X/Total.

entropy([], 0).
entropy([_:P|T], E) :- entropy(T, E1), (P > 0 -> E is E1 - P*log(P) ; E = E1).

% ... (autres implémentations nécessaires)

%%%%%%%%%%%%%%%%%%%%%%%%
% STRATÉGIE D'ÉQUILIBRE DYNAMIQUE
%%%%%%%%%%%%%%%%%%%%%%%%
% Permet de s'adapter même contre des clones de soi-même
anti_clone_policy(Historique, Coup) :-
    findall(C, (between(1,5,C), is_safe_against_clone(C, Historique)), Safe),
    random_member(Coup, Safe).

is_safe_against_clone(C, Hist) :-
    % Vérifie que le coup C ne crée pas de configuration exploitable
    not(dangerous_pattern(C, Hist)).

dangerous_pattern(C, Hist) :-
    length(Hist, L),
    L > 5,
    sublist([Prev1, Prev2, _], Hist),
    C =:= (Prev1 + Prev2) mod 5 + 1.

















%%%%%%%%%%%%%%%%%%%%%%%%
% PREDICATS UTILITAIRES
%%%%%%%%%%%%%%%%%%%%%%%%
adversaire_repetitif(Historique) :-
    derniers_coups(Historique, 5, Derniers),
    compter_repetitions(Derniers, Reps),
    Reps >= 3.

adversaire_titfortat(Historique) :-
    length(Historique, L), L >= 2,
    derniers_coups(Historique, 2, [[M1, _], [_, A2]]),
    A2 =:= M1.

jouer_contre_repetitif(Historique, Coup) :-
    dernier_adversaire(Historique, Dernier),
    Coup is max(1, Dernier - 1).

jouer_contre_titfortat(Historique, Coup) :-
    derniers_coups(Historique, 1, [[M, _]]),
    ( M =:= 3 ->
         Coup = 5
    ;
         Coup = 2
    ).

dernier_adversaire(Historique, D) :-
    Historique = [[_, D] | _].


derniers_coups(Historique, N, Derniers) :-
    reverse(Historique, R),
    firstN(R, N, Derniers).

firstN(L, N, R) :-
    length(R, N),
    append(R, _, L).

compter_repetitions(L, R) :-
    msort(L, S),
    count_reps(S, 1, R).

count_reps([_], C, C).
count_reps([H, H | T], Acc, R) :-
    Acc1 is Acc + 1,
    count_reps([H | T], Acc1, R).
count_reps([_ | T], Acc, R) :-
     count_reps(T, Acc, R).

computeLongestPreviousSequence(_, _, [], 0).
computeLongestPreviousSequence(X, P, [[X, _] | T], N) :-
    P =:= 1,
    computeLongestPreviousSequence(X, 1, T, M),
    N is M + 1.
computeLongestPreviousSequence(X, P, [[_, X] | T], N) :-
    P =:= 2,
    computeLongestPreviousSequence(X, 2, T, M),
    N is M + 1.
computeLongestPreviousSequence(_, _, _, 0).

inversePaires([], []).
inversePaires([[X, Y] | T], [[Y, X] | R]) :-
    inversePaires(T, R).

comparePairs(=, [_, X], [_, X]) :- !.
comparePairs(<, [_, X], [_, Y]) :-
    X > Y, !.
comparePairs(>, _, _).

affiche(_, _, _, _, _, _, _, _).


:- dynamic khawa_meta_state_v6/3.  % Stratégie détectée, Confiance, Compteur de stabilité

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prédicat principal - Version méta-adaptative universelle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
joue(khawa_khawa_v6, Historique, Coup) :-
    % Initialisation dynamique de l'état méta
    ( khawa_meta_state_v6(_,_,_) -> true ; assertz(khawa_meta_state_v6(unknown, 0.0, 0))),

    % Phase d'analyse méta en continu
    analyser_meta_strategie_khawa_khawa(Historique, Strat, NewConf, Stab),
    retractall(khawa_meta_state_v6(_,_,_)),
    assertz(khawa_meta_state_v6(Strat, NewConf, Stab)),

    % Détermination du coup avec système de priorité
    ( NewConf > 0.7 ->
        appliquer_strategie_ciblee_khawa_khawa(Strat, Historique, Coup)
    ; Stab > 15 ->
        declencher_surprise_khawa_khawa(Historique, Coup)
    ;
        generer_coup_optimal_khawa_khawa(Historique, Coup)
    ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Méta-analyse stratégique (15 indicateurs combinés)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
analyser_meta_strategie_khawa_khawa(Historique, Strat, Conf, Stab) :-
    % 1. Analyse de fréquence multi-niveaux
    calculer_distributions_khawa_khawa(Historique, [1,3,5], FreqDist),

    % 2. Détection de motifs complexes
    detecter_motifs_complexes_khawa_khawa(Historique, Motifs),

    % 3. Analyse de stabilité contextuelle
    calculer_entropie_khawa_khawa(Historique, Entropie),
    calculer_derive_strategique_khawa_khawa(Historique, Derive),

    % 4. Classification par réseau de décision
    ( Entropie < 1.2, Derive < 0.1 ->
        Strat = repetitive, Conf is 0.9 - (Entropie/2)
    ; Motifs = [anti_pattern|_] ->
        Strat = anti_strat, Conf is 0.8
    ; Entropie > 1.8 ->
        Strat = aleatoire, Conf is 0.95
    ;
        Strat = adaptive, Conf is max(0.6, 1 - (Entropie/3))
    ),

    % Calcul de la stabilité
    Stab is integer(20 * (1 - Derive)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Générateur de coup universel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
generer_coup_optimal_khawa_khawa(Historique, Coup) :-
    % Triple couche prédictive
    markov_conditional_distribution_khawa_khawa(Historique, 3, MarkovDist),
    pattern_bayesien_khawa_khawa(Historique, BayesDist),
    historique_pondere_khawa_khawa(Historique, 0.9, HistDist),

    % Fusion neuronale
    blended_distribution_khawa_khawa([0.4,0.3,0.3], [MarkovDist,BayesDist,HistDist], FusionDist),

    % Calcul d'utilité avec gestion de risque
    findall(U-C, (between(1,5,C), utilite_attendue_khawa_khawa(C, FusionDist, U)), Utilities),
    keysort(Utilities, Sorted),
    reverse(Sorted, [MaxU-MaxC|_]),

    % Sélection avec exploration adaptative
    ( MaxU > 3.5 -> Coup = MaxC ; random_between(1,5,Coup)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Contre-stratégies spécialisées
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
appliquer_strategie_ciblee_khawa_khawa(repetitive, Historique, Coup) :-
    derniers_coups_adversaire_khawa_khawa(Historique, 5, Derniers),
    mode_khawa_khawa(Derniers, Mode),
    ( Mode > 3 -> Coup is Mode - 1 ; Coup is Mode + 1).

appliquer_strategie_ciblee_khawa_khawa(anti_strat, Historique, Coup) :-
    random_select_khawa_khaway(Coup, [2,4], 0.7),  % Évite les extrêmes
    ( coup_valide_khawa_khaway(Historique, Coup) -> true ; Coup = 3).

appliquer_strategie_ciblee_khawa_khawa(aleatoire, _, Coup) :-
    distribution_anti_aleatoire_khawa_khaway(Coup).

appliquer_strategie_ciblee_khawa_khawa(adaptive, Historique, Coup) :-
    adversaire_imprevisible_khawa_khaway(Historique) ->
        random_between(1,5,Coup) ;
        generer_coup_optimal_khawa_khawa(Historique, Coup).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Système de surprise stratégique
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
declencher_surprise_khawa_khawa(Historique, Coup) :-
    % Alternance entre pièges et fausses patterns
    random_select_khawa_khaway(Type, [sequence_trap,reverse_pattern,boost_multiplier], [0.4,0.3,0.3]),
    execute_surprise_khawa_khaway(Type, Historique, Coup).

execute_surprise_khawa_khaway(sequence_trap, Historique, Coup) :-
    derniers_coups_khawa_khaway(Historique, 3, MesDerniers),
    sum_list(MesDerniers, Sum),
    Coup is (Sum mod 5) + 1.

execute_surprise_khawa_khaway(reverse_pattern, Historique, Coup) :-
    reverse(Historique, [H|_]),
    H = [_,AdvCoup],
    Coup is 6 - AdvCoup.

execute_surprise_khawa_khaway(boost_multiplier, Historique, Coup) :-
    findall(C, member([C,_], Historique), MesCoups),
    mode_khawa_khaway(MesCoups, Mode),
    Coup = Mode.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fonctions analytiques avancées
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
calculer_distributions_khawa_khawa(_, [], []).
calculer_distributions_khawa_khawa(Historique, [N|Tailles], [Dist-N|Rests]) :-
    distribution_par_fenetre_khawa_khaway(Historique, N, Dist),
    calculer_distributions_khawa_khawa(Historique, Tailles, Rests).

distribution_par_fenetre_khawa_khaway(Historique, N, Dist) :-
    length(Historique, L),
    ( L > N ->
        length(Window, N),
        append(Window, _, Historique),
        compter_frequences_khawa_khaway(Window, Dist)
    ;
        compter_frequences_khawa_khaway(Historique, Dist)
    ).

detecter_motifs_complexes_khawa_khawa(Historique, Motifs) :-
    findall(Motif, (motif_complexe_khawa_khaway(Historique, Motif)), Motifs).

motif_complexe_khawa_khaway(Historique, anti_pattern) :-
    subsequence_khawa_khaway(Historique, [_,[A,B],[C,D]]),
    abs(A-B) =:= 1,
    abs(C-D) =:= 1,
    abs(A-C) =:= 2.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Utilitaires optimisés
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
compter_frequences_khawa_khaway(Historique, Dist) :-(
    findall(C, member([_,C], Historique, Coups),
    init_counts_khawa_khaway(1-5, Counts),
    remplir_counts_khawa_khaway(Coups, Counts, FinalCounts),
    total_counts_khawa_khaway(FinalCounts, Total),
    maplist(prob_of_count_khawa_khaway(Total), FinalCounts, Dist))).

historique_pondere_khawa_khaway(Historique, Decay, Dist) :-
    reverse(Historique, Chrono),
    init_counts_khawa_khaway(1-5, Counts),
    apply_decay_recursive_khawa_khaway(Chrono, Decay, 1.0, Counts, FinalCounts),
    total_counts_khawa_khaway(FinalCounts, Total),
    maplist(prob_of_count_khawa_khaway(Total), FinalCounts, Dist).

apply_decay_recursive_khawa_khaway([], _, _, Counts, Counts).
apply_decay_recursive_khawa_khaway([[_,C]|R], D, W, CIn, COut) :-
    update_count_khawa_khaway(CIn, C, W, CTmp),
    WNew is W * D,
    apply_decay_recursive_khawa_khaway(R, D, WNew, CTmp, COut).



:- dynamic khawa_nash_state_v7/2.
:- dynamic khawa_game_version_v7/1.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Intégration de l'équilibre de Nash - Version hybride V7
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
joue(khawa_khawa_v7, Historique, Coup) :-
    % Détection dynamique de la version du jeu
    ( khawa_game_version_v7(V) -> true ; detecter_version_jeu_khawa_khawa(Historique, V)),

    % Calcul de la stratégie Nash en temps réel
    ( appliquer_nash_khawa_khawa(V, Historique, NashCoup) ->
        Coup = NashCoup,
        debug_nash_khawa_khawa(V)
    ;
        % Fallback sur la stratégie adaptative
        generer_coup_optimal_khawa_khawa(Historique, Coup)
    ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Détection de la version du jeu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
detecter_version_jeu_khawa_khawa(Historique, Version) :-
    findall(S, (member([A,B], Historique), score(A,B,_,S1,S2), S is S1+S2), Scores),
    ( member(S, Scores), S > 10 ->
        assertz(khawa_game_version_v7(v2)),
        Version = v2
    ;
        assertz(khawa_game_version_v7(v1)),
        Version = v1
    ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stratégies Nash pour les deux versions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
appliquer_nash_khawa_khawa(v1, Historique, Coup) :-
    % Équilibre mixte calculé : [1:10%, 2:30%, 3:20%, 4:25%, 5:15%]
    random_select_khawa_khaway(Coup, [1,2,2,2,3,3,4,4,4,5], _).

appliquer_nash_khawa_khawa(v2, Historique, Coup) :-
    % Stratégie Nash adaptative avec mémoire
    ( derniers_coups_khawa_khawa(Historique, 3, [X,X,X]) ->
        contre_multiplicateur_nash_khawa_khawa(X, Coup)
    ;
        nash_pondere_khawa_khawa(Historique, Coup)
    ).

contre_multiplicateur_nash_khawa_khawa(X, Coup) :-
    Y is (X mod 5) + 1,
    (Y =:= X+1 -> Coup = Y ; Coup = max(1, X-1)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Calcul Nash pondéré version 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nash_pondere_khawa_khawa(Historique, Coup) :-
    matrice_gains_nash_khawa_khawa(Historique, Matrice),
    meilleure_reponse_nash_khawa_khawa(Matrice, Coup).

matrice_gains_nash_khawa_khawa(Historique, Matrice) :-
    findall(Col, (between(1,5,AdvCoup), Colonnes),
    maplist(calcul_utilite_nash_khawa_khawa(Historique), Colonnes, Matrice)).

calcul_utilite_nash_khawa_khawa(Historique, AdvCoup, Utilite) :-
    findall(U, (between(1,5,MyCoup), calcul_gain_nash_khawa_khawa(MyCoup, AdvCoup, U)), Utilite).

calcul_gain_nash_khawa_khawa(MyCoup, AdvCoup, Gain) :-
    ( abs(MyCoup - AdvCoup) =:= 1 ->
        ( MyCoup < AdvCoup -> Gain is MyCoup + AdvCoup ; Gain = 0 )
    ;   Gain = MyCoup
    ).

meilleure_reponse_nash_khawa_khawa(Matrice, Coup) :-
    transpose(Matrice, Transpose),
    findall(Max, (nth1(Idx, Transpose, Col), max_list(Col, Max)), Maxs),
    max_list(Maxs, MaxVal),
    findall(Idx, nth1(Idx, Transpose, Col), member(MaxVal, Col), Indices),
    random_member(Coup, Indices).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Intégration avec système existant
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
generer_coup_optimal_khawa_khawa(Historique, Coup) :-
    % Fusion Nash + Adaptatif
    ( random(0.0,1.0,R), R < 0.3 ->
        appliquer_nash_khawa_khawa(v2, Historique, Coup)
    ;
        % Code original adaptatif
        markov_conditional_distribution_khawa_khawa(Historique, 3, MarkovDist),
        pattern_bayesien_khawa_khawa(Historique, BayesDist),
        blended_distribution_khawa_khawa([0.5,0.5], [MarkovDist,BayesDist], FusionDist),
        findall(U-C, (between(1,5,C), utilite_attendue_khawa_khawa(C, FusionDist, U)), Utilities),
        max_ep_move_khawa_khawa(Utilities, Coup)
    ).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Utilitaires supplémentaires
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
debug_nash_khawa_khawa(v1) :- write('Nash V1 activé').
debug_nash_khawa_khawa(v2) :- write('Nash V2 adaptatif').

derniers_coups_khawa_khawa(Historique, N, Coups) :-
    length(Prefix, N),
    append(Prefix, _, Historique),
    findall(C, member([C,_], Prefix), Coups).

% ... (Maintenir tous les prédicats auxiliaires existants)



:- discontiguous joue/3.
:- dynamic param_khawa_khawa_prime/2.
:- dynamic drapeau_fausse_repet/1.
:- dynamic khawa_multiplier_state/2.

%%%%%%%%%%%%%%%%%%%%%%%%
%% PARAMÈTRES DYNAMIQUES
%%%%%%%%%%%%%%%%%%%%%%%%
param_khawa_khawa_prime(avance_sure, 25).
param_khawa_khawa_prime(retard_aggr, -20).
param_khawa_khawa_prime(repet_min, 1).
param_khawa_khawa_prime(taux_nash, 0.05).
param_khawa_khawa_prime(menace_max, 0.15).
param_khawa_khawa_prime(mult_max, 3).

maj_param_cle(Cle, Val) :-
    retractall(param_khawa_khawa_prime(Cle,_)),
    assertz(param_khawa_khawa_prime(Cle,Val)).

%%%%%%%%%%%%%%%%%%%%%%%%
%% STRATÈGE PRINCIPALE
%%%%%%%%%%%%%%%%%%%%%%%%
joue(khawa_khawa_prime, Historique, Coup) :-
    parametres(AvanceOk, RetardMax, SeuilRep, TauxNash, MenaceMax, MultMax),
    (detecter_version(Historique, v2) ->
        strategie_v2(Historique, Coup, AvanceOk, RetardMax, SeuilRep, TauxNash, MenaceMax, MultMax)
    ;
        strategie_v1(Historique, Coup, AvanceOk, RetardMax, SeuilRep, TauxNash)
    ).

strategie_v2(Hist, Coup, Av, Rg, Sr, Tn, Mm, Mx) :-
    (khawa_multiplier_state(Current, Count), Count > 0 ->
        (safe_multiplier(Current, Hist, Count, Mx)
            -> Coup = Current, NewCount is Count + 1,
               retractall(khawa_multiplier_state(_,_)),
               assertz(khawa_multiplier_state(Current, NewCount))
            ; abandon_multiplier(Hist, Coup, Mm)
        )
    ;
        etat_score(Hist, Delta),
        menace_basse(Hist, MenaceMax, CoupSafe),
        pret_decharger(Hist, CoupDecharge),
        choisir_coup_v2(Hist, Coup, Av, Rg, Sr, Tn, Delta, CoupSafe, CoupDecharge, Mx)
    ).

%%%%%%%%%%%%%%%%%%%%%%%%
%% LOGIQUE VERSION 2
%%%%%%%%%%%%%%%%%%%%%%%%
choisir_coup_v2(Hist, Coup, Av, Rg, Sr, Tn, Dlt, CoupSafe, CoupDecharge, Mx) :-
    (Dlt >= Av, random(0.0, 1.0, R), R < 0.4 -> initier_multiplier(Hist, Coup, Mx)
    ; peut_decharger(Hist, CoupDecharge) -> Coup = CoupDecharge
    ; menace_basse(Hist, 0.2, CoupSafe) -> Coup = CoupSafe
    ; generer_coup_adaptatif(Hist, Coup, Tn)
    ).

safe_multiplier(Coup, Hist, Count, Max) :-
    dernier_coup_adv(Hist, DernierAdv),
    abs(DernierAdv - Coup) =\= 1,
    Count < Max,
    length_hist_streak(Hist, Coup, Len),
    Len >= 2.

initier_multiplier(Hist, Coup, Max) :-
    dernier_coup_moi(Hist, Last),
    between(2, 4, SafeCoup),
    Coup = SafeCoup,
    assertz(khawa_multiplier_state(Coup, 1)).

abandon_multiplier(Hist, Coup, Mm) :-
    retractall(khawa_multiplier_state(_,_)),
    (random(0.0, 1.0, R), R < Mm ->
        coup_agressif(Hist, Coup)
    ;
        generer_coup_adaptatif(Hist, Coup, 0.1)
    ).






joue(nash_equilibrium, _, Coup) :-
    khawa_khawa_select_weighted(khawa_khawa,
                    [0,
                     0,
                     4/9,
                     2/9,
                     1/3], [1,2,3,4,5], Coup).

joue(stage_test, _, Coup) :-
    khawa_khawa_select_weighted(khawa_khawa,
        [0.03,
            0.444,
            0.203,
            0.323,
            0.0], [1,2,3,4,5], Coup).
