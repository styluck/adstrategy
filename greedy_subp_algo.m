function [x, fval, cap] = greedy_subp_algo(n, w, p, c, alflg)
% the greedy algorithm for solving subproblem 
% inputs: 
%   n: # of items
%   w: the weighting of the items: P(c_i = t_i | Buy)
%   p: the value of the items: P(c_i = t_i)
%   c: the capacity
%   alflg: allow inefficient strategy
% outputs:
%   x: the solution
%   fval: the value of the objective function
%   cap: the value of the CONSTRAINT 
%
% create: L. Xiao 07-2022

if nargin < 5 || isempty(alflg)
    alflg = 0;
end

ratio = p./w;
x = zeros(n, 1);
[sorted_ratio, idx] = sort(ratio,'descend');

for i=1:n
    if sorted_ratio(i) >= 1 || alflg == 1
        x(idx(i)) = 1;
    end
    
    if iprod(x, w) > c % should not use >=
        break;
    end
end

if iprod(x, p) <= iprod(x, w)
    x = ones(n, 1);
end

if nargout >=2
    fval = iprod(x, p);
    
    cap = iprod(x, w);
end
end

function p = iprod(x,y)
    p = sum(x.*y);
end

% [EOF]