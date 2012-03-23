clear;

% Load the image
%im = imread('cameraman.jpg');
im = imread('banana.jpg');

% Make sure the image is grayscale in [0,1]
if size(im,3) > 1
    % Multi channel image, convert to grayscale
    im = double(rgb2gray(im))/255;
else
    im = double(im)/255;
end

c1 = 0.9;
c2 = 1;

lambda = 10;
theta = 1;
beta = 10;

C = segment(im, c1, c2, lambda, theta, beta, 1, 50);
