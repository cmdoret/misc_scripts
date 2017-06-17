# Implementing a simple hidden markov model from scratch and the
# Viterbi algorithm.

# Cyril Matthey-Doret
# 17.06.2017

import numpy as np
from random import randint

class hmm:

    def __init__(self, N, M, L, T, O):

    self.N = N  # Number of different states
    self.m = M  # Number of different observations
    self.L = L  # Number of time steps
    self.T = T  # Matrix of transition probabilities
    self.O = O  # Matrix of emission probabilities
    self.S = np.full(c(1,L), -1)  # List of states
    self.V = np.full(c(1,L), -1)  # List of observations

    def proba_pick(self, v):
        # This method will pick a category given their
        # probability distribution v in percentage
        p, s = randint(1,100), 0
        # p is a random number between 1 and 100,
        # s will store the cumsum of weights
        for i in range(len(v)):
            s = s + v[i]  # Adding weights of categories
            if p <= s:  # Is random number smaller than cumsum ?
                return i  # If so, pick category

    def transition(self, t):
        # This method uses the transition probability matrix to
        # select the new state at timestep t.
        if t:
            self.S[t] = self.proba_pick(self.T[self.S[t-1]])
        else:  # If starting time, use starting probability vector
            self.S[t] = self.proba_pick(self.T[self.S[t-1]])

    def observe(self, t):
        # This method uses the emission probabilty matrix to select
        # an observation from state at time t.
        self.V[t] = self.proba_pick(self.O[self.V[t]])


# tr_mat[i,j] -> probability of moving from state i to j
tr_mat = np.array([[60,20, 20],
                   [0, 70, 30],
                   [70,10, 20]])
# em_mat[i,j] -> probability of observing i on state i
em_mat = np.array([[5, 95],
                   [55,45],
                   [90,10]])

hmm(N=3, M=2, L=1000, T=tr_mat, O=em_mat)
