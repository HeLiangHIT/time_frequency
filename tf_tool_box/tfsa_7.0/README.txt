********************
USER AGREEMENT
********************
Acknowledgements of this TFSA software package is required in all
publications arising from its use.  

B. Boashash, TFSA Package, "Time-Frequency Signal Analysis Package", 
The University of Queensland, UQ Centre for Clinical Research, 2010


********************
ABOUT TFSA
********************

TFSA, originally created for use on PC's with MS-DOS, has been
rewritten to operate on both Unix and MS-Windows operating systems
running MATLAB.

The current version can be used as a Matlab toolbox - The full
functionality of the C functions is made available inside Matlab, by
providing Matlab MEX file interfaces and supporting Matlab M files.
The Matlab interface is further enhanced by a Graphical User Interface
to TFSA.  Matlab code is fully portable, and can be run on any
computer with Matlab (but not with the student edition of Matlab).
The TFSA Matlab interface has been carefully designed to ensure
maximum productivity and seamless integration with existing Matlab
functionality.

The current release of TFSA supports the following functions:
1. Generation of test signals;
2. Generation of bilinear time-frequency distributions:
	a) Wigner-Ville Distribution;
        b) Smoothed Wigner-Ville Distribution;
        c) Rihaczek-Margenau Distribution;
        d) Choi-Williams Distribution;
        e) Cross Wigner-Ville Distribution;
        f) Short Time Fourier Transform;
        g) Born-Jordan-Cohen Distribution;
        h) Zhao-Atlas-Marks Distribution;
        i) Polynomial Wigner-Ville Distributions;
        j) Ambiguity function;
        k) B and Modified-B Distributions;
	l) Extended Modified-B Distributions.
3. Generation of time-frequency distributions based on:
	a) Compact Support Kernel
	b) Extended-Compact Support Kernel
3. Generation of multilinear time-frequency distributions:
	a) Polynomial WVD of order 4;
	b) Polynomial WVD of order 6.
4. Instantaneous frequency estimation methods:
	a) Finite phase difference;
	b) Weighted phase difference;
	c) Zero crossing;
	d) Mean squares adaptive methods;
	e) LS polynomial coefficients;
	f) Peak of spectrogram;
	h) Peak of WVD;
	i) Peak of polynomial WVD.
5. Time-frequency distribution signal synthesis methods:
	a) Short-time Fourier transform;
	b) Modified short-time Fourier transform;
	c) Modified spectrogram;
	d) Wigner-Ville distribution.
6. Generation of time-scale signal representations:
	a) Daubechies 4, 12 and 20 coefficient wavelet transforms.
7. Time-frequency plotting routines.



********************
LICENSE AGREEMENT
********************

The SPRC (Signal Processing Research Concentration at the The
University of Queensland Centre for Clinical Research) grants you the
right to install and use the enclosed software programs on a single
computer.  You may copy the software into any machine readable form
for backup or archival purposes in support of your use of the Software
on the single computer.  Plain text parts of the package may be
customised for personal use, provided that any references to the
authors and the copyright notices of the package are not removed. You
may transfer the Software and license agreement to another party if
the other party agrees to accept the terms and conditions of the
Agreement, and if the Software remains unmodified by you.  If you
transfer the Software, you must at the same time transfer all copies
of the same and accompanying documentation, or destroy any copies not
transfered.  YOU WILL NOT: 1. Sublicense the Software; 2. Copy or
transfer the Software in whole or in part, except as expressly
provided for in the wording above; 3. Incorporate the Software in
whole or in part into any commercial product.

Although considerable effort has been expended to make the programs in
TFSA correct and reliable, we make no warranties, express or implied,
that the programs contained in this package are free of error, or are
consistent with any particular standard of merchantability, or that
they will meet your requirements for any particular application.  They
should not be relied on for solving a problem whose incorrect solution
could result in injury to a person or loss of property.  If you do use
the programs in such a manner, it is at your own risk.  The authors
disclaim all liability for direct or consequential damages resulting
from your use of this package.

MATLAB is a trademark of The MathWorks, Inc.

UNIX is a trademark of American Telephone and Telegraph Company.

MS-DOS and MS-Windows are trademarks of Microsoft Corporation.


Acknowledgements of this TFSA software package is required in all
publications arising from its use.  

B. Boashash, TFSA Package, "Time-Frequency Signal Analysis Package", 
The University of Queensland, UQ Centre for Clinical Research, 2010


********************
Support Policy
********************
It is the intent of the SPRC to continue to update TFSA to reflect new
ideas and algorithms, and to correct bugs which may be discovered.
Bug reports are welcome, and should contain sufficient information to
reliably reproduce the aberrant behaviour.  Telephone support is not
available at present.  Suggested fixes or workarounds are welcome.
Our address for matters concerning the TFSA package is:

Prof. B. Boashash
Signal Processing Research Concentration, 
The University of Queensland Centre for Clinical Research,
Building 71/918, 
Royal Brisbane and Women's Hospital,
Herston, QLD 4029, 
Australia


For technical support the preferred means of communication is by
e-mail.  Please send emails to:

j.otoole@ieee.org


********************
SYSTEM REQUIREMENTS
********************

A Linux or MS-Windows computer system is required, running Matlab 7.5 
(R2007b) or higher.  Licensing information for Matlab is available from
The Mathworks, Inc.


*************
INSTALLATION 
*************

The distribution for MS-Windows and Linux (kernel 2.6 and higher) is pre-compiled.  To
install the distribution, just copy all the files on the distribution disks into the
desired directory.  Then edit Matlab's search path to include this directory. For
information on editing Matlab's search path, refer to your Matlab User's Guide.

+ For the Linux 32-bit version use the directory:  

  linux/glnx86_bin

+ For the Linux 64-bit version use the directory: 

  linux/glnxa64_bin

+ For the Windows 32-bit version use the directory: 

  windows\win32_bin

+ For the Windows 64-bit version use the directory: 

  windows\win64_bin

Place the files in an appropriate directory and then update your Matlab path.


********************
BASIC REFERENCE
********************

B. Boashash, editor. "Time-Frequency Signal Analysis and Processing: A
Comprehensive Reference", Elsevier, 2004.

B. Boashash, editor. "Time-Frequency Signal Analysis: Methods and
Applications", Longman Cheshire, 1992.

B. Boashash, "Estimating and Interpreting The Instantaneous Frequency 
of a Signal - Part 1: Fundamentals", Proceedings of the IEEE, 
vol. 80(4), pages 519-538, 1992.

B. Boashash, "Estimating and Interpreting the Instantaneous Frequency 
of a Signal - Part 2: Algorithms and Applications", Proceedings of the IEEE, 
vol. 80(4), pages 539-568, 1992.



