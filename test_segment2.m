clear;

% Load the image
im = imread('cameraman.jpg');
%im = imread('banana.jpg');

% Make sure the image is grayscale in [0,1]
if size(im,3) > 1
    % Multi channel image, convert to grayscale
    im = double(rgb2gray(im))/255;
else
    % Single channel image
    im = double(im)/255;
end

% TODO: perhaps additional preprocessing of the image
%       e.g. grayscale normalization (histogram)

c1 = 0;
c2 = 0.6;

lambda = 0.1;
theta = 1;
beta = 10;

M(30) =  struct('cdata',[],'colormap',[]);
fig = figure;

for k = 1:40
    lambda = 10^((k-16)/10)
    
    % perform the image segmentation
    [C, c1n, c2n] = segment2(im, c1, c2, lambda, theta, beta, 0, 1);

    % show the result
    imagesc(draw_perimeter(im, C));
    title(['f with \partial\{u\}' ...
           '     \lambda = ' num2str(lambda) ...
           '     \theta = ' num2str(theta) ...
           '     \beta = ' num2str(beta) ...
           '\newline' ...
           '     c1 = ' num2str(c1n) ...
           '     c2 = ' num2str(c2n) ]);
   
    drawnow
    M(k) = getframe(fig);
end

movie2gif(M, {M(1:end).cdata}, ['segment2_test.gif'], 'loopcount', Inf, 'delaytime', 0.5)