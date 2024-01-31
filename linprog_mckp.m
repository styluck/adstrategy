function [c_prob, prob, pval, x, t] = linprog_mckp(Li, p, q, groups, prtflg, debug)
% create: L.Xiao 07-2023
% clc; clear; close all;
tic;

if nargin < 6 || isempty(debug)
    debug = false;
end
% load data

if debug
    ii = 1;
    N_test = 50;
    L = logspace(-10,0,N_test);
    Li = L(ii);
    prtflg = 1;
    [p, q, groups] = loaddata();
end

budgets = - round(log(Li));

% -----------------------------
% obtain the LP relaxation
% x = linprog(f, A, b,Aeq,beq,lb,ub) ;
% min f'*x
% such that A*x <= b
%           Aeq*x = beq
%           lb <= x <= ub
% -----------------------------

ngroup = max(groups);
nvars = length(p);
f = - (log(p) - log(q)); % values
b = [budgets; ones(ngroup,1)];

A = - log(q)'; % weights
for i = 1:ngroup
    Ai = (groups==i);
    A = [A; Ai'];
end

lb = zeros(nvars, 1);

% find solution
x = linprog(f, A, b, [], [], lb, []);

items_decimal = find(x>0);
items_one = find(x==1);

if length(items_decimal) == length(items_one)
    items = items_one;

else
    fprintf('there it is\n')
    c = setdiff(items_decimal, items_one);
    [cf, idx] = sort(f(c),'descend');
    c = c(idx);

    % -----------------------------
    % conduct branch and bound algorithm
    x_tmp = zeros(nvars, 1);
    x_tmp(items_one) = 1;
    x_old = x_tmp;

    for j = 1:length(c)
        x_tmp(c(j)) = 1;

        if A(1,:)*x_tmp > budgets
            x_tmp(c(j)) = 0;

        elseif f'*x_tmp <= f'*x_old
            x_tmp(c(j)) = 0;

        else % add new item success
            x_old = x_tmp;
        end    
            
    end
    % -----------------------------
    x = x_tmp;
    items = find(x==1);
end

if debug
    ii = ii + 1;
end

if sum(x)>0
    fprintf('Calculation finished.\n')

    c_prob = prod(p(items)); % P(Buy & c \in S)
    prob = prod(q(items));% P(c \in S)
    pval = c_prob/prob;  % P(Buy | c \in S)
    
else
    fprintf('Trivial solution.\n')
    c_prob = 1;
    prob = 1;
    pval = 1;
end

if prtflg
    fprintf('P(Buy | c in F^s): \t%8.5fB \n', pval);
    fprintf('P(c in F^s):    \t%8.5f \n', prob);
    fprintf('P(Buy & c in F^s):\t%8.5fB \n', c_prob);
end
t = toc;

% [EOF]