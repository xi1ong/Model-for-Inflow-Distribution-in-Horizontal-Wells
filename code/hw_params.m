function P = hw_params()
%HW_PARAMS Define the baseline synthetic horizontal-well case.
% Hydraulic quantities use metres and days; fluid properties are converted
% consistently to the same daily time basis.
% Aquifer hydraulic properties.
P.Kx = 10;   P.Ky = 10;   P.Kz = 10;
P.Ss = 1e-3;
% Rectangular domain dimensions: x faces are constant-head boundaries,
% while the y and z faces are impermeable.
P.a  = 2000; P.b = 2000; P.c = 200;
% Coordinates of the well centre within the aquifer.
P.x0 = 1000; P.y0 = 1000; P.z0 = 100;
% Well geometry, pumping rate, and reference toe diameter.
P.L  = 300;
P.Q  = 3000;
P.D_toe = 0.15;
% Water density and dynamic viscosity in kg, metres, and days.
P.Ro = 1000;
P.Mu = 87.3;
% Spectral truncation order and temporal quadrature resolution.
P.N  = 2000;
P.nd = 2000;
end
