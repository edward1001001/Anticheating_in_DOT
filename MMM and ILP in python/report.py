import pickle
import numpy as np
import matplotlib.pyplot as plt

import config


def report(loc=config.loc):
    with open(f'{loc}/honest', 'rb') as f:
        honest = pickle.load(f)
        honest = np.array(honest)
    files = {
        'init_cyc': f'{loc}/initial_cyclic_score',
        'cyc': f'{loc}/greedy_cyclic_score',
        'random': f'{loc}/initial_greedy_scores',
        'greedy': f'{loc}/greedy_scores',
        'cyc_greedy': f'{loc}/greedy_greedy_scores',
        'ilp': f'{loc}/ilp_score'
    }
    labels = {
        'init_cyc': r'Cyclic',
        'cyc': r'Alg-Cyclic',
        'random': r'Random',
        'greedy': r'Alg-Greedy',
        'cyc_greedy': r'Alg-Cyclic+Greedy',
        'ilp': r'ILP'
    }
    # algs = ['random', 'init_cyc', 'cyc', 'greedy', 'cyc_greedy', 'ilp']
    algs = ['random', 'init_cyc', 'cyc', 'greedy', 'cyc_greedy']
    q = config.q
    scores = dict()
    for a in algs:
        with open(files[a], 'rb') as f:
            s = pickle.load(f)
            s = np.array(s)
            s = (1/q)*(s - honest)
            scores[a] = s
    plt.rcParams.update({'font.size': 13, 'font.weight': 'bold'})
    plt.figure()
    plt.boxplot([scores[a] for a in algs], showmeans=True, vert=False)
    plt.yticks([i+1 for i in range(len(algs))], [labels[a] for a in algs])
    plt.xlabel(r'gain ($g$)')
    plt.title(rf'$N$={config.n}, $M_p$={config.m}, $M$={config.q}, {config.num_instances} instances')
    plt.grid()
    plt.tight_layout()
    plt.savefig(f'{loc}/report_{config.n}_{config.m}_{config.q}.png')
    plt.show()

    """
    with open(f'{loc}/greedy_cyclic_runtimes', 'rb') as f:
        greedy_cyclic_runtime = pickle.load(f)
    with open(f'{loc}/greedy_runtimes', 'rb') as f:
        greedy_runtime = pickle.load(f)
    with open(f'{loc}/greedy_greedy_runtimes', 'rb') as f:
        greedy_greedy_runtime = pickle.load(f)
    with open(f'{loc}/ilp_runtimes', 'rb') as f:
        ilp_runtime = pickle.load(f)
    """
