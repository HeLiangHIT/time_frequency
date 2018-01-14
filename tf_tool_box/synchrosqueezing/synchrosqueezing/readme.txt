Synchrosqueezing Toolbox v1.1
Authors: Eugene Brevdo (http://www.math.princeton.edu/~ebrevdo/)

If you use this code in your research, please include the citations to papers
[2,3] below.

Acknowledgements
------------------

Hau-tieng Wu and Ingrid Daubechies were instrumental in the creation
of the underlying ideas behind the Synchrosqueezing transform code in
this toolbox.

The file curve_ext.c was authored by Jianfeng Lu (now at NYU CIMS).


Introduction
--------------

This toolbox implements several time-frequency and time-scale analysis
methods, as described in [1,2,3].  These include:

1. Forward and inverse Discrete Wavelet Transform (a discretization
   of the continuous wavelet transform, so we will call it cwt).
2. Forward and inverse Wavelet-based Synchrosqueezing (synsq_cwt).
3. Various plotting and curve extraction utilities to go with
   cwt and synsq_cwt.
4. A GUI (the Synchrosqueezing GUI) for analysis, filtering,
   denoising, and signal extraction.  This allows the simple, fast,
   initial analysis via Synchrosqueezing.

Installation
-------------

0. You will need the MATLAB Image Processing toolbox for some of the
   GUI filtering tools used by gsynsq (see basic command reference
   below).

1. Put the contents of the synchrosqueezing toolbox somewhere (say,
   $HOME/matlab/).

2. Add the new directories to your path permanently; e.g., add the
   following to your startup.m:
     addpath ~/matlab/synchrosqueezing;
     addpath ~/matlab/util;

3. Go into the new directory and compile the necessary .mex files:
     cd ~/matlab/synchrosqueezing;
     compile_synsq;

Basic command reference
------------------------

gsynsq: The synchrosqueezing GUI.  Run it without any parameters and
use the menu items and keyboard shortcuts to analyze signals.  To
import time/signal vectors from your workspace, use file->import
(control+I).  To export analysis output when done, use file->export
(control+E).  This GUI calls, and provides examples for using, many of the
functions described below.

cwt_fw, cwt_iw: wavelet forward/inverse transform

dft_fw: discrete fourier series

synsq_cwt_fw, synsq_cwt_iw: wavelet-based synchrosqueezing
  forward/inverse transform.

est_riskshrink_thresh: RiskShrink threshold estimator
  for denoising signals.

tplot, tplot_power: plotting of output of cwt and synsq_cwt
  transforms.

curve_ext_*: curve extraction from output of synsq_cwt
plot_ext_curves*: associated plotting functions

synsq_filter_pass: frequency-region filtering in synchrosqueezing
domain.

References
-------------
1. Mallat, S., Wavelet Tour of Signal Processing 3rd ed.

2. E. Brevdo, N.S. Fučkar, G. Thakur, and H-T. Wu, "The
Synchrosqueezing algorithm: a robust analysis tool for signals
with time-varying spectrum," 2011.

3. I. Daubechies, J. Lu, H.T. Wu, "Synchrosqueezed Wavelet Transforms: a
tool for empirical mode decomposition", 2010.
