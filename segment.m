function [ C, c1, c2 ] = segment( f, c1, c2, lambda, theta, beta, show_iterations, max_iter )
%SEGMENT Segments the image 
% f - grayscale image with f_ij \in [0,1]
% c1 - initial grayscale level for the foreground
% c2 - initial grayscale level for the background
% lambda - weight for data term (large lambda => high cost for missmatch)
% theta - used for (1/2\theta) * ||u - v||^2  (should be small)
% beta - the edge indicator function is constructed as
%        g = 1 / (1 + beta*||grad(f)||^2)

if nargin < 8
    max_iter = 100;
end

if nargin < 7
    show_iterations = 1;
end

% edge indicator function
g = 1 ./ (1 + beta*sum(grad(f).^2, 3));

% we choose u_0 = v_0 = 0
u = zeros(size(f));
v = zeros(size(f));

% for the data term
r1 = @(c1,c2) (c1 - f).^2 - (c2 - f).^2;

% For creating gifs
%fig = figure;
%M(50) =  struct('cdata',[],'colormap',[]);

for iter = 1:max_iter
    % we solve the problem
    % min_u TV_g(u) + (1/2\theta)*||u - v||^2
    % using chambolles algorithm   
    [u, c_iter] = chambolle(v, theta, 100, g);
        
    % we update c1 and c2 every 10-th iteration
    % with the mean values of the image areas
    if mod(iter, 10) == 0
        c1 = mean(f(u > 0.5));
        c2 = mean(f(u <= 0.5));
        fprintf('c1 = %f, c2 = %f\n', c1, c2);
    end

    % we solve the problem
    % min_v (1/2\theta)*||u - v||^2 + \int(\lambda * r1(c1,c2) * v)
    v = u - theta * lambda * r1(c1,c2);   
    v(v > 1) = 1;
    v(v < 0) = 0;
    
    % TODO: stopping critereon

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

