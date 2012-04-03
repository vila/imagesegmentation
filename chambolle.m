function [u, iter, max_diff] = chambolle(g, theta, max_iter, w, tau, epsilon, stop_crit)
%CHAMBOLLE Performs Chambolles algorithm for solving the ROF problem
% min_u TV_w(u) + (1/2\theta) * ||u - g||^2
% Parameters:
% max_iter	- maximum number of iterations allowed
% w         - weight for the TV norm (default: ones(size(g)))
% tau       - determines step length (default: 1/4)
% epsilon	- for the stopping critereon (default: 1/100)
% stop_crit	- stopping criterion, available options are
%             'p'       => largest difference in p
%             'divp'    => largest difference in div(p)
%            The default is 'p'
% Output:
% u         - the resulting function
% iter      - number of iterations
% max_diff  - (1 x iter) vector containing the values used to
%               check the stopping criterion for each iteration

% Solves the problem
% min_u  TV_w(u) + (1/2\theta) * ||u - g||^2 

if nargin < 7; stop_crit = 'p';     end
if nargin < 6; epsilon = 1/100;     end
if nargin < 5; tau = 1/4;           end
if nargin < 4; w = ones(size(g));   end

p = zeros([size(g) 2]);

for iter = 1:max_iter
    % we compute \nabla (div(p^n) - g/\theta)    
    d = grad(div(p) - g/theta);
    
    % and then the norm of p_ij divided by w(i,j)
    nd = sqrt(sum(d.^2, 3)) ./ w;
    
    % we just replicate it so we can easily do elementwise division
    nd = repmat(nd, [1 1 2]);
        
    % find p^n+1 from p^n
    new_p = (p + tau*d) ./ (1 + tau * nd);
    
    % Stopping criterions
    if strcmp(stop_crit, 'p');      diff = new_p - p;           end;
    if strcmp(stop_crit, 'divp');   diff = div(new_p) - div(p); end;
    max_diff(iter) = max(abs(diff(:)));
    
    if max_diff(iter) < epsilon
        break;
    end
    
    % update p
    p = new_p;        
end

u = g - theta * div(p);
end


