# -*- coding: utf-8 -*-
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
import scipy.io


def main():
     instances = instance_helper.generate_instances(config.n, config.m, config.q, config.num_instances, loc=config.loc)
     instance_helper.convert_instances_pickle_to_mat(loc=config.loc, num_instances=config.num_instances)
    



if  __name__ == '__main__':
    main()
    