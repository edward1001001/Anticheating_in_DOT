import numpy as np


def score_copying_pair(ai, ak, yi, yk):
    """
    # questions on which i copies from k
    Input:
        ai: m-vector assignment of agent i
        ak: m-vector assignment of agent k
        yi: real number, ability of agent i
        yk: real number, ability of agent k
    Output:
        s: m-vector, s[j] takes value yi if i answers, yk if i copies from k, 0 otherwise
    """
    m = np.size(ai)
    score = np.zeros(m)
    itested = np.where(np.array(ai) > 0)[0]
    if yi >= yk:
        score[itested] = yi
    else:
        ktested = np.where(np.array(ak) > 0)[0]
        for j in itested:
            if not j in ktested:
                score[j] = yi
            else:
                if ak[j] <= ai[j]:
                    score[j] = yk
                else:
                    score[j] = yi
    return score


def compute_scores(I, A):
    """
    Input:
        I: (n, m, q, y, P) instance
        A: nxm-matrix of assignments
    Output:
        scores: n-vector of scores
    """
    (n, m, q, y, P) = I
    A = np.array(A)
    S = np.zeros((n,n))
    for i in range(n):
        ai = A[i,:]
        yi = y[i]
        for k in range(i+1):
            ak = A[k,:]
            yk = y[k]
            pik = P[i,k]
            if pik > 0:
                sik = score_copying_pair(ai, ak, yi, yk)
                sik = np.sum(sik)
                S[i,k] = pik*sik
    scores = np.sum(S, axis=1)
    return scores, S
