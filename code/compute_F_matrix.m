function [F, wellx, dx] = compute_F_matrix(Kx, Ky, Kz, Ss, a, b, c, ...
                                           x0, y0, z0, L, Nk, dt, N, nd)
%COMPUTE_F_MATRIX Build the transient drawdown influence matrix.
% The well is aligned with x and divided into Nk segments centred at wellx.
% The x faces are constant head; the y and z faces are impermeable.
% F maps segment totals q to drawdown s through s = F*q at time dt.
% N controls the spatial series and nd controls Gauss-Legendre integration.

% Place source and observation points at segment centres.
dx = L / Nk;
xw_b = x0 - L/2;
wellx = xw_b + ((1:Nk) - 0.5) * dx;

% Map quadrature nodes and weights from (-1, 1) to (0, dt).
[xi, wi] = gauss_legendre(nd);
tau = 0.5 * (xi + 1) * dt;
w   = 0.5 * wi * dt;

m = (1:N)';

% Evaluate the y-direction impermeable-boundary kernel, including its zero mode.
Ey = exp(-(Ky/Ss) * bsxfun(@times, (m*pi/b).^2, tau));
P2 = 2 * cos(m*pi*y0/b) .* cos(m*pi*y0/b);
S2 = sum(bsxfun(@times, P2, Ey), 1);

% Evaluate the analogous z-direction kernel.
Ez = exp(-(Kz/Ss) * bsxfun(@times, (m*pi/c).^2, tau));
P3 = 2 * cos(m*pi*z0/c) .* cos(m*pi*z0/c);
S3 = sum(bsxfun(@times, P3, Ez), 1);

% Contract the transverse modes into the time-integration weights.
Wt = w .* (1 + S2) .* (1 + S3);

% Integrate each nonzero x mode against the transverse kernel.
Ex = exp(-(Kx/Ss) * bsxfun(@times, (m*pi/a).^2, tau));
G  = sum(bsxfun(@times, Ex, Wt), 2);

% Factor the x kernel into observation and source-segment terms.
A1 = -2 * sin(wellx' * (m.' * pi/a));
xb = xw_b + (0:Nk-1) * dx;
xe = xb + dx;
mr = m.' * pi/a;
B1 = bsxfun(@rdivide, cos(xe' * mr) - cos(xb' * mr), mr);

% Assemble all segment interactions by matrix multiplication. Dividing by dx
% converts the integrated line-source kernel to a response per segment total.
F = bsxfun(@times, A1, G.') * B1.' / (Ss * a * b * c);
F = F / dx;
end
