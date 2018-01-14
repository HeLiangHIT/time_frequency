/**
   To compile, run from matlab:  mex diff_mex.c

---------------------------------------------------------------------------------
    Synchrosqueezing Toolbox
    Authors: Eugene Brevdo (http://www.math.princeton.edu/~ebrevdo/),
             Hau-Tieng Wu
---------------------------------------------------------------------------------
 */
#include <math.h>
#include "mex.h"
#include "matrix.h"

/**
   dW = diff_mex(W, dt, dorder)
**/
void mexFunction(int nlhs, mxArray *plhs[], 
		 int nrhs, const mxArray *prhs[])
{
  size_t ai, bi, k, N, na;
  double dt;
  int dorder;
  double *Wr, *Wi, *dWr, *dWi;

  na = mxGetM(prhs[0]);
  N = mxGetN(prhs[0]);

  Wr = mxGetPr(prhs[0]);
  Wi = mxGetPi(prhs[0]);
  dt = mxGetScalar(prhs[1]);
  dorder = (int)mxGetScalar(prhs[2]);

  if (Wi != NULL)
    plhs[0] = mxCreateDoubleMatrix(na, N, mxCOMPLEX);
  else
    plhs[0] = mxCreateDoubleMatrix(na, N, mxREAL);
    
  if (plhs[0] == NULL)
    mexErrMsgTxt("Error allocating output matrix Tx");

  dWr = mxGetPr(plhs[0]);
  if (Wi != NULL)
    dWi = mxGetPi(plhs[0]);

  /* Take derivatives of a certain order, in the column direction */
  if (dorder == 1) /* 1st order Forward Difference */
    for (bi = 0; bi < N-1; ++bi) {
      for (ai = 0; ai < na; ++ai) {
	dWr[na*bi+ai] = (Wr[na*(bi+1)+ai] - Wr[na*(bi)+ai])/dt;
	if (Wi != NULL)
	  dWi[na*bi+ai] = (Wi[na*(bi+1)+ai] - Wi[na*(bi)+ai])/dt;
      }
    }
  else if (dorder == 2) /* 2nd order Forward Difference */
    for (bi = 0; bi < N-2; ++bi)
      for (ai = 0; ai < na; ++ai) {
	dWr[na*bi+ai] = (4*Wr[na*(bi+1)+ai] - Wr[na*(bi+2)+ai] - 3*Wr[na*bi+ai])/(2*dt);
	if (Wi != NULL)
	  dWi[na*bi+ai] = (4*Wi[na*(bi+1)+ai] - Wi[na*(bi+2)+ai] - 3*Wi[na*bi+ai])/(2*dt);
      }
  else if (dorder == 4) /* 4th order Central Difference */
    for (bi = 2; bi < N-2; ++bi)
      for (ai = 0; ai < na; ++ai) {
	dWr[na*bi+ai] = (-Wr[na*(bi+2)+ai] + 8*Wr[na*(bi+1)+ai]
			 -8*Wr[na*(bi-1)+ai] + Wr[na*(bi-2)+ai])/(12*dt);
	if (Wi != NULL)
	  dWi[na*bi+ai] = (-Wi[na*(bi+2)+ai] + 8*Wi[na*(bi+1)+ai]
			   -8*Wi[na*(bi-1)+ai] + Wi[na*(bi-2)+ai])/(12*dt);
      }
  else
    mexErrMsgTxt("Unknown dorder");
}
