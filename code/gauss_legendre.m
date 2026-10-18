function [x, w] = gauss_legendre(n)
%GAUSS_LEGENDRE Return n-point Gauss-Legendre nodes and weights.
% Uses the Golub-Welsch eigenvalue construction on the interval (-1, 1).
% Outputs are sorted row vectors.
% The symmetric Jacobi matrix encodes the Legendre recurrence coefficients.
i = 1:n-1;
v = i ./ sqrt(4*i.^2 - 1);
[V, D] = eig(diag(v, 1) + diag(v, -1));
x = diag(D);
[x, idx] = sort(x);
w = 2 * V(1, idx).^2;
x = x(:).';
w = w(:).';
end
