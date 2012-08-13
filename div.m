function div_A = div(A)
%DIV Calculates the divergence as specified in the paper by Chambolle
% A should be MxNx2

% chambolles definition
%A1 = [A(:,1,1) (A(:,2:end-1,1) - A(:,1:end-2,1)) -A(:,end-1,1)];
%A2 = [A(1,:,2);(A(2:end-1,:,2) - A(1:end-2,:,2)); -A(end-1,:,2)];

% circular definition
A1 = A(:,:,1) - A(:,[end 1:end-1], 1);
A2 = A(:,:,2) - A([end 1:end-1],:, 2);

div_A = A1 + A2;