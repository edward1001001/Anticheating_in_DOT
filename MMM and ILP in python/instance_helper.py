"""
Instance:
    n: # agents
    m: # questions
    q: # questions in each exam
    y: n-vector of agents abilities, assumed to be in decreasing order
    P: nxn-matrix cheating network
"""

import os
import pickle
import scipy.io
import numpy as np

import config


def generate_abilities(n):
    """
    Input:
        n: # agents
    Output:
        y: n-vector of agents' abilities, y[i] in [0,1]
    """
    y = [np.random.uniform(0.25, 1) for i in range(n)]
    y = sorted(y, reverse=True)
    y = np.array(y)
    return y


def generate_cheating_network(n, y):
    """
    Input:
        n: # agents
        y: n-vector of agents' abilities, y[i] in [0,1]
    Output:
        P: nxn-matrix P[i,k] = probability that i copies from agent k, \sum_k P[i,k] = 1
    """
    assert(np.size(y) == n)
    P = np.zeros((n, n))
    for i in range(n):
        candidates = [k for k in range(n) if y[k] > y[i]] # change to y[k] >= y[i] to have a probability of not cheating
        ncandidates = len(candidates)
        if ncandidates == 0:
            P[i,i] = 1
        else:
            probabilities = np.random.dirichlet(np.ones(ncandidates),size=1)[0]
            for l in range(ncandidates):
                c = candidates[l]
                p = probabilities[l]
                P[i,c] = p
    return P


def generate_dot_instance(n, m, q, fnability=generate_abilities, fncheating=generate_cheating_network):
    y = generate_abilities(n)
    assert(np.size(y) == n)
    P = generate_cheating_network(n, y)
    assert(np.shape(P) == (n,n))
    return n, m, q, y, P


def generate_instances(n, m, q, num_instances, loc=config.loc):
    """
    Generate num_instances instances
    """
    dir = '/'.join(loc.split('/')[:-1])
    if not os.path.exists(dir):
        os.mkdir(dir)
    instances = list()
    for i in range(num_instances):
        out_n, out_m, q, Y, P = generate_dot_instance(config.n, config.m, config.q, fnability=globals()['generate_abilities'], fncheating=globals()['generate_cheating_network'])
        instances.append((out_n, out_m, q, Y, P))
        fname = f'{loc}/{i}.instance'
        with open(fname, 'wb') as fo:
            pickle.dump((out_n, out_m, q, Y, P), fo)
    return instances


def load_instances(loc=config.loc, num_instances=0):
    instances = list()
    for i in range(num_instances):
        fname = f'{loc}/{i}.instance'
        with open(fname, 'rb') as f:
            r = pickle.load(f)
            instances.append(r)
    return instances


def convert_instances_pickle_to_mat(loc=config.loc, num_instances=0):
    instances = list()
    for i in range(num_instances):
        fname = f'{loc}/{i}.instance'
        with open(fname, 'rb') as f:
            r = pickle.load(f)
            instances.append(r)
    for i in range(num_instances):
        I = instances[i]
        scipy.io.savemat(f'{loc}/{i}.mat', mdict={'instance': I})


def test_to_assignment(b, m):
    """
    Input:
        b: q-vector of question names
        m: # questions
    Output:
        a: m-vector, a[j] is the position of question j on the test according to input b
    """
    q = np.size(b)
    a = np.zeros(m)
    for i in range(q):
        j = b[i]
        a[j] = i+1
    return a
