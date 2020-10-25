# Breif Explanation for Functions
## Optimization Algorithms
* ``opt_ilp.py`` corresponds to the Integer Linear Programming (ILP) optimization;
* ``alg_greedy.py`` corresponds to the Min-Max Greedy Matching (MMM) optimization;
* ``alg_cyclicgreedy.py`` corresponds to the MMM optimiztion with Cyclic Greedy Searching (CGS) initialization;
* ``alg_CGS.m`` corresponds to the CGS optimization;
* ``alg_cyclic.py`` converts the CGS result obtained with MATLAB to python version.
## Main Function
* ``dot.py`` is the main function;
* ``config.py`` holds the configuration of the DOT, i.e., the number of students ``n``, the size of the question pool ``m``, the number of questions in one test ``q``, the number of instances ``num_instances``.
## Others
* ``instance_helper.py`` can generate DOT instances ( ``n``,``m``,``q``, uniformly distributed competences ``y``, and Dirichlet distributed colluding matrix ``P``), and convert ``.instance`` (python version) to ``.mat`` (MATLAB version);
* ``report.py`` report the statistics of the optimization results of different algorithms;
* ``scoring_helper.py`` computes the scores with collusion for each instance.

# Usage
## generate new instances
* (1) Change the configurations in the ``config.py`` file accordingly;
* (2) Uncomment lines 33 and 34 in ``dot.py``,
```
instances = instance_helper.generate_instances(config.n, config.m, config.q, config.num_instances, loc=config.loc)
instance_helper.convert_instances_pickle_to_mat(loc=config.loc, num_instances=config.num_instances)
```
and comment all other lines in the main() function;
* (3) Run ``dot.py`` with Python.
Generated instances (both ``.instance`` and ``.mat`` files) will be saved under the folder ``{n}_{m}_{q}_instances``.
