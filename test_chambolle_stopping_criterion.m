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

beta = 10;
w = 1 ./ (1 + beta*sum(grad(im).^2, 3));
tau = 1/4;
epsilon = 1e-15; % small enough so that it should run max_iter iterations
max_iter = 100;

diff_plot = figure;

for k = 1:6
theta = 10.^(k-4);
[im_p, iter_p, diff_p] = chambolle(im, theta, max_iter, w, tau, epsilon, 'p');
[im_np, iter_np, diff_np] = chambolle(im, theta, max_iter, w, tau, epsilon, 'np');
[im_divp, iter_divp, diff_divp] = chambolle(im, theta, max_iter, w, tau, epsilon, 'divp');

figure(diff_plot);
subplot(3,2,k)
semilogy(1:iter_p, diff_p, 'r-', 1:iter_divp, diff_divp, 'b-',1:iter_np, diff_np, 'g--');
legend('||p_{n+1} - p_{n}||_{\infty,\infty}', '||div(p_{n+1}) - div(p_{n})||_\infty', '||p_{n+1} - p_{n}||_{\infty,2}') 
title(['\theta = ' num2str(theta)]);
end





