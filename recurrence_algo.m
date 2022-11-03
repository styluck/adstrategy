function [c_prob, prob, pval, X] = recurrence_algo(L, prtflg, alflg)
% recurrence algorithm for solving the optimal advertising problem
%
% input: L: the ad expenditure budget
%        prtflg: printing screen flag (default = 1)
%        alflg: allow inefficient strategy
% output: c_prob: the probability of P(Buy & c in F^s)
%           prob: the probability of P(c in F^s)
%           pval: the conditional probability of P(Buy | c in F^s)
%
% create: L. Xiao 07-2022

if nargin < 3 || isempty(alflg)
    alflg = 0;
end

if nargin < 2 || isempty(prtflg)
    prtflg = 1;
end

addpath(genpath('data'));
addpath(genpath('knapsack'));
A = dir('data/*.mat');

% param definition
% prtflg = 0;
% L = 1;
tiny = 1e-3;
ext = 1e3;
n = length(A);
c = zeros(n,1) + tiny;
X = zeros(n,1);
p = zeros(n,1);
q = zeros(n,1);
p_tmp = zeros(n,1);
q_tmp = zeros(n,1);

itr = 1;
% solve subproblem
while 1
    for i = 1:n
        % load data
        data = load(['data/',A(i).name]);

        p_sub = data.table(:,1);
        w_sub = data.table(:,2);
        n_sub = size(data.table,1);

        % solve subproblem
        [~, p_tmp(i), q_tmp(i)] = greedy_subp_algo(n_sub, w_sub, p_sub, c(i), alflg);

    end


    % remove items with q = 1
    if sum(q) == n || round(L,3) == 1
        % trivial solution
        fprintf('Trivial solution.\n')
        c_prob = 1;
        prob = 1;
        pval = 1;
        break;
    end

    nq = find(round(q_tmp,3) ~= 1);
    if ~isempty(nq)
        q = q_tmp(nq);
        p = p_tmp(nq);
    else
        q = q_tmp;
        p = p_tmp;
    end


    % solve the knapsack problem
    values = round((log(p) - log(q))*ext);
    weights =  - round(log(q)*ext);
    budgets = - round(log(L)*ext);
    [fval, X] = knapsack(weights, values, budgets);
    items = find(X);
    cap = sum(weights(items));

    if sum(X)>0
        fprintf('Calculation finished.\n')

        c_prob = prod(p(items));
        prob = prod(q(items));
        pval = c_prob/prob;
        
        break;
    elseif itr < 10
        c = q + tiny;
    else
        fprintf('Calculation failed.\n')

        c_prob = prod(p(items));
        prob = prod(q(items));
        pval = c_prob/prob;
        break;
    end
    itr = itr + 1;
end


if prtflg
    fprintf('P(Buy | c in F^s): \t%8.2fB \n', pval);
    fprintf('P(c in F^s):    \t%8.2f \n', prob);
    fprintf('P(Buy & c in F^s):\t%8.2fB \n', c_prob);
end

% [EOF]