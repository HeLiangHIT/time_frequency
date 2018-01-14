% TFSA PLOTTING FACILITIES
%
% Plotting routines used to visualise data. The following types of
% graphs can be employed:
%
%  (i)   Plot
%  (ii)  Image
%  (iii) Pseudo-Colour
%  (iv)  Waterfall (1 and 2)
%  (v)   Mesh
%  (vi)  Surf
%  (vii) Contour
%  (viii)TFSAPL
%
% All plots except (i) can be used to plot time-frequency
% distributions. The time domain and frequency spectra one
% dimensional plots can be added to the figure along the two axes.
% The plots can be configured by specifying various options in the
% figure. The 'Expand' button can be used to reveal more options. On
% the actual plot figure the appearance of the plots can be altered
% from a popup menu which is activated by right clicking.
%  
% EXPLANATION OF VARIOUS PLOTTING ROUTINES
%
%  (i) Plot
%      
%      Used for one dimensional plots of signals, IF estimation,
%      wavelet coefficients, frequency spectra etc.
%
%  (ii) Image
%
%      Used to plot two dimensional matrices such as time-frequency
%      distributions and scalograms. Displays the matrix as an image.
%
%  (iii) Pseudo-Colour
%
%      Pseudo-colour plots a colour grid for each element of the input
%      matrix. Also used to plot two dimensional matrices such as
%      time-frequency distributions and scalograms.
%
%  (iv) Waterfall 1 and 2
%
%      Again also used to plot two dimensional matrices such as
%      time-frequency distributions and scalograms. This uses a
%      waterfall style plot of the matrix, using different viewing
%      angles which distinguish Waterfall 1 and Waterfall 2.
%
%  (v) Mesh
%   
%      Same as the waterfall plots except that column lines are
%      drawn to produce a 'mesh' surface.
%
%  (vi) Surf
%
%      Equivalent to the mesh plot except that a 'surface' is now
%      defined over the mesh.
%
%  (vii) Contour
%
%      Contour plot of the two dimensional matrix where the
%      different coloured lines represent varying degrees of magnitudes.
%
%  (viii) TFSAL
%
%      TFSA graphing function specifically optimised for viewing
%      time-frequency distributions.
%
%
%
%
%  See Also:  tfsapl



