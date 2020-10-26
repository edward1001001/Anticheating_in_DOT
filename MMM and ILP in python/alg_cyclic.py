import copy
import pickle
import numpy as np
import scipy.io

import config
import instance_helper
import scoring_helper


def loadCGS(instances, assignment_loc=None, loc=config.loc):
    if assignment_loc is None:
        assignment_loc = f'{config.n}_{config.m}_{config.q}_instances/N{config.n}_Mp{config.m}_M{config.q}_alg2'
    data = scipy.io.loadmat(assignment_loc)
    tbank = data['PSetsPool'] - 1 # because matlab
    data_assignments = data['QSA']
    data_assignments = np.array(data_assignments)
    data_assignments = data_assignments[1:,:]
    data_assignments = data_assignments - 1 # because matlab
    assert(np.shape(data_assignments)[1] == config.n)
    data_num_instances = np.shape(data_assignments)[0]
    num_instances = len(instances)
    assert(data_num_instances == num_instances)
    assignments = list()
    scores = list()
    for c in range(num_instances):
        data_A = data_assignments[c, :]
        assert(np.size(data_A) == config.n)
        I = instances[c]
        A = np.zeros((config.n, config.m))
        for i in range(config.n):
            data_a = copy.deepcopy(data_A[i])
            t = tbank[data_a]
            assert(np.size(t) == config.q)
            a = instance_helper.test_to_assignment(t, config.m)
            A[i, :] = np.array(a)
        assignments.append(A)
        s, S = scoring_helper.compute_scores(I, A)
        s = np.sum(s)
        scores.append(s)
    with open(f'{loc}/CGS_scores', 'wb') as fo:
        pickle.dump(scores, fo)
    with open(f'{loc}/CGS_assignments', 'wb') as fo:
        pickle.dump(assignments, fo)

