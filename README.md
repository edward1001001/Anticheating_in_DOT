# Optimization-based Anti-collusion Algorithms for Distanced Online Testing (DOT)
This repository contains the codes and simulation data for our anti-cheating algorithms described in the following papers:
### [Optimized Collusion Prevention for Online Exams during Social Distancing](). npj Science of Learning. (under review)
### [Anti-cheating Online Exams by Minimizing the Cheating Gain](https://doi.org/10.20944/preprints202005.0502.v1). Preprints, 2020.

## Prerequisites
The codes are developed in two platforms. 

The Grouping-based Anti-collusion Scheme (GAS) and Cyclic Greedy Searching (CGS) algorithms are developed in MATLAB R2018a. 

The Min-Max Greedy Matching (MMM) and Integer Linear Programming (ILP) algorithms are developed in Python v3.6, and the dependent packages include:
* networkx v2.5
* numpy v1.14.3
* scipy v1.1.0
* pulp v2.3.1
* matplotlib v2.2.2
* gurobi v9.0.3

Note: the ``gurobi`` package is only needed by ILP. The academic licence can be easily obtained through [their website](https://www.gurobi.com/free-trial/) if you are eligible. Or you can simply comment the ILP related codes, and rely on the CGS or MMM-CGS which will also generate comparable results at a much faster speed. 
