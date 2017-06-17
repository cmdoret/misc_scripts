# Implementing a simple hidden markov model from scratch and the
# Viterbi algorithm.

# Cyril Matthey-Doret
# 17.06.2017

import numpy as np
from random import randint

class HMM:
    """
    This class creates a hidden markov model object which takes
    several arguments.
    :param N: Number of different states
    :param M: Number of different observations
    :param L: Number of time steps
    :param T: Matrix of transition probabilities
    :param O: Matrix of emission probabilities
    :param S: List of known states
    :param V: List of known observations
    :param init_prob: Vector of initial probabilities for each state
    """

    def __init__(self, N, M, L, T, O, S=0, V=0, init_prob=0):

        self.N, self.M, self.L, self.T, self.O = N, M, L, T, O

        if S and V:  # Are states and observations provided ?
            self.S = S
            self.V = V
        else:
            self.S = np.full((1,self.L), -1)  # Initializing list of states
            self.V = np.full((1,self.L), -1)  # Initializing list of observations

        if init_prob:  # Do we know initial probabilities ?
            self.init_prob = init_prob
        else:
            self.init_prob = [(1/self.N)*100] * self.N


    def proba_pick(self, v):
        """
        This method will pick a category given their
        probability distribution v in percentage.
        :param v: list of percentages to use as weights
        """
        p, s = randint(1,100), 0
        # p is a random number between 1 and 100,
        # s will store the cumsum of weights
        for i in range(len(v)):
            s = s + v[i]  # Adding weights of categories
            if p <= s:  # Is random number smaller than cumsum ?
                return i  # If so, pick category

    def prb(self, x):
        """
        Using logs to reduce memory usage of probabilities
        When multiplying them together.
        :param x: an numeric value between 0 and 100
        representing a probability.
        :return: the log of the probability (as a fraction of 1)
        """
        return np.log(x/100)

    def transition(self, t):
        """
        This method uses the transition probability matrix to
        select the new state at timestep t.
        :param t: timestep
        """

        if t:
            self.S[t] = self.proba_pick(self.T[self.S[t-1]])
        else:  # If starting time, use starting probability vector
            self.S[t] = self.proba_pick(self.init_prob)

    def observe(self, t):
        """
        This method uses the emission probabilty matrix to select
        an observation from state at a given time step.
        :param t: timestep
        """

        self.V[t] = self.proba_pick(self.O[self.V[t]])

    def generate(self):
        """
        Uses the probability matrices to generate a path.
        This is non deterministic as it will depend on the
        different transmission and emission probabilities
        """

        for t in range(self.L):
            self.transition(t)
            self.observe(t)

    def viterbi(self):
        """
        This method runs the Viterbi algorithm
        """

        self.trellis = [[] for t in range(self.L)]
        # Initializes trellis with one empty list per timestep
        for i in range(self.N):
            # Initializes first nodes (t0) of trellis
            self.trellis[0][i] = {'state': i,
             'proba': prb(1/self.N * self.O[i][self.V[0]])}
        for t in range(1,self.L):  # running algorithm
            viterbi_step(t)
        self.bestpath = self.backtrack(self.best_node(self.trellis[self.L]))

    def viterbi_node(self, t, i):
        """
        This method builds a viterbi node for a hidden state at
        a given timestep
        :param t: time step
        :param i: target state for time t
        :return: the node, as a dictionary with its state,
        probability and most likely parent node
        """

        prev = self.trellis[t-1]
        # list of potential parent nodes (N nodes at previous timestep)
        idx, proba = 0, -np.inf
        p = 0
        for j in range(self.N):  # going over possible parent states
            # Everything in log, so the equation below is equivalent to:
            # P(O[t-1](j)) * P(O[t](i)|P(O[t-1](j) * bj(i))))
            p = prev[j]['proba'] + prb(self.T[j][i]) + prb(1/self.N *
                                                           self.O[i][self.V[t]])
            if p > proba:
                # Selecting candidate node with highest probability
                proba, idx = p, j
        return {'state': i,
                'proba': proba,
                'prev': prev[idx]}

    def backtrack(self, node):
        """
        Backtracking through Viterbi nodes to find the optimal path.
        :param node: Node from which the backtrack should start
        :return: List of states from t0 to tf with only the most probable state
        at each timestep
        """
        r = [None] * self.L  # List to store best node at each timestep
        node_exists = True  # Boolean operator to stop when t0 is reached
        nodes_left = self.L - 1  # initial shift due to zero indexing
        while node_exists:
            try:
                r[nodes_left] = node['state']  # Filling list of nodes backwards
                node = node['prev']  # Moving to parent (optimal) node
                nodes_left -= 1
            except:
                node_exists = False # When t0 is reached, exit loop
        return r

    def best_node(nodes):
        """
        Selecting the very best node in given timestep.
        :param nodes: Nodes for different states at the same timestep
        :return: Node with the highest probability in the input set
        """
        r = {'proba': -np.inf}  # Initiating with mallest value possible
        for i in range(len(nodes)):  # Iterating over states
            if nodes[i]['proba'] > r['proba']:  # Keep node with highest proba
                r = nodes[i]
        return r

    def viterbi_step(self, t):
        """
        One iteration of the viterbi algorithm
        :param t: time step on which to run the iteration
        """
        self.trellis[t] = {}
        for i in range(self.N):
            self.trellis[t][i] = viterbi_node(t, i)



# tr_mat[i,j] -> probability of moving from state i to j
tr_mat = np.array([[60,20, 20],
                   [0, 70, 30],
                   [70,10, 20]])
# em_mat[i,j] -> probability of observing i on state i
em_mat = np.array([[5, 95],
                   [55,45],
                   [90,10]])
test_hmm = HMM(N=3, M=2, L=1000, T=tr_mat, O=em_mat)
test_hmm.generate()

# =============
# Testing area: measuring success
ok = 0
for i in range(test_hmm.L):
  if test_hmm.S[i] == test_hmm.bestpath[i]:
    ok += 1

print(100*ok/L)
