function [ C, c1, c2, iter ] = segment2( f, c1, c2, lambda, theta, beta, show_iterations, max_iter, epsilon )
%SEGMENT2 Segments the image by solving the problem 
%  min_u TV_g(u) + \int(\lambda*r1(x,c1,c2) * u(x))
% 0<=u<=1
% where r1(x,c1,c2) = (c1 - f)^2 - (c2 - f)^2
% This is accomplished by solving the ROF problem 
%  min_w TV_g(w) + 1/(2*\theta) * ||w - (-\lambda*r1)||^2
% and then constructing u by thresholding w around zero.
% Parameters:
% f - grayscale image with f_ij \in [0,1]
% c1 - initial grayscale level for the foreground
% c2 - initial grayscale level for the background
% lambda - weight for data term (large lambda => high cost for missmatch)
% theta - should be 1
% beta      - the edge indicator function is constructed as
%               g = 1 / (1 + beta*||grad(f)||^2)
% show_iterations - if the intermediate results should be plotted each iteration
% max_iter   - the maximum number of iterations
% epsilon - used as stopping criterion for c1,c2 update 
% Output:
% C         - Binary image showing with ones corresponding to c1
% c1, c2    - the final gray levels
% iter      - number of iterations

if nargin < 9; epsilon = 1e-3; end
if nargin < 8; max_iter = 100; end
if nargin < 7; show_iterations = 1; end

% edge indicator function
g = 1 ./ (1 + beta*sum(grad(f).^2, 3));

% for the data term
r1 = @(c1,c2) (c1 - f).^2 - (c2 - f).^2;

% For creating gifs
%fig = figure;
%M(50) =  struct('cdata',[],'colormap',[]);

for iter = 1:max_iter
    % we solve the problem
    % min_u TV_g(w) + (1/2\theta)*||w - (-lambda*r1)||^2
    % using chambolles algorithm   
    [w, c_iter] = chambolle(-lambda*r1(c1,c2), theta, 5000, g, 1/4, 1e-3);
    
    fprintf('c_iter = %d\n', c_iter);
    
    % the solution to
    % min_u TV_g(u) - <(-lambda*r1), u>
    % is then given by thresholding w around zero
    u = w >= 0;
    
    % we update c1 and c2
    m1 = mean(f(u));
    m2 = mean(f(~u));
        
    d_c1 = abs(c1 - m1);
    d_c2 = abs(c2 - m2);
    
    c1 = m1;
    c2 = m2;
    
    fprintf('c1 = %f, c2 = %f\n', c1, c2);
    % check if we have converged
    if max(d_c1, d_c2) < epsilon
        break;
    end
    
    % for debug output
    if show_iterations
        figure(1);
        % draw the perimiter of u
        imagesc(draw_perimeter(f, u));
        title(['f with \partial\{u\}' ...
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

C = u;
end

