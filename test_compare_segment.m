clear;
close all;

% Load the image
im = imread('cameraman.jpg');

% Make sure the image is grayscale in [0,1]
if size(im,3) > 1
    % Multi channel image, convert to grayscale
    im = double(rgb2gray(im))/255;
else
    % Single channel image
    im = double(im)/255;
end

c1 = 0;
c2 = 0.6;

lambda = 1000;
beta = 10;
max_iter = 50;
figure;

for k = 1:5
    theta = 10^(1-k);
   
    [C, c1_tv, c2_tv, iter] = segment(im, c1, c2, lambda, theta, beta, 0, max_iter);
    
    subplot(3,2,k);
    imagesc(draw_perimeter(im,C)); colormap(gray);
    title(['\theta = ' num2str(theta) ', c = [' num2str([c1_tv c2_tv]) '], iter = ' num2str(iter)]);
    drawnow
end

[C_rof, c1_rof, c2_rof, iter] = segment2(im, c1, c2, lambda, 1, beta, 0, max_iter);
subplot(3,2,6);
imagesc(draw_perimeter(im,C_rof)); colormap(gray);
title(['ROF c = [' num2str([c1_rof c2_rof]) '], iter = ' num2str(iter)]);


