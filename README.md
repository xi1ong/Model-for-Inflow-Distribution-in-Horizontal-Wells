# Model for Inflow Distribution in Horizontal Wells

MATLAB utilities for the aquifer-side calculations used by the horizontal-well
inflow-distribution study.

## Requirements

- MATLAB
- PowerPoint and `pdfcrop` are additionally required only for
  `code/build_conceptual_model.m`

## Scope

This repository revision intentionally excludes the MTBC solvers and the
dependent main simulation and verification scripts. The removed components are
not part of this downloadable source set.

## Included Source

- `code/compute_F_matrix.m`: transient aquifer influence matrix
- `code/gauss_legendre.m`: Gauss-Legendre nodes and weights
- `code/hw_params.m`: baseline domain and fluid parameters
- `code/build_conceptual_model.m`: optional conceptual-figure assembly

The source directory also contains the original conceptual-figure helper. Its
PowerPoint and generated figure inputs remain local and are excluded from Git.

No MTBC solver or generated numerical result is included in this revision.
