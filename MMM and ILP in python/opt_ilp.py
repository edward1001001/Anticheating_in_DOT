import sys
import time
import pulp
import pickle
import numpy as np

import config
from scoring_helper import *


def opt_ilp(I):
    """
    Input:
        I: (n, m, q, y, P) instance
    Output:
        A: nxm matrix of assignments, A[i,j] is the question number of j on i's exam
    """
    (n, m, q, y, P) = I
    # print('defining problem')

    """
    ILP variables
    """
    # add variables for the assignment
    x = pulp.LpVariable.dicts('x', [(i,j) for i in range(n) for j in range(m)], lowBound=0, upBound=1, cat='Integer')
    ### x[(i,j)]=1 iff i is assigned question j
    z = pulp.LpVariable.dicts('z', [(i,j) for i in range(n) for j in range(m)], lowBound=0, upBound=q, cat='Integer')
    ### z[(i,j)]=question # of j in i's exam
    e = pulp.LpVariable.dicts('e', [(i,j,l) for i in range(n) for j in range(m) for l in range(1,q+1)],
                              lowBound=0, upBound=1, cat='Integer')
    ### e[(i,j,l)]=1 if z[(i,j)]>=l; l from 1...q
    f = pulp.LpVariable.dicts('f', [(i,j,l) for i in range(n) for j in range(m) for l in range(1,q+1)],
                              lowBound=0, upBound=1, cat='Integer')
    ### f[(i,j,l)]=1 if z[(i,j)]<=l; l from 1...q
    g = pulp.LpVariable.dicts('g', [(i,j,l) for i in range(n) for j in range(m) for l in range(1,q+1)],
                              lowBound=0, upBound=1, cat='Integer')
    ### g[(i,j,l)]=1 if z[(i,j)]==l; l from 1...q

    # add variables to track who can copy from whom
    c = pulp.LpVariable.dicts('c', [(i,k,j) for i in range(n) for k in range(i+1) for j in range(m)],
                              lowBound=0, upBound=1, cat='Integer')
    ### c[(i,k,j)]=1 if agent i can copy question j from agent k
    ### i can copy j from k if both are assigned j and k has seen j
    u = pulp.LpVariable.dicts('u', [(i,k,j) for i in range(n) for k in range(i) for j in range(m)],
                              lowBound=0, upBound=1, cat='Integer')
    ### u[(i,k,j)]=1 if both agents i and k were assigned question j
    v = pulp.LpVariable.dicts('v', [(i,k,j) for i in range(n) for k in range(i) for j in range(m)],
                              lowBound=0, upBound=1, cat='Integer')
    ### v[(i,k,j)]=1 if y[(k,j)]<=z[(i,j)]

    # add variables for the assignment
    s = pulp.LpVariable.dicts('s', [(i,j) for i in range(n) for j in range(m)], lowBound=0, upBound=1, cat='Continuous')
    ### s[(i,j)] i's expected score on question j
    # print('added variables')

    """
    ILP definition and objective
    """
    # define the problem
    model = pulp.LpProblem('OptimalAssignment', pulp.LpMinimize)
    # set objective
    model += pulp.lpSum([s[(i,j)] for i in range(n) for j in range(m)])
    # print('added objective')

    """
    ILP constraints
    """
    # add constraints on the assignment
    for i in range(n):
        model += pulp.lpSum([z[(i,j)] for j in range(m)]) == np.sum(list(range(q+1)))
        for j in range(m):
            model += x[(i,j)] >= z[(i,j)]*(1/m)
            model += x[(i,j)] <= z[(i,j)]
        for l in range(1,q+1):
            for j in range(m):
                model += e[(i,j,l)] >= (1 + z[(i,j)] - l)*(1/(m+1))
                model += e[(i,j,l)] <= (m + z[(i,j)] - l)*(1/m)
                model += f[(i,j,l)] >= (1 + l - z[(i,j)])*(1/(m+1))
                model += f[(i,j,l)] <= (m + l - z[(i,j)])*(1/m)
                model += g[(i,j,l)] <= e[(i,j,l)]
                model += g[(i,j,l)] <= f[(i,j,l)]
                model += g[(i,j,l)] >= e[(i,j,l)] + f[(i,j,l)] - 1
            model += pulp.lpSum([g[(i,j,l)] for j in range(m)]) == 1
        model += pulp.lpSum([g[(i,j,l)] for j in range(m) for l in range(1,q+1)]) == q
    # print('added feasibility constraints')

    # add constraints for copying
    for i in range(n):
        for k in range(i):
            for j in range(m):
                model += u[(i,k,j)] <= x[(i,j)]
                model += u[(i,k,j)] <= x[(k,j)]
                model += u[(i,k,j)] >= x[(i,j)] + x[(k,j)] - 1
                model += v[(i,k,j)] >= (1 + z[(i,j)] - z[(k,j)])*(1/(m+1))
                model += v[(i,k,j)] <= (m + z[(i,j)] - z[(k,j)])*(1/m)
                model += c[(i,k,j)] <= u[(i,k,j)]
                model += c[(i,k,j)] <= v[(i,k,j)]
                model += c[(i,k,j)] >= u[(i,k,j)] + v[(i,k,j)] - 1
        for j in range(m):
            model += c[(i,i,j)] == 1
    # print('added copying constraints')

    # add constraints for scoring
    for i in range(n):
        for j in range(m):
            model += s[(i,j)] == pulp.lpSum([P[i,k]*y[k]*c[(i,k,j)] for k in range(i+1)]) + \
                                y[i]*(1 - pulp.lpSum([P[i,k]*c[(i,k,j)] for k in range(i+1)]))
    # print('added scoring constraints')

    """
    Solve
    """
    solver = pulp.GUROBI(msg=0)
    model.solve(solver)

    status = model.status
    # print('pulp', status)
    status = (pulp.LpStatusOptimal == model.status)
    A = np.zeros((n,m))

    for i in range(n):
        for j in range(m):
            A[i,j] = pulp.value(z[(i, j)])

    return status, A


def experiment_ilp(instances):
    num_instances = len(instances)
    ilp_status_all = list()
    ilp_assignments_all = list()
    ilp_score_all = list()
    ilp_runtimes_all = list()
    for i in range(num_instances):
        I = instances[i]
        (n, m, q, y, P) = I
        start_time = time.time()
        status, A = opt_ilp(I)
        end_time = time.time()
        if not status:
            print(f'ILP failed instance {i}')
            sys.exit()
        scores, S = compute_scores(I, A)
        score = np.sum(scores)
        ilp_status_all.append(status)
        ilp_assignments_all.append(A)
        ilp_score_all.append(score)
        ilp_runtimes_all.append(end_time - start_time)
        print(f'instance {i}, status {status}, score {score}, runtime {end_time-start_time}')
    return ilp_status_all, ilp_assignments_all, ilp_score_all, ilp_runtimes_all


def run_ilp(instances, loc=config.loc):
    ilp_status_all, ilp_assignments_all, ilp_score_all, ilp_runtimes_all = experiment_ilp(instances)
    with open(f'{loc}/ilp_status', 'wb') as fo:
        pickle.dump(ilp_status_all, fo)
    with open(f'{loc}/ilp_score', 'wb') as fo:
        pickle.dump(ilp_score_all, fo)
    with open(f'{loc}/ilp_runtimes', 'wb') as fo:
        pickle.dump(ilp_runtimes_all, fo)
    with open(f'{loc}/ilp_assignments', 'wb') as fo:
        pickle.dump(ilp_assignments_all, fo)
