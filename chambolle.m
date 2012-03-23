function [u, iter] = chambolle(g, theta, max_iter, w, tau)
%CHAMBOLLE Performs chambolles algorithm for Total Variation Minimization
% with a weighting w(x) for the TV norm.

% Solves the problem
% min_u  TV_w(u) + (1/2\theta) * ||u - g||^2 


if nargin < 5
   tau = 1/4; 
end

if nargin < 4
   w = ones(size(g)); 
end

p = zeros([size(g) 2]);

for iter = 1:max_iter
    % we compute \nabla (div(p^n) - g/\theta)    
    d = grad(div(p) - g/theta);
    
    % and then the norm of p_ij divided by w(i,j)
    nd = sqrt(sum(d.^2, 3)) ./ w;
    %nd = (abs(d(:,:,1)) + abs(d(:,:,2))) ./ w;
    
    % we just replicate it so we can easily do elementwise division
    nd = repmat(nd, [1 1 2]);
        
    % find p^n+1 from p^n
    new_p = (p + tau*d) ./ (1 + tau * nd);
    
    diff = abs(new_p - p);
    p = new_p;

    % we break when the max difference (in any element) between
    % two iterations is less than 1/100 
    if(max(diff(:)) <= 1/100)
        break;
    end
end

proj = theta * div(p);
u = g - proj;

end


