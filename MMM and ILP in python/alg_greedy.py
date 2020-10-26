import copy
import pickle
import time
import numpy as np
import networkx as nx

import config
import scoring_helper


def get_random_assignment(n, m, q):
    """
    Input:
        n: # agents
        m: # total questions
        q: # questions per agent
    Output:
        A: nxm-matrix, A[i,j] is the question number of question j on i's test
    """
    A = np.zeros((n, m))
    for i in range(n):
        a = np.random.choice(m, q, replace=False)
        for l in range(q):
            A[i, a[l]] = l+1
    return A


def alg_greedy(I, Ainitial=None):
    """
    Input:
        I: (n, m, q, y, P) instance
    Output:
        Agreedy: nxm assignment matrix
    """
    (n, m, q, y, P) = I
    if Ainitial is None:
        Ainitial = get_random_assignment(n, m, q)
    Agreedy = copy.deepcopy(Ainitial)
    for i in range(n):
        sgreedypre, S = scoring_helper.compute_scores(I, Agreedy)
        sgreedypre = np.sum(sgreedypre)
        B = nx.Graph()
        posnodes = [f'pos{i}' for i in range(1, q+1)]
        B.add_nodes_from(posnodes, bipartite=0)
        qnodes = [f'q{i}' for i in range(m)]
        B.add_nodes_from(qnodes, bipartite=1)
        for l in range(1, q+1):
            for j in range(m):
                # question j is in position l
                w = list()
                for k in range(i+1):
                    # case: i copying from k
                    ikcopycurrent = int(Agreedy[i, j] >= 1) * int(Agreedy[k, j] >= 1) * int(Agreedy[k, j] <= Agreedy[i, j])
                    current = P[i, k] * (ikcopycurrent*y[k] + (1 - ikcopycurrent)*y[i])
                    ikcopypair = int(Agreedy[k, j] >= 1) * int(Agreedy[k, j] <= l)
                    pair = P[i, k] * (ikcopypair*y[k] + (1 - ikcopypair)*y[i])
                    w.append(pair - current)
                for h in range(i+1, n):
                    # case: h copying from i
                    hicopycurrent = int(Agreedy[h, j] >= 1)*int(Agreedy[i, j] >= 1)*int(Agreedy[i, j] <= Agreedy[h, j])
                    current = P[h, i]*(hicopycurrent*y[i] + (1 - hicopycurrent)*y[h])
                    hicopypair = int(Agreedy[h, j] >= 1) * int(l <= Agreedy[h, j])
                    pair = P[h,i]*(hicopypair*y[i] + (1 - hicopypair)*y[h])
                    w.append(pair - current)
                w = np.sum(w)
                B.add_edge(f'pos{l}', f'q{j}', weight=w)
        M = nx.algorithms.bipartite.matching.minimum_weight_full_matching(B)
        a = np.zeros(m)
        for u in M.keys():
            v = M[u]
            [l, j] = sorted((u, v))
            l = int(l.lstrip('pos').rstrip()) # position
            j = int(j.lstrip('q').rstrip()) # question
            a[j] = l
        apre = copy.deepcopy(Agreedy[i, :])
        Agreedy[i, :] = a
        sgreedy, S = scoring_helper.compute_scores(I, Agreedy)
        sgreedy = np.sum(sgreedy)
        assert(sgreedy <= sgreedypre)
    return Agreedy, Ainitial


def experiment_greedy(instances):
    num_instances = len(instances)
    initial_assignments = list()
    initial_scores = list()
    greedy_assignments = list()
    greedy_scores = list()
    greedy_runtimes = list()
    for i in range(num_instances):
        I = instances[i]
        start_time = time.time()
        Agreedy, Ainitial = alg_greedy(I)
        end_time = time.time()
        sinit, Sinit = scoring_helper.compute_scores(I, Ainitial)
        sinit = np.sum(sinit)
        sgreedy, Sgreedy = scoring_helper.compute_scores(I, Agreedy)
        sgreedy = np.sum(sgreedy)
        initial_assignments.append(Ainitial)
        initial_scores.append(sinit)
        greedy_assignments.append(Agreedy)
        greedy_scores.append(sgreedy)
        greedy_runtimes.append(end_time - start_time)
        print(f'instance {i}, initial {sinit}, MMM {sgreedy}, runtime {end_time-start_time}s')
    return initial_assignments, initial_scores, greedy_assignments, greedy_scores, greedy_runtimes


def run_MMM(instances, loc=config.loc):
    initial_assignments, initial_scores, greedy_assignments, greedy_scores, greedy_runtimes = experiment_greedy(instances)
    with open(f'{loc}/initial_MMM_assignments', 'wb') as fo:
        pickle.dump(initial_assignments, fo)
    with open(f'{loc}/initial_MMM_scores', 'wb') as fo:
        pickle.dump(initial_scores, fo)
    with open(f'{loc}/MMM_assignments', 'wb') as fo:
        pickle.dump(greedy_assignments, fo)
    with open(f'{loc}/MMM_scores', 'wb') as fo:
        pickle.dump(greedy_scores, fo)
    with open(f'{loc}/MMM_runtimes', 'wb') as fo:
        pickle.dump(greedy_runtimes, fo)
    print(f'mean initial {np.mean(initial_scores)}, MMM {np.mean(greedy_scores)}')
