import sys
import time
import copy
import pickle
import numpy as np
import networkx as nx

import config
import scoring_helper
import alg_greedy


def alg_cyclicgreedy(I, Acyc=None):
    """
    Input:
        I: (n, m, q, y, P) instance
    Output:
        Agreedy: nxm assignment matrix
        Ainit: nxm assignment matrix
    """
    (n, m, q, y, P) = I
    assert(Acyc is not None)
    Agreedy, Ainit = alg_greedy.alg_greedy(I, Ainitial=Acyc)
    assert(np.array_equal(Ainit, Acyc))
    sinit, Sinit = scoring_helper.compute_scores(I, Ainit)
    sinit = np.sum(sinit)
    sgreedy, Sgreedy = scoring_helper.compute_scores(I, Agreedy)
    sgreedy = np.sum(sgreedy)
    assert(sgreedy <= sinit)
    return Agreedy, Acyc


def experiment_cyclicgreedy(instances, cycloc=None):
    num_instances = len(instances)
    initial_assignments = list()
    initial_scores = list()
    greedy_assignments = list()
    greedy_scores = list()
    greedy_runtimes = list()
    if cycloc is not None:
        with open(cycloc, 'rb') as f:
            cyc_assignments = pickle.load(f)
            assert(len(cyc_assignments) == len(instances))
    for i in range(num_instances):
        I = instances[i]
        start_time = time.time()
        Acyc = None
        if cycloc is not None:
            Acyc = cyc_assignments[i]
        Agreedy, Ainitial = alg_cyclicgreedy(I, Acyc=Acyc)
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
        print(f'instance {i}, initial {sinit}, MMM-CGS {sgreedy}, runtime {end_time-start_time}s')
    return initial_assignments, initial_scores, greedy_assignments, greedy_scores, greedy_runtimes


def run_MMM_CGS(instances, loc=config.loc, cycloc=None):
    initial_assignments, initial_scores, greedy_assignments, greedy_scores, greedy_runtimes = experiment_cyclicgreedy(instances, cycloc=cycloc)
    with open(f'{loc}/MMMCGS_assignments', 'wb') as fo:
        pickle.dump(greedy_assignments, fo)
    with open(f'{loc}/MMMCGS_scores', 'wb') as fo:
        pickle.dump(greedy_scores, fo)
    with open(f'{loc}/MMMCGS_runtimes', 'wb') as fo:
        pickle.dump(greedy_runtimes, fo)
