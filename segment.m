function [ C, c1, c2, iter ] = segment( f, c1, c2, lambda, theta, beta, show_iterations, max_iter, epsilon_tv, epsilon_cv )
%SEGMENT Segments the image using the algorithm proposed in 
% section 3 of the article "Fast Global Minimization of the Active Contour/Snake Model"
% The segmentation is found by solving the problem
%  min_u,v   TV_g(u) + \int(\lambda*r1(x,c1,c2) * u(x))
% 0<=v<=1
% where r1(x,c1,c2) = (c1 - f)^2 - (c2 - f)^2
% Parameters:
% f         - grayscale image with f_ij \in [0,1]
% c1        - initial grayscale level for the foreground
% c2        - initial grayscale level for the background
% lambda    - weight for data term (large lambda => high cost for missmatch)
% theta     - used for (1/2\theta) * ||u - v||^2  (should be small)
%           This is to keep u \approx v
% beta      - the edge indicator function is constructed as
%               g = 1 / (1 + beta*||grad(f)||^2)
% show_iterations - if the intermediate results should be plotted each iteration
% max_iter   - the maximum number of iterations
% epsilon_tv - used as stopping criterion for u,v update
% epsilon_cv - used as stopping criterion for c1,c2 update 
% Output:
% C         - Binary image showing with ones corresponding to c1
% c1, c2    - the final gray levels
% iter      - number of iterations

if nargin < 10; epsilon_cv = 1e-3; end
if nargin < 9; epsilon_tv = 1e-2; end
if nargin < 8; max_iter = 100; end
if nargin < 7; show_iterations = 1; end

% edge indicator function
g = 1 ./ (1 + beta*sum(grad(f).^2, 3));

% we choose u_0 = v_0 = 0
u = zeros(size(f));
v = zeros(size(f));

prev_u = u;
prev_v = v;

% for the data term
r1 = @(c1,c2) (c1 - f).^2 - (c2 - f).^2;

% For creating gifs
%fig = figure;
%M(50) =  struct('cdata',[],'colormap',[]);

for iter = 1:max_iter
    % we solve the problem
    % min_u TV_g(u) + (1/2\theta)*||u - v||^2
    % using chambolles algorithm   
    [u, c_iter] = chambolle(v, theta, 500, g, 1/4, 1e-2);
        
    % we solve the problem
    % min_v (1/2\theta)*||u - v||^2 + \int(\lambda * r1(c1,c2) * v)
    v = u - theta * lambda * r1(c1,c2);   
    v(v > 1) = 1;
    v(v < 0) = 0;
    
    
    % check if u,v have converged and if so update c1 and c2
    d_v = abs(v - prev_v);
    d_u = abs(u - prev_u);    
    if max(max(d_u(:)), max(d_v(:))) < epsilon_tv
        % we update c1 and c2
        m1 = mean(f(u > 0.5));
        m2 = mean(f(~(u > 0.5)));
        
        d_c1 = abs(c1 - m1);
        d_c2 = abs(c2 - m2);
        
        c1 = m1;
        c2 = m2;
        fprintf('c1 = %f, c2 = %f\n', c1, c2);
        
        % check if we have converged
        if max(d_c1, d_c2) < epsilon_cv
            break;
        end
    end
    
    prev_v = v;
    prev_u = u;

    % for debug output
    if show_iterations
        figure(1);
        % find the perimiter of {u > 0.5}
        imagesc(draw_perimeter(f, u > 0.5));
        title(['f with \partial\{u > 0.5\}' ...
            '     \lambda = ' num2str(lambda) ...
            '     \theta = ' num2str(theta) ...
            '     \beta = ' num2str(beta) ...
            '\newline' ...
            '     iter = ' num2str(iter) ...
            '     c1 = ' num2str(c1) ...
            '     c2 = ' num2str(c2) ]);
    
        drawnow
        %M(iter) = getframe(fig);
    end
end

% movie2gif.m is available at http://user.it.uu.se/~stefane/downloads/Utils/movie2gif.m
%movie2gif(M, {M(1:end).cdata}, ['segment_' num2str(lambda) '.gif'], 'loopcount', Inf, 'delaytime', 0.5)

C = u > 0.5;
end

