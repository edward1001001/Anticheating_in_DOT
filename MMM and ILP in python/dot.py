"""
Instance:
    n: # agents
    m: # questions
    q: # questions in each exam
    y: n-vector of agents abilities, assumed to be in decreasing order
    P: nxn-matrix cheating network
"""

import pickle
import numpy as np

import config
import instance_helper
import alg_cyclic
import alg_greedy
import alg_cyclicgreedy
import opt_ilp
import report


def main():
    # instances = instance_helper.generate_instances(config.n, config.m, config.q, config.num_instances, loc=config.loc)
    # instance_helper.convert_instances_pickle_to_mat(loc=config.loc, num_instances=config.num_instances)
    # instances = instance_helper.load_instances(loc=config.loc, num_instances=config.num_instances)
    # print(f'loaded {len(instances)} instances')
    # alg_cyclic.run_cyclic(instances, loc=config.loc)
    # alg_greedy.run_greedy(instances, loc=config.loc)
    # alg_cyclicgreedy.run_cyclicgreedy(instances, loc=config.loc, cycloc=f'{config.loc}/greedy_cyclic_assignments')
    # opt_ilp.run_ilp(instances, loc=config.loc)
    report.report(loc=config.loc)


if  __name__ == '__main__':
    main()
