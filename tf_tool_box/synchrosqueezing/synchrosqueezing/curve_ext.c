#include <math.h>
#include "mex.h"

/**
See curve_ext.m for help on using this MEX code.

Original Author: Jianfeng Lu (now at NYU CIMS)
Maintainer: Eugene Brevdo

--------------------------------------------------------------------------------
    Synchrosqueezing Toolbox
    Authors: Eugene Brevdo (http://www.math.princeton.edu/~ebrevdo/),
             Hau-Tieng Wu,
---------------------------------------------------------------------------------
 */

/**
   Calculate distance between frequencies on frequency scale
   given by vector fs
 **/
double fdist(double* fs, int i, int j) {
  return (fs[i]-fs[j])*(fs[i]-fs[j]);
}


/**
   Extract a maximum energy, minimum curvature curve from
   Synchrosqueezed Representation.  Note, energy is given as:
     abs(Tx).^2

   Original Author: Jianfeng Lu (now at NYU CIMS)
   Current Version: Eugene Brevdo

   Usage:
     [C,E] = curve_ext(Tx, log2(fs), lambda);

   lambda should be >=0.  Default: lambda=0
 **/

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){
  double *Txr, *Txi, *fs;
  int N,na;
  double lambda;

  int *Freq;
  double *FreqOut;
  double *EnergyOut;
  double *FValOut;
  double *Energy, *FVal;
  double minval, val;
 
  int i,j,k;

  const double eps = 1e-8;
  double sum = 0;

  /* Portal to matlab */
  Txr = mxGetPr(prhs[0]);
  Txi = mxGetPi(prhs[0]);
  na = mxGetM(prhs[0]);
  N = mxGetN(prhs[0]);

  /* Get frequencies */
  fs = mxGetPr(prhs[1]);

  lambda = mxGetScalar(prhs[2]);

  plhs[0] = mxCreateNumericArray(1,&N,mxDOUBLE_CLASS,mxREAL);
  plhs[1] = mxCreateNumericMatrix(1,1,mxDOUBLE_CLASS,mxREAL);
  FreqOut = mxGetPr(plhs[0]);
  EnergyOut = mxGetPr(plhs[1]);
  
  
  Energy = (double *)mxMalloc(sizeof(double)*N*na);
  FVal = (double *)mxMalloc(sizeof(double)*N*na);
  Freq = (int *)mxMalloc(sizeof(int)*N);

  /**
     Calculate in terms of energy - more numerically stable
  **/
  for (i=0;i<N;++i) {
    for (j=0;j<na;++j) {
      if (Txr != NULL)
	Energy[i*na+j] = Txr[i*na+j]*Txr[i*na+j];
      if (Txi != NULL)
	Energy[i*na+j] += Txi[i*na+j]*Txi[i*na+j];

      sum += Energy[i*na+j];
    }
  }

  for (i=0;i<N;++i)
    for (j=0;j<na;++j)
      Energy[i*na+j] = -log(Energy[i*na+j]/sum+eps);

  /**
     Simple first order dynamic program: find minimum energy to
     traverse from frequency bin j at time i to frequency bin k at
     time i+1, where the energy cost is proportional to
     lambda*dist(j,k)
   **/
  for (j=0;j<na;++j)
    FVal[j] = Energy[j];

  for (i=1;i<N;++i){
    for (j=0;j<na;++j)
      FVal[i*na+j] = mxGetInf(); /* INFINITY; */

    for (j=0;j<na;++j){
      for (k=0;k<na;++k)
        if (FVal[i*na+j] > FVal[(i-1)*na+k]+lambda*fdist(fs, j, k))
	  FVal[i*na+j] = FVal[(i-1)*na+k]+lambda*fdist(fs, j, k);

      FVal[i*na+j] += Energy[i*na+j];
    }
  }

  /**
     Find the locations for the minimum values of our energy
     functional at each time location i.  Store in freq.
   **/
  minval = FVal[(N-1)*na];
  for (i=1;i<N;++i)
    Freq[i] = -1;

  Freq[N-1] = 0;
  for (j=1;j<na;++j) {
    if (FVal[(N-1)*na+j]<minval) {
      minval = FVal[(N-1)*na+j];
      Freq[N-1] = j;
    }
  }

  /**
     Back out from the end time N-1, calculating the indices of the
     minimum negative-log-energy curve while we're at it.
   **/
  for (i=N-2;i>=0;--i){
    if (Freq[i+1] == -1)
      continue;
    
    val = FVal[(i+1)*na+Freq[i+1]] - Energy[(i+1)*na+Freq[i+1]];
    for (j=0;j<na;++j)
      if (fabs((val-FVal[i*na+j]) - lambda*fdist(fs, j, Freq[i+1]))<eps) {
        Freq[i] = j;
        break;
      }
  }
          
  for (i=0;i<N;++i)
    FreqOut[i] = (double)Freq[i]+1.;

  *EnergyOut = FVal[(N-1)*na + Freq[N-1]];

  mxFree(Freq);
  mxFree(Energy);
  mxFree(FVal);
}

