import copy
import time
import pickle
import numpy as np
from collections import deque

import config
import instance_helper
import scoring_helper


def generate_cyclical_test_bank(n, m, q):
    assert(q <= m)
    B = list()
    t = deque(list(range(m)))
    for i in range(n):
        b = [t[j] for j in range(q)]
        t.rotate(1)
        assert(len(set(b)) == q)
        b = instance_helper.test_to_assignment(b, m)
        B.append(b)
    B = np.array(B)
    return B


def cyclical_assignment(n, B):
    """
    Input:
        n: # agents
        B: question bank
    Output:
        A: nxm-matrix of assignments
    """
    nbank = np.shape(B)[0]
    A = np.array([B[i%nbank,:] for i in range(n)])
    return A


def alg_cyclic(I):
    """
    Input:
        I: (n, m, q, y, P) instance
    Output:
        Agreedy: nxm assignment matrix
        Ainit: nxm assignment matrix
    """
    (n, m, q, y, P) = I
    B = generate_cyclical_test_bank(n, m, q)
    Ainit = cyclical_assignment(n, B)
    assert(np.shape(Ainit) == (n, m))
    Agreedy = copy.deepcopy(Ainit)
    for k in range(n):
        # k is the current agent we want to greedily improve
        spre, Spre = scoring_helper.compute_scores(I, Agreedy)
        spre = np.sum(spre)
        yk = y[k]
        snew = list()
        for l in range(np.shape(B)[0]):
            # l is the index of the new assignment being considered for k
            b = copy.deepcopy(B[l,:])
            siknew = list()
            for i in range(k+1, n):
                # i is an agent who may copy from k
                ai = Agreedy[i,:]
                yi = y[i]
                pik = P[i,k]
                sik = scoring_helper.score_copying_pair(ai, b, yi, yk)
                siknew.append(pik*sik)
                # sik is the score
            skinew = list()
            for i in range(k):
                # i is an agent from whom k may copy
                ai = Agreedy[i,:]
                yi = y[i]
                pki = P[k,i]
                ski = scoring_helper.score_copying_pair(b, ai, yk, yi)
                skinew.append(pki*ski)
            snew.append(np.sum(siknew)+np.sum(skinew))
        bestidx = snew.index(np.min(snew))
        bbest = B[bestidx,:]
        Agreedy[k,:] = bbest
        sgreedy, Sgreedy = scoring_helper.compute_scores(I, Agreedy)
        sgreedy = np.sum(sgreedy)
        assert(sgreedy <= spre)
    return Agreedy, Ainit


def experiment_cyclic(instances):
    num_instances = len(instances)
    honest_score_all = np.zeros(num_instances)
    initial_score_all = np.zeros(num_instances)
    greedy_score_all = np.zeros(num_instances)
    initial_assignments_all = list()
    greedy_assignments_all = list()
    greedy_runtime_all = list()
    for i in range(num_instances):
        I = instances[i]
        (n, m, q, y, P) = I
        shonest = np.sum([q*y[k] for k in range(n)])
        honest_score_all[i] = shonest
        start_time = time.time()
        Agreedy, Ainitial = alg_cyclic(I)
        end_time = time.time()
        sgreedy, Sgreedy = scoring_helper.compute_scores(I, Agreedy)
        sgreedy = np.sum(sgreedy)
        greedy_score_all[i] = sgreedy
        greedy_assignments_all.append(Agreedy)
        greedy_runtime_all.append(end_time - start_time)
        sinit, Sinit = scoring_helper.compute_scores(I, Ainitial)
        sinit = np.sum(sinit)
        initial_score_all[i] = sinit
        initial_assignments_all.append(Ainitial)
        print(f'instance {i}, honest {shonest}, initial {sinit}, greedy {sgreedy}, {end_time-start_time}s')
    return honest_score_all, initial_score_all, greedy_score_all, initial_assignments_all, greedy_assignments_all, greedy_runtime_all


def run_cyclic(instances, loc=config.loc):
    honest_score_all, initial_score_all, greedy_score_all, initial_assignments_all, greedy_assignments_all, greedy_runtime_all = experiment_cyclic(instances)
    with open(f'{loc}/honest', 'wb') as fo:
        pickle.dump(honest_score_all, fo)
    with open(f'{loc}/initial_cyclic_score', 'wb') as fo:
        pickle.dump(initial_score_all, fo)
    with open(f'{loc}/greedy_cyclic_score', 'wb') as fo:
        pickle.dump(greedy_score_all, fo)
    with open(f'{loc}/initial_cyclic_assignments', 'wb') as fo:
        pickle.dump(initial_assignments_all, fo)
    with open(f'{loc}/greedy_cyclic_assignments', 'wb') as fo:
        pickle.dump(greedy_assignments_all, fo)
    with open(f'{loc}/greedy_cyclic_runtimes', 'wb') as fo:
        pickle.dump(greedy_runtime_all, fo)
