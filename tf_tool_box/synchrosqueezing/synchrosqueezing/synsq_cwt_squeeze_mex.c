/**
   To compile, run from matlab:  mex synsq_cwt_squeeze_mex.c

   This function is only to be used from synsq_cwt_squeeze()

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
   Tx = synsq_cwt_squeeze_mex(Wx, w, as, fs, dfs, lfm, lfM);
**/
void mexFunction(int nlhs, mxArray *plhs[], 
		 int nrhs, const mxArray *prhs[])
{
  /**
   MATLAB equivalent code:

   for b=1:N
       for ai=1:length(as)
            if (mxIsFinite(w(ai, b)) && (w(ai,b)>0))
                % Find w_l nearest to w(a_i,b)
                %  2.^(lfm + k*(lfM-lfm)/na) ~= w(a_i,b)
                k = 1 + floor(na/(lfM-lfm)*(log2(w(ai,b))-lfm));
                if mxIsFinite(k) && k>0 && k<=na
                    % Tx(k,b) = Tx(k, b) + fs(k)/dfs(k) * Wx(ai, b) * as(ai)^(-1/2);
                    Tx(k,b) = Tx(k, b) + Wx(ai, b) * as(ai)^(-1/2);
                end
            end
        end % for ai...
     end % for b
  **/
  size_t ai, bi, k, N, na;
  double lfM, lfm, eps;
  double *w, *Wxr, *Wxi, *as, *fs, *dfs, *Txr, *Txi;
  double *dfsinv, *asrtinv, *Txbr, *Txbi, *Wxbr, *Wxbi, *wab;

  na = mxGetM(prhs[0]);
  N = mxGetN(prhs[0]);

  Wxr = mxGetPr(prhs[0]);
  Wxi = mxGetPi(prhs[0]);
  w = mxGetPr(prhs[1]);
  as = mxGetPr(prhs[2]);
  fs = mxGetPr(prhs[3]);
  dfs = mxGetPr(prhs[4]);
  lfm = mxGetScalar(prhs[5]);
  lfM = mxGetScalar(prhs[6]);

  dfsinv = mxCalloc(na, sizeof(double));
  asrtinv = mxCalloc(na, sizeof(double));
  Txbr = mxCalloc(na, sizeof(double));
  Txbi = mxCalloc(na, sizeof(double));
  Wxbr = mxCalloc(na, sizeof(double));
  Wxbi = mxCalloc(na, sizeof(double));
  wab = mxCalloc(na, sizeof(double));

  eps = 0.00000001f;

  for (ai = 0; ai < na; ++ai) {
    dfsinv[ai] = 1/dfs[ai];
    asrtinv[ai] = 1/sqrt(as[ai]);
  }

  plhs[0] = mxCreateDoubleMatrix(na, N, mxCOMPLEX);
  if (plhs[0] == NULL)
    mexErrMsgTxt("Error allocating output matrix Tx");

  Txr = mxGetPr(plhs[0]);
  Txi = mxGetPi(plhs[0]);

  for (bi = 0; bi < N; ++bi) {
    /* Copy Wx into a temporary vector */
    for (ai = 0; ai < na; ++ai) {
      Wxbr[ai] = Wxr[na*bi+ai];
      Wxbi[ai] = Wxi[na*bi+ai];
      Txbr[ai] = 0;
      Txbi[ai] = 0;
      wab[ai] = w[na*bi + ai];
    }

    for (ai = 0; ai < na; ++ai) {
      if (!(mxIsFinite(wab[ai]) && wab[ai]>0))
	continue;

      /* Round to nearest integer */
      k = (size_t)(floor(0.5f + ((double)(na-1))/(lfM-lfm)*(log2(wab[ai])-lfm)));
      /* k = (size_t)(round(((double)(na-1))/(lfM-lfm)*(log2(wab[ai])-lfm))); */
      
      if (mxIsFinite(k) && k>=0 && k<na) {
	Txbr[k] = Txbr[k] + (Wxbr[ai] * asrtinv[ai] * dfsinv[k]);
	Txbi[k] = Txbi[k] + (Wxbi[ai] * asrtinv[ai] * dfsinv[k]);
	/**
	   Txbr[k] = Txbr[k] + (fs[k] * dfsinv[k] * Wxbr[ai] * asrtinv[ai]);
	   Txbi[k] = Txbi[k] + (fs[k] * dfsinv[k] * Wxbi[ai] * asrtinv[ai]);
	**/
      }
    }

    for (ai = 0; ai < na; ++ai) {
      Txr[na*bi + ai] = Txbr[ai];
      Txi[na*bi + ai] = Txbi[ai];
    }
  }

  mxFree(dfsinv);
  mxFree(asrtinv);
  mxFree(Txbr); mxFree(Txbi);
  mxFree(Wxbr); mxFree(Wxbi);
  mxFree(wab);
}
