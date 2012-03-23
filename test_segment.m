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

% foreground/background grayscale images
c1 = 0;
c2 = 0.6;

lambda = 0.5;
theta = 1;
beta = 10;

% perform the image segmentation
C = segment(im, c1, c2, lambda, theta, beta, 1, 50);

% show the result
imagesc(draw_perimeter(im, C));