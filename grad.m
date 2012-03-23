function grad_A = grad(A)
%GRAD Computes the gradient as specified in the paper by Chambolle
% A should be a MxN matrix

A1 = [(A(:,2:end)-A(:,1:end-1)) zeros(size(A,1),1)];
A2 = [(A(2:end,:)-A(1:end-1,:)); zeros(1,size(A,2))];

grad_A(:,:,1) = A1;
grad_A(:,:,2) = A2;
