# breif explanations of functions:
* ## PoolGenbycircshift
Generate the cyclic pool for sequences of problem sets, with the dimension of Mp by M, and often denoted as PSetsPool;
* ## TBinGen
Calculate the inherent gain matrix which is an element-wise product of the colluding matrix P and the competence difference matrix D, whose values depend only on the competences of the students;
* TBposFullCal
Calculate the positional matrix of the pool;
* TBposInitFunc
Calculate the positional matrix of the assignment (PSTA, problem sets assignment) from the positional matrix of the pool;
* GenSchemeV2
Generate the assignments with GAS, with the dimension of 1 by N, and often denoted as PSTA0, with each element represents the index of a sequence from PSetsPool, i.e., number j in PSTA means the sequence PSetsPool(j,:);
* PosOptimizationFullV2
One-iteration optimization of assignments with CGS;
* WorstLossCal
Calculate the gW (the worst case average collusion gain) and the gMI (the maximum individual collusion gain).

