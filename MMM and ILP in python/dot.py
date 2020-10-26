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

def honestScore(instances):
    honest_score_all = np.zeros(config.num_instances)
    for i in range(config.num_instances):
        (n, m, q, y, P) = instances[i]
        shonest = np.sum([q*y[k] for k in range(n)])
        honest_score_all[i] = shonest
    with open(f'{config.loc}/honest', 'wb') as fo:
        pickle.dump(honest_score_all, fo)
    

def main():
    # # # Generate instances
    # instances = instance_helper.generate_instances(config.n, config.m, config.q, config.num_instances, loc=config.loc)
    # instance_helper.convert_instances_pickle_to_mat(loc=config.loc, num_instances=config.num_instances)
    
    # # # Optimization 
    # load instances
    instances = instance_helper.load_instances(loc=config.loc, num_instances=config.num_instances)
    # calculate honest scores, if the honest file does not exist
    honestScore(instances)

    
    print(f'loaded {len(instances)} instances')
    # MMM
    alg_greedy.run_MMM(instances, loc=config.loc) # MMM
    # CGS
    alg_cyclic.loadCGS(instances) # load CGS
    # MMM-CGS
    alg_cyclicgreedy.run_MMM_CGS(instances, loc=config.loc, cycloc=f'{config.loc}/CGS_assignments') # MMM-CGS
    # ILP, usually takes a long time for large scale optimization
#    opt_ilp.run_ilp(instances, loc=config.loc) # ILP
    
    # report with ilp
#    report.report(loc=config.loc, algs=['random', 'MMM', 'CGS', 'MMMCGS', 'ilp'])
    # report without ilpS
    report.report(loc=config.loc, algs=['random', 'MMM', 'CGS', 'MMMCGS'])


if  __name__ == '__main__':
    main()
