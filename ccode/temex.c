/* Level-2 c-mex S function interface for the TE problem.
 * Copyright: N. L. Ricker, 12/98.  ricker@u.washington.edu
 */

/* Number continuous states = 50
 * Number of inputs = 12
 * Number of outputs = 41
 * Number of parameters = 2

 * Parameters are:
 * 1  Vector of 52 initial states.  If empty, defaults are used.
 * 2  Vector of 20 disturbance codes (IDV).  If empty, all disturbances 
 * are "off."
 */

#define S_FUNCTION_NAME  temex
#define S_FUNCTION_LEVEL 2

/* #define MATLAB_MEX_FILE (removed for Release 12)*/

#include "math.h"
#include "simstruc.h"
#include "teprob.h"
 
const int NX = 50;
const int NU = 12;
const int NY = 41;
const int NPAR = 2;

/* Common Block Declarations */

static struct {
    doublereal xmeas[41], xmv[12];
} pv_;


static struct {
    integer idv[21];
} dvec_;

static struct {
	doublereal g;
} randsd_;

static struct {
	doublereal avp[8], bvp[8], cvp[8], ah[8], bh[8], ch[8], ag[8], bg[8], 
		cg[8], av[8], ad[8], bd[8], cd[8], xmw[8];
} const_;

static struct {
	doublereal uclr[8], ucvr[8], utlr, utvr, xlr[8], xvr[8], etr, esr, 
		tcr, tkr, dlr, vlr, vvr, vtr, ptr, ppr[8], crxr[8], rr[4], rh,
		 fwr, twr, qur, hwr, uar, ucls[8], ucvs[8], utls, utvs, xls[8]
		, xvs[8], ets, ess, tcs, tks, dls, vls, vvs, vts, pts, pps[8],
		 fws, tws, qus, hws, uclc[8], utlc, xlc[8], etc, esc, tcc, 
		dlc, vlc, vtc, quc, ucvv[8], utvv, xvv[8], etv, esv, tcv, tkv,
		 vtv, ptv, vcv[12], vrng[12], vtau[12], ftm[13], fcm[104]	
		/* was [8][13] */, xst[104]	/* was [8][13] */, xmws[13], 
		hst[13], tst[13], sfr[8], cpflmx, cpprmx, cpdh, tcwr, tcws, 
		htr[3], agsp, xdel[41], xns[41], tgas, tprod, vst[12];
	integer ivst[12];
} teproc_;

static struct {
	doublereal adist[12], bdist[12], cdist[12], ddist[12], tlast[12], 
		tnext[12], hspan[12], hzero[12], sspan[12], szero[12], spspan[
		12];
	integer idvwlk[12];
	doublereal rdumm;
} wlk_;

/* Table of constant values */

const integer c__50 = 50;
const integer c__12 = 12;
const integer c__21 = 21;
const integer c__153 = 153;
const integer c__586 = 586;
const integer c__139 = 139;
const integer c__6 = 6;
const integer c__1 = 1;
const integer c__0 = 0;
const integer c__41 = 41;
const integer c__2 = 2;
const integer c__3 = 3;
const integer c__4 = 4;
const integer c__5 = 5;
const integer c__7 = 7;
const integer c__8 = 8;
const doublereal c_b73 = 1.1544;
const doublereal c_b74 = .3735;
const integer c__9 = 9;
const integer c__10 = 10;
const integer c__11 = 11;
const doublereal c_b123 = 4294967296.;

static char msg[256];  /* For error messages*/
static integer code_sd;

/*====================================================================*
 * Parameter handling methods. These methods are not supported by RTW *
 *====================================================================*/

#define MDL_CHECK_PARAMETERS   /* Change to #undef to remove function */
#if defined(MDL_CHECK_PARAMETERS) && defined(MATLAB_MEX_FILE)

static void mdlCheckParameters(SimStruct *S)
  {
	/* Declarations*/
	int_T Plen[2];         /* Expected lengths*/
	int_T i, nEls;

	/* Start*/
	Plen[0] = NX;
	Plen[1] = 20;
	for (i=0; i<NPAR; i++) {
		if (mxIsEmpty(ssGetSFcnParam(S,i)))
			continue;
		if (mxIsSparse(ssGetSFcnParam(S,i)) ||
			mxIsComplex(ssGetSFcnParam(S,i)) ||
			!mxIsNumeric(ssGetSFcnParam(S,i))) {
			sprintf(msg,"Error in parameter %i:  %s",i+1,
				"Parameter must be a real, non-sparse vector.");
			ssSetErrorStatus(S,msg);
			return;
		}
		nEls = mxGetNumberOfElements(ssGetSFcnParam(S,i));
		if (nEls != Plen[i]) {
			sprintf(msg,"Error in parameter %i:  Length = %i"
				".  Expecting length = %i", i+1, nEls, Plen[i]);
			ssSetErrorStatus(S,msg);
			return;
		}
	}
  }
#endif /* MDL_CHECK_PARAMETERS */


/*=====================================*
 * Configuration and execution methods *
 *=====================================*/

/* Function: mdlInitializeSizes ===============================================
 * Abstract:
 *    The sizes information is used by Simulink to determine the S-function
 *    block's characteristics (number of inputs, outputs, states, etc.).
 *
 *    The direct feedthrough flag can be either 1=yes or 0=no. It should be
 *    set to 1 if the input, "u", is used in the mdlOutput function. Setting
 *    this to 0 is akin to making a promise that "u" will not be used in the
 *    mdlOutput function. If you break the promise, then unpredictable results
 *    will occur.
 *
 *    The NumContStates, NumDiscStates, NumInputs, NumOutputs, NumRWork,
 *    NumIWork, NumPWork NumModes, and NumNonsampledZCs widths can be set to:
 *       DYNAMICALLY_SIZED    - In this case, they will be set to the actual
 *                              input width, unless you are have a
 *                              mdlSetWorkWidths to set the widths.
 *       0 or positive number - This explicitly sets item to the specified
 *                              value.
 */
static void mdlInitializeSizes(SimStruct *S)
{
    ssSetNumSFcnParams(S, 2);  /* Number of expected parameters */
    if (ssGetNumSFcnParams(S) == ssGetSFcnParamsCount(S)) {
		mdlCheckParameters(S);
		if (ssGetErrorStatus(S) != NULL) return;
	}
	else {
			return;     /*Simulink will report a parameter mismatch error */
	}

    ssSetNumContStates(    S, NX);   /* number of continuous states           */
    ssSetNumDiscStates(    S, 0);   /* number of discrete states             */


    /*
     * Configure the input ports. First set the number of input ports,
     * then set for each input port index starting at 0, the width
     * and whether or not the port has direct feedthrough (1=yes, 0=no).
     * The width of a port can be DYNAMICALLY_SIZED or greater than zero.
     * A port has direct feedthrough if the input is used in either
     * the mdlOutputs or mdlGetTimeOfNextVarHit functions.
     */
    if (!ssSetNumInputPorts(S, 1)) return;
    ssSetInputPortWidth(S, 0, NU);
    /*ssSetInputPortDirectFeedThrough(S, 0, 0);  (modified for Release 12)*/
    ssSetInputPortDirectFeedThrough(S, 0, 1);

    /*
     * Configure the output ports. First set the number of output ports,
     * then set for each output port index starting at 0, the width
     * of the output port which can be DYNAMICALLY_SIZE or greater than zero.
     */
    if (!ssSetNumOutputPorts(S, 1)) return;
    ssSetOutputPortWidth(S, 0, NY);

    /*
     * Set the number of sample times. This must be a positive, nonzero
     * integer indicating the number of sample times or it can be
     * PORT_BASED_SAMPLE_TIMES.*/
    ssSetNumSampleTimes(   S, 1);   /* number of sample times                */

    /*
     * Set size of the work vectors.
     */
    ssSetNumRWork(         S, 0);   /* number of real work vector elements   */
    ssSetNumIWork(         S, 0);   /* number of integer work vector elements*/
    ssSetNumPWork(         S, 0);   /* number of pointer work vector elements*/
    ssSetNumModes(         S, 0);   /* number of mode work vector elements   */
    ssSetNumNonsampledZCs( S, 0);   /* number of nonsampled zero crossings   */

	/* Set any S-function options which must be OR'd together.*/
    ssSetOptions(S, SS_OPTION_EXCEPTION_FREE_CODE);   /* general options (SS_OPTION_xx)        */

	/* Declare parameter 1 to be unchanging during a simulation.*/
	ssSetSFcnParamNotTunable(S, 0);

} /* end mdlInitializeSizes */





#undef MDL_SET_WORK_WIDTHS   /* Change to #undef to remove function */
#if defined(MDL_SET_WORK_WIDTHS) && defined(MATLAB_MEX_FILE)
  static void mdlSetWorkWidths(SimStruct *S)
  {
  }
#endif /* MDL_SET_WORK_WIDTHS */



#define MDL_INITIALIZE_CONDITIONS   /* Change to #undef to remove function */
#if defined(MDL_INITIALIZE_CONDITIONS)
  /* Function: mdlInitializeConditions ========================================
   * Abstract:
   *    In this function, you should initialize the continuous and discrete
   *    states for your S-function block.  The initial states are placed
   *    in the state vector, ssGetContStates(S) or ssGetDiscStates(S).
   *    You can also perform any other initialization activities that your
   *    S-function may require. Note, this routine will be called at the
   *    start of simulation and if it is present in an enabled subsystem
   *    configured to reset states, it will be call when the enabled subsystem
   *    restarts execution to reset the states.
   *
   *    You can use the ssIsFirstInitCond(S) macro to determine if this is
   *    is the first time mdlInitializeConditions is being called.
   */
static void mdlInitializeConditions(SimStruct *S)
  {
	  real_T *x0;      /* pointer to states*/
      real_T *pr;
	  int_T i, nx;
	  real_T dxdt[50];
	  real_T rt;

	  x0 = ssGetContStates(S);
	  nx = NX;
	  rt = 0;
	  if (ssIsFirstInitCond(S)) teinit(&nx, &rt, x0, dxdt);
	  /* If first parameter is non-empty, use it to initialize the state vector.
	  // If empty, use default values.*/
	  if (mxIsEmpty(ssGetSFcnParam(S,0))) {
		x0[0] = (float)10.40491389;
		x0[1] = (float)4.363996017;
		x0[2] = (float)7.570059737;
		x0[3] = (float).4230042431;
		x0[4] = (float)24.15513437;
		x0[5] = (float)2.942597645;
		x0[6] = (float)154.3770655;
		x0[7] = (float)159.186596;
		x0[8] = (float)2.808522723;
		x0[9] = (float)63.75581199;
		x0[10] = (float)26.74026066;
		x0[11] = (float)46.38532432;
		x0[12] = (float).2464521543;
		x0[13] = (float)15.20484404;
		x0[14] = (float)1.852266172;
		x0[15] = (float)52.44639459;
		x0[16] = (float)41.20394008;
		x0[17] = (float).569931776;
		x0[18] = (float).4306056376;
		x0[19] = .0079906200783;
		x0[20] = (float).9056036089;
		x0[21] = .016054258216;
		x0[22] = (float).7509759687;
		x0[23] = .088582855955;
		x0[24] = (float)48.27726193;
		x0[25] = (float)39.38459028;
		x0[26] = (float).3755297257;
		x0[27] = (float)107.7562698;
		x0[28] = (float)29.77250546;
		x0[29] = (float)88.32481135;
		x0[30] = (float)23.03929507;
		x0[31] = (float)62.85848794;
		x0[32] = (float)5.546318688;
		x0[33] = (float)11.92244772;
		x0[34] = (float)5.555448243;
		x0[35] = (float).9218489762;
		x0[36] = (float)94.59927549;
		x0[37] = (float)77.29698353;
		x0[38] = (float)63.05263039;
		x0[39] = (float)53.97970677;
		x0[40] = (float)24.64355755;
		x0[41] = (float)61.30192144;
		x0[42] = (float)22.21;
		x0[43] = (float)40.06374673;
		x0[44] = (float)38.1003437;
		x0[45] = (float)46.53415582;
		x0[46] = (float)47.44573456;
		x0[47] = (float)41.10581288;
		x0[48] = (float)18.11349055;
		x0[49] = (float)50.;
	  } else {
	    pr = mxGetPr(ssGetSFcnParam(S,0));		/* pointer to first parameter*/
	    for (i=0; i<nx; i++) {
			x0[i] = pr[i];
		}
	  }
	  setidv(S);
	  dvec_.idv[20] = (integer) 0;
	  code_sd = (integer) 0;
  }
#endif /* MDL_INITIALIZE_CONDITIONS */



#undef MDL_START  /* Change to #undef to remove function */
#if defined(MDL_START)
static void mdlStart(SimStruct *S)
  {
  }
#endif /*  MDL_START */


/* Function: mdlInitializeSampleTimes =========================================
 * Abstract:
 *    This function is used to specify the sample time(s) for your
 *    S-function. You must register the same number of sample times as
 *    specified in ssSetNumSampleTimes.
 */
static void mdlInitializeSampleTimes(SimStruct *S)
{
    ssSetSampleTime(S, 0, CONTINUOUS_SAMPLE_TIME);
    ssSetOffsetTime(S, 0, 0.0);

}


/* Function: mdlOutputs =======================================================
 * Abstract:
 *    In this function, you compute the outputs of your S-function
 *    block. Generally outputs are placed in the output vector(s),
 *    ssGetOutputPortSignal.
 */
static void mdlOutputs(SimStruct *S, int_T tid)
{
	real_T *y;
	int i;
	doublereal rx[50];
	doublereal dx[50];
	doublereal rt;

	/* Get current time, states, and inputs*/
	rt = getcurr(rx, S);
	/* Call TEFUNC to update everything*/
	tefunc(&NX, &rt, rx, dx);
	/* Transfer the outputs to Simulink*/
	y = ssGetOutputPortRealSignal(S,0);
	for (i=0; i<NY; i++) {
		y[i] = pv_.xmeas[i];
	}
	/* Shut down the simulation if ISD is non-zero.*/
	if (dvec_.idv[20] != (integer) 0 && rt > (doublereal) 0.1 ) {
		code_sd = dvec_.idv[20];
		ssSetStopRequested(S,1);
	}
} /* end mdlOutputs */


#undef MDL_UPDATE  /* Change to #undef to remove function */
#if defined(MDL_UPDATE)
  /* Function: mdlUpdate ======================================================
   * Abstract:
   *    This function is called once for every major integration time step.
   *    Discrete states are typically updated here, but this function is useful
   *    for performing any tasks that should only take place once per
   *    integration step.
   */
static void mdlUpdate(SimStruct *S, int_T tid)
  {
  }
#endif /* MDL_UPDATE */



#define MDL_DERIVATIVES  /* Change to #undef to remove function */
#if defined(MDL_DERIVATIVES)
  /* Function: mdlDerivatives =================================================
   * Abstract:
   *    In this function, you compute the S-function block's derivatives.
   *    The derivatives are placed in the derivative vector, ssGetdX(S).
   */
static void mdlDerivatives(SimStruct *S)
  {
	doublereal x[50];
	doublereal *dx;
	doublereal rt;

	rt = getcurr(x, S);
	/* Call TEFUNC to update dx*/
	dx = ssGetdX(S);
	tefunc(&NX, &rt, x, dx);
  }
#endif /* MDL_DERIVATIVES */



/* Function: mdlTerminate =====================================================
 * Abstract:
 *    In this function, you should perform any actions that are necessary
 *    at the termination of a simulation.  For example, if memory was allocated
 *    in mdlStart, this is the place to free it.
 *
 *    Suppose your S-function allocates a few few chunks of memory in mdlStart
 *    and saves them in PWork. The following code fragment would free this
 *    memory.
 *        {
 *            int i;
 *            for (i = 0; i<ssGetNumPWork(S); i++) {
 *                if (ssGetPWorkValue(S,i) != NULL) {
 *                    free(ssGetPWorkValue(S,i));
 *                }
 *            }
 *        }
 */
static void mdlTerminate(SimStruct *S)
{
		if (code_sd != (integer) 0 ) {
			mexWarnMsgTxt(msg);
		}
}

/* GETCURR gets pointers to current states and inputs from Simulink.  
// Also moves current IDV values into the common block.
// Also moves current U values into common.*/

static doublereal getcurr(doublereal x[], SimStruct *S)
{
	int i;
	doublereal rt;
	real_T *xPtr;
	InputRealPtrsType uPtrs;

	rt = ssGetT(S);
	xPtr = ssGetContStates(S);
	uPtrs = ssGetInputPortRealSignalPtrs(S,0);
	setidv(S);
	for (i=0; i<NU; i++) {
		pv_.xmv[i] = *uPtrs[i];
	}
	for (i=0; i<NX; i++) {
		x[i] = xPtr[i];
	}
	return rt;
}
/* end GETCURR

// SETIDV moves current IDV parameters into the common block.*/

static void setidv(SimStruct *S)
{
	real_T *pr;
	int i;
	pr = mxGetPr(ssGetSFcnParam(S,1));		/* pointer to IDV in Simulink*/
	for (i=0; i<20; i++) {
		dvec_.idv[i] = (integer) pr[i];
	}
}
/* end SETIDV*/


/* ============================================================================= */

/* SUBROUTINE TEFUNC*/

static int tefunc(const integer *nn, doublereal *time, doublereal *yy, doublereal *yp)
{
    /* System generated locals */
    integer i__1;
    doublereal d__1;

    /* Local variables */
    doublereal flms, xcmp[41], hwlk, vpos[12], xmns, swlk;
    integer i__;
    doublereal spwlk, vovrl;
    doublereal rg, flcoef, pr, tmpfac, uarlev, r1f, r2f, uac, fin[8];
#define isd ((integer *)&dvec_ + 20)
    doublereal dlp, vpr, uas;

    /* Parameter adjustments */
    --yp;
    --yy;

    /* Function Body */
    for (i__ = 1; i__ <= 20; ++i__) {
	if (dvec_.idv[i__ - 1] > 0) {
	    dvec_.idv[i__ - 1] = 1;
	} else {
	    dvec_.idv[i__ - 1] = 0;
	}
/* L500: */
    }
    wlk_.idvwlk[0] = dvec_.idv[7];
    wlk_.idvwlk[1] = dvec_.idv[7];
    wlk_.idvwlk[2] = dvec_.idv[8];
    wlk_.idvwlk[3] = dvec_.idv[9];
    wlk_.idvwlk[4] = dvec_.idv[10];
    wlk_.idvwlk[5] = dvec_.idv[11];
    wlk_.idvwlk[6] = dvec_.idv[12];
    wlk_.idvwlk[7] = dvec_.idv[12];
    wlk_.idvwlk[8] = dvec_.idv[15];
    wlk_.idvwlk[9] = dvec_.idv[16];
    wlk_.idvwlk[10] = dvec_.idv[17];
    wlk_.idvwlk[11] = dvec_.idv[19];
    for (i__ = 1; i__ <= 9; ++i__) {
	if (*time >= wlk_.tnext[i__ - 1]) {
	    hwlk = wlk_.tnext[i__ - 1] - wlk_.tlast[i__ - 1];
	    swlk = wlk_.adist[i__ - 1] + hwlk * (wlk_.bdist[i__ - 1] + hwlk 
		    * (wlk_.cdist[i__ - 1] + hwlk * wlk_.ddist[i__ - 1]));
	    spwlk = wlk_.bdist[i__ - 1] + hwlk * (wlk_.cdist[i__ - 1] * 2. 
		    + hwlk * 3. * wlk_.ddist[i__ - 1]);
	    wlk_.tlast[i__ - 1] = wlk_.tnext[i__ - 1];
	    tesub5_(&swlk, &spwlk, &wlk_.adist[i__ - 1], &wlk_.bdist[i__ - 
		    1], &wlk_.cdist[i__ - 1], &wlk_.ddist[i__ - 1], &
		    wlk_.tlast[i__ - 1], &wlk_.tnext[i__ - 1], &wlk_.hspan[
		    i__ - 1], &wlk_.hzero[i__ - 1], &wlk_.sspan[i__ - 1], &
		    wlk_.szero[i__ - 1], &wlk_.spspan[i__ - 1], &
		    wlk_.idvwlk[i__ - 1]);
	}
/* L900: */
    }
    for (i__ = 10; i__ <= 12; ++i__) {
	if (*time >= wlk_.tnext[i__ - 1]) {
	    hwlk = wlk_.tnext[i__ - 1] - wlk_.tlast[i__ - 1];
	    swlk = wlk_.adist[i__ - 1] + hwlk * (wlk_.bdist[i__ - 1] + hwlk 
		    * (wlk_.cdist[i__ - 1] + hwlk * wlk_.ddist[i__ - 1]));
	    spwlk = wlk_.bdist[i__ - 1] + hwlk * (wlk_.cdist[i__ - 1] * 2. 
		    + hwlk * 3. * wlk_.ddist[i__ - 1]);
	    wlk_.tlast[i__ - 1] = wlk_.tnext[i__ - 1];
	    if (swlk > .1) {
		wlk_.adist[i__ - 1] = swlk;
		wlk_.bdist[i__ - 1] = spwlk;
		wlk_.cdist[i__ - 1] = -(swlk * 3. + spwlk * .2) / .01;
		wlk_.ddist[i__ - 1] = (swlk * 2. + spwlk * .1) / .001;
		wlk_.tnext[i__ - 1] = wlk_.tlast[i__ - 1] + .1;
	    } else {
		*isd = -1;
		hwlk = wlk_.hspan[i__ - 1] * tesub7_(isd) + wlk_.hzero[i__ 
			- 1];
		wlk_.adist[i__ - 1] = 0.;
		wlk_.bdist[i__ - 1] = 0.;
/* Computing 2nd power */
		d__1 = hwlk;
		wlk_.cdist[i__ - 1] = (doublereal) wlk_.idvwlk[i__ - 1] / (
			d__1 * d__1);
		wlk_.ddist[i__ - 1] = 0.;
		wlk_.tnext[i__ - 1] = wlk_.tlast[i__ - 1] + hwlk;
	    }
	}
/* L910: */
    }
    if (*time == 0.) {
	for (i__ = 1; i__ <= 12; ++i__) {
	    wlk_.adist[i__ - 1] = wlk_.szero[i__ - 1];
	    wlk_.bdist[i__ - 1] = 0.;
	    wlk_.cdist[i__ - 1] = 0.;
	    wlk_.ddist[i__ - 1] = 0.;
	    wlk_.tlast[i__ - 1] = 0.;
	    wlk_.tnext[i__ - 1] = .1;
/* L950: */
	}
    }
    teproc_.esr = teproc_.etr / teproc_.utlr;
    teproc_.xst[24] = tesub8_(&c__1, time) - dvec_.idv[0] * .03 - 
	    dvec_.idv[1] * .00243719;
    teproc_.xst[25] = tesub8_(&c__2, time) + dvec_.idv[1] * .005;
    teproc_.xst[26] = 1. - teproc_.xst[24] - teproc_.xst[25];
    teproc_.tst[0] = tesub8_(&c__3, time) + dvec_.idv[2] * 5.;
    teproc_.tst[3] = tesub8_(&c__4, time);
    teproc_.tcwr = tesub8_(&c__5, time) + dvec_.idv[3] * 5.;
    teproc_.tcws = tesub8_(&c__6, time) + dvec_.idv[4] * 5.;
    r1f = tesub8_(&c__7, time);
    r2f = tesub8_(&c__8, time);
    for (i__ = 1; i__ <= 3; ++i__) {
	teproc_.ucvr[i__ - 1] = yy[i__];
	teproc_.ucvs[i__ - 1] = yy[i__ + 9];
	teproc_.uclr[i__ - 1] = (float)0.;
	teproc_.ucls[i__ - 1] = (float)0.;
/* L1010: */
    }
    for (i__ = 4; i__ <= 8; ++i__) {
	teproc_.uclr[i__ - 1] = yy[i__];
	teproc_.ucls[i__ - 1] = yy[i__ + 9];
/* L1020: */
    }
    for (i__ = 1; i__ <= 8; ++i__) {
	teproc_.uclc[i__ - 1] = yy[i__ + 18];
	teproc_.ucvv[i__ - 1] = yy[i__ + 27];
/* L1030: */
    }
    teproc_.etr = yy[9];
    teproc_.ets = yy[18];
    teproc_.etc = yy[27];
    teproc_.etv = yy[36];
    teproc_.twr = yy[37];
    teproc_.tws = yy[38];
    for (i__ = 1; i__ <= 12; ++i__) {
	vpos[i__ - 1] = yy[i__ + 38];
/* L1035: */
    }
    teproc_.utlr = (float)0.;
    teproc_.utls = (float)0.;
    teproc_.utlc = (float)0.;
    teproc_.utvv = (float)0.;
    for (i__ = 1; i__ <= 8; ++i__) {
	teproc_.utlr += teproc_.uclr[i__ - 1];
	teproc_.utls += teproc_.ucls[i__ - 1];
	teproc_.utlc += teproc_.uclc[i__ - 1];
	teproc_.utvv += teproc_.ucvv[i__ - 1];
/* L1040: */
    }
    for (i__ = 1; i__ <= 8; ++i__) {
	teproc_.xlr[i__ - 1] = teproc_.uclr[i__ - 1] / teproc_.utlr;
	teproc_.xls[i__ - 1] = teproc_.ucls[i__ - 1] / teproc_.utls;
	teproc_.xlc[i__ - 1] = teproc_.uclc[i__ - 1] / teproc_.utlc;
	teproc_.xvv[i__ - 1] = teproc_.ucvv[i__ - 1] / teproc_.utvv;
/* L1050: */
    }
	teproc_.esr = teproc_.etr / teproc_.utlr;
    teproc_.ess = teproc_.ets / teproc_.utls;
    teproc_.esc = teproc_.etc / teproc_.utlc;
    teproc_.esv = teproc_.etv / teproc_.utvv;
    tesub2_(teproc_.xlr, &teproc_.tcr, &teproc_.esr, &c__0);
    teproc_.tkr = teproc_.tcr + (float)273.15;
    tesub2_(teproc_.xls, &teproc_.tcs, &teproc_.ess, &c__0);
    teproc_.tks = teproc_.tcs + (float)273.15;
    tesub2_(teproc_.xlc, &teproc_.tcc, &teproc_.esc, &c__0);
    tesub2_(teproc_.xvv, &teproc_.tcv, &teproc_.esv, &c__2);
    teproc_.tkv = teproc_.tcv + (float)273.15;
    tesub4_(teproc_.xlr, &teproc_.tcr, &teproc_.dlr);
    tesub4_(teproc_.xls, &teproc_.tcs, &teproc_.dls);
    tesub4_(teproc_.xlc, &teproc_.tcc, &teproc_.dlc);
    teproc_.vlr = teproc_.utlr / teproc_.dlr;
    teproc_.vls = teproc_.utls / teproc_.dls;
    teproc_.vlc = teproc_.utlc / teproc_.dlc;
    teproc_.vvr = teproc_.vtr - teproc_.vlr;
    teproc_.vvs = teproc_.vts - teproc_.vls;
    rg = (float)998.9;
    teproc_.ptr = (float)0.;
    teproc_.pts = (float)0.;
    for (i__ = 1; i__ <= 3; ++i__) {
	teproc_.ppr[i__ - 1] = teproc_.ucvr[i__ - 1] * rg * teproc_.tkr / 
		teproc_.vvr;
	teproc_.ptr += teproc_.ppr[i__ - 1];
	teproc_.pps[i__ - 1] = teproc_.ucvs[i__ - 1] * rg * teproc_.tks / 
		teproc_.vvs;
	teproc_.pts += teproc_.pps[i__ - 1];
/* L1110: */
    }
    for (i__ = 4; i__ <= 8; ++i__) {
	vpr = exp(const_.avp[i__ - 1] + const_.bvp[i__ - 1] / (teproc_.tcr 
		+ const_.cvp[i__ - 1]));
	teproc_.ppr[i__ - 1] = vpr * teproc_.xlr[i__ - 1];
	teproc_.ptr += teproc_.ppr[i__ - 1];
	vpr = exp(const_.avp[i__ - 1] + const_.bvp[i__ - 1] / (teproc_.tcs 
		+ const_.cvp[i__ - 1]));
	teproc_.pps[i__ - 1] = vpr * teproc_.xls[i__ - 1];
	teproc_.pts += teproc_.pps[i__ - 1];
/* L1120: */
    }
    teproc_.ptv = teproc_.utvv * rg * teproc_.tkv / teproc_.vtv;
    for (i__ = 1; i__ <= 8; ++i__) {
	teproc_.xvr[i__ - 1] = teproc_.ppr[i__ - 1] / teproc_.ptr;
	teproc_.xvs[i__ - 1] = teproc_.pps[i__ - 1] / teproc_.pts;
/* L1130: */
    }
    teproc_.utvr = teproc_.ptr * teproc_.vvr / rg / teproc_.tkr;
    teproc_.utvs = teproc_.pts * teproc_.vvs / rg / teproc_.tks;
    for (i__ = 4; i__ <= 8; ++i__) {
	teproc_.ucvr[i__ - 1] = teproc_.utvr * teproc_.xvr[i__ - 1];
	teproc_.ucvs[i__ - 1] = teproc_.utvs * teproc_.xvs[i__ - 1];
/* L1140: */
    }
    teproc_.rr[0] = exp((float)31.5859536 - (float)20130.85052843482 / 
	    teproc_.tkr) * r1f;
    teproc_.rr[1] = exp((float)3.00094014 - (float)10065.42526421741 / 
	    teproc_.tkr) * r2f;
    teproc_.rr[2] = exp((float)53.4060443 - (float)30196.27579265224 / 
	    teproc_.tkr);
    teproc_.rr[3] = teproc_.rr[2] * .767488334;
    if (teproc_.ppr[0] > (float)0. && teproc_.ppr[2] > (float)0.) {
	r1f = pow_dd(teproc_.ppr, &c_b73);
	r2f = pow_dd(&teproc_.ppr[2], &c_b74);
	teproc_.rr[0] = teproc_.rr[0] * r1f * r2f * teproc_.ppr[3];
	teproc_.rr[1] = teproc_.rr[1] * r1f * r2f * teproc_.ppr[4];
    } else {
	teproc_.rr[0] = (float)0.;
	teproc_.rr[1] = (float)0.;
    }
    teproc_.rr[2] = teproc_.rr[2] * teproc_.ppr[0] * teproc_.ppr[4];
    teproc_.rr[3] = teproc_.rr[3] * teproc_.ppr[0] * teproc_.ppr[3];
    for (i__ = 1; i__ <= 4; ++i__) {
	teproc_.rr[i__ - 1] *= teproc_.vvr;
/* L1200: */
    }
    teproc_.crxr[0] = -teproc_.rr[0] - teproc_.rr[1] - teproc_.rr[2];
    teproc_.crxr[2] = -teproc_.rr[0] - teproc_.rr[1];
    teproc_.crxr[3] = -teproc_.rr[0] - teproc_.rr[3] * 1.5;
    teproc_.crxr[4] = -teproc_.rr[1] - teproc_.rr[2];
    teproc_.crxr[5] = teproc_.rr[2] + teproc_.rr[3];
    teproc_.crxr[6] = teproc_.rr[0];
    teproc_.crxr[7] = teproc_.rr[1];
    teproc_.rh = teproc_.rr[0] * teproc_.htr[0] + teproc_.rr[1] * 
	    teproc_.htr[1];
    teproc_.xmws[0] = (float)0.;
    teproc_.xmws[1] = (float)0.;
    teproc_.xmws[5] = (float)0.;
    teproc_.xmws[7] = (float)0.;
    teproc_.xmws[8] = (float)0.;
    teproc_.xmws[9] = (float)0.;
    for (i__ = 1; i__ <= 8; ++i__) {
	teproc_.xst[i__ + 39] = teproc_.xvv[i__ - 1];
	teproc_.xst[i__ + 55] = teproc_.xvr[i__ - 1];
	teproc_.xst[i__ + 63] = teproc_.xvs[i__ - 1];
	teproc_.xst[i__ + 71] = teproc_.xvs[i__ - 1];
	teproc_.xst[i__ + 79] = teproc_.xls[i__ - 1];
	teproc_.xst[i__ + 95] = teproc_.xlc[i__ - 1];
	teproc_.xmws[0] += teproc_.xst[i__ - 1] * const_.xmw[i__ - 1];
	teproc_.xmws[1] += teproc_.xst[i__ + 7] * const_.xmw[i__ - 1];
	teproc_.xmws[5] += teproc_.xst[i__ + 39] * const_.xmw[i__ - 1];
	teproc_.xmws[7] += teproc_.xst[i__ + 55] * const_.xmw[i__ - 1];
	teproc_.xmws[8] += teproc_.xst[i__ + 63] * const_.xmw[i__ - 1];
	teproc_.xmws[9] += teproc_.xst[i__ + 71] * const_.xmw[i__ - 1];
/* L2010: */
    }
    teproc_.tst[5] = teproc_.tcv;
    teproc_.tst[7] = teproc_.tcr;
    teproc_.tst[8] = teproc_.tcs;
    teproc_.tst[9] = teproc_.tcs;
    teproc_.tst[10] = teproc_.tcs;
    teproc_.tst[12] = teproc_.tcc;
    tesub1_(teproc_.xst, teproc_.tst, teproc_.hst, &c__1);
    tesub1_(&teproc_.xst[8], &teproc_.tst[1], &teproc_.hst[1], &c__1);
    tesub1_(&teproc_.xst[16], &teproc_.tst[2], &teproc_.hst[2], &c__1);
    tesub1_(&teproc_.xst[24], &teproc_.tst[3], &teproc_.hst[3], &c__1);
    tesub1_(&teproc_.xst[40], &teproc_.tst[5], &teproc_.hst[5], &c__1);
    tesub1_(&teproc_.xst[56], &teproc_.tst[7], &teproc_.hst[7], &c__1);
    tesub1_(&teproc_.xst[64], &teproc_.tst[8], &teproc_.hst[8], &c__1);
    teproc_.hst[9] = teproc_.hst[8];
    tesub1_(&teproc_.xst[80], &teproc_.tst[10], &teproc_.hst[10], &c__0);
    tesub1_(&teproc_.xst[96], &teproc_.tst[12], &teproc_.hst[12], &c__0);
    teproc_.ftm[0] = vpos[0] * teproc_.vrng[0] / (float)100.;
    teproc_.ftm[1] = vpos[1] * teproc_.vrng[1] / (float)100.;
    teproc_.ftm[2] = vpos[2] * (1. - dvec_.idv[5]) * teproc_.vrng[2] / (
	    float)100.;
    teproc_.ftm[3] = vpos[3] * (1. - dvec_.idv[6] * .2) * teproc_.vrng[3] /
	     (float)100. + 1e-10;
    teproc_.ftm[10] = vpos[6] * teproc_.vrng[6] / (float)100.;
    teproc_.ftm[12] = vpos[7] * teproc_.vrng[7] / (float)100.;
    uac = vpos[8] * teproc_.vrng[8] * (tesub8_(&c__9, time) + 1.) / (float)
	    100.;
    teproc_.fwr = vpos[9] * teproc_.vrng[9] / (float)100.;
    teproc_.fws = vpos[10] * teproc_.vrng[10] / (float)100.;
    teproc_.agsp = (vpos[11] + (float)150.) / (float)100.;
    dlp = teproc_.ptv - teproc_.ptr;
    if (dlp < (float)0.) {
	dlp = (float)0.;
    }
    flms = sqrt(dlp) * 1937.6;
    teproc_.ftm[5] = flms / teproc_.xmws[5];
    dlp = teproc_.ptr - teproc_.pts;
    if (dlp < (float)0.) {
	dlp = (float)0.;
    }
    flms = sqrt(dlp) * 4574.21 * (1. - tesub8_(&c__12, time) * .25);
    teproc_.ftm[7] = flms / teproc_.xmws[7];
    dlp = teproc_.pts - (float)760.;
    if (dlp < (float)0.) {
	dlp = (float)0.;
    }
    flms = vpos[5] * .151169 * sqrt(dlp);
    teproc_.ftm[9] = flms / teproc_.xmws[9];
    pr = teproc_.ptv / teproc_.pts;
    if (pr < (float)1.) {
	pr = (float)1.;
    }
    if (pr > teproc_.cpprmx) {
	pr = teproc_.cpprmx;
    }
    flcoef = teproc_.cpflmx / 1.197;
/* Computing 3rd power */
    d__1 = pr;
    flms = teproc_.cpflmx + flcoef * ((float)1. - d__1 * (d__1 * d__1));
    teproc_.cpdh = flms * (teproc_.tcs + 273.15) * 1.8e-6 * 1.9872 * (
	    teproc_.ptv - teproc_.pts) / (teproc_.xmws[8] * teproc_.pts);
    dlp = teproc_.ptv - teproc_.pts;
    if (dlp < (float)0.) {
	dlp = (float)0.;
    }
    flms -= vpos[4] * 53.349 * sqrt(dlp);
    if (flms < .001) {
	flms = .001;
    }
    teproc_.ftm[8] = flms / teproc_.xmws[8];
    teproc_.hst[8] += teproc_.cpdh / teproc_.ftm[8];
    for (i__ = 1; i__ <= 8; ++i__) {
	teproc_.fcm[i__ - 1] = teproc_.xst[i__ - 1] * teproc_.ftm[0];
	teproc_.fcm[i__ + 7] = teproc_.xst[i__ + 7] * teproc_.ftm[1];
	teproc_.fcm[i__ + 15] = teproc_.xst[i__ + 15] * teproc_.ftm[2];
	teproc_.fcm[i__ + 23] = teproc_.xst[i__ + 23] * teproc_.ftm[3];
	teproc_.fcm[i__ + 39] = teproc_.xst[i__ + 39] * teproc_.ftm[5];
	teproc_.fcm[i__ + 55] = teproc_.xst[i__ + 55] * teproc_.ftm[7];
	teproc_.fcm[i__ + 63] = teproc_.xst[i__ + 63] * teproc_.ftm[8];
	teproc_.fcm[i__ + 71] = teproc_.xst[i__ + 71] * teproc_.ftm[9];
	teproc_.fcm[i__ + 79] = teproc_.xst[i__ + 79] * teproc_.ftm[10];
	teproc_.fcm[i__ + 95] = teproc_.xst[i__ + 95] * teproc_.ftm[12];
/* L5020: */
    }
    if (teproc_.ftm[10] > (float).1) {
	if (teproc_.tcc > (float)170.) {
	    tmpfac = teproc_.tcc - (float)120.262;
	} else if (teproc_.tcc < (float)5.292) {
	    tmpfac = (float).1;
	} else {
	    tmpfac = (float)363.744 / ((float)177. - teproc_.tcc) - (float)
		    2.22579488;
	}
	vovrl = teproc_.ftm[3] / teproc_.ftm[10] * tmpfac;
	teproc_.sfr[3] = vovrl * (float)8.501 / (vovrl * (float)8.501 + (
		float)1.);
	teproc_.sfr[4] = vovrl * (float)11.402 / (vovrl * (float)11.402 + (
		float)1.);
	teproc_.sfr[5] = vovrl * (float)11.795 / (vovrl * (float)11.795 + (
		float)1.);
	teproc_.sfr[6] = vovrl * (float).048 / (vovrl * (float).048 + (float)
		1.);
	teproc_.sfr[7] = vovrl * (float).0242 / (vovrl * (float).0242 + (
		float)1.);
    } else {
	teproc_.sfr[3] = (float).9999;
	teproc_.sfr[4] = (float).999;
	teproc_.sfr[5] = (float).999;
	teproc_.sfr[6] = (float).99;
	teproc_.sfr[7] = (float).98;
    }
    for (i__ = 1; i__ <= 8; ++i__) {
	fin[i__ - 1] = (float)0.;
	fin[i__ - 1] += teproc_.fcm[i__ + 23];
	fin[i__ - 1] += teproc_.fcm[i__ + 79];
/* L6010: */
    }
    teproc_.ftm[4] = (float)0.;
    teproc_.ftm[11] = (float)0.;
    for (i__ = 1; i__ <= 8; ++i__) {
	teproc_.fcm[i__ + 31] = teproc_.sfr[i__ - 1] * fin[i__ - 1];
	teproc_.fcm[i__ + 87] = fin[i__ - 1] - teproc_.fcm[i__ + 31];
	teproc_.ftm[4] += teproc_.fcm[i__ + 31];
	teproc_.ftm[11] += teproc_.fcm[i__ + 87];
/* L6020: */
    }
    for (i__ = 1; i__ <= 8; ++i__) {
	teproc_.xst[i__ + 31] = teproc_.fcm[i__ + 31] / teproc_.ftm[4];
	teproc_.xst[i__ + 87] = teproc_.fcm[i__ + 87] / teproc_.ftm[11];
/* L6030: */
    }
    teproc_.tst[4] = teproc_.tcc;
    teproc_.tst[11] = teproc_.tcc;
    tesub1_(&teproc_.xst[32], &teproc_.tst[4], &teproc_.hst[4], &c__1);
    tesub1_(&teproc_.xst[88], &teproc_.tst[11], &teproc_.hst[11], &c__0);
    teproc_.ftm[6] = teproc_.ftm[5];
    teproc_.hst[6] = teproc_.hst[5];
    teproc_.tst[6] = teproc_.tst[5];
    for (i__ = 1; i__ <= 8; ++i__) {
	teproc_.xst[i__ + 47] = teproc_.xst[i__ + 39];
	teproc_.fcm[i__ + 47] = teproc_.fcm[i__ + 39];
/* L6130: */
    }
    if (teproc_.vlr / (float)7.8 > (float)50.) {
	uarlev = (float)1.;
    } else if (teproc_.vlr / (float)7.8 < (float)10.) {
	uarlev = (float)0.;
    } else {
	uarlev = teproc_.vlr * (float).025 / (float)7.8 - (float).25;
    }
/* Computing 2nd power */
    d__1 = teproc_.agsp;
    teproc_.uar = uarlev * (d__1 * d__1 * (float)-.5 + teproc_.agsp * (
	    float)2.75 - (float)2.5) * .85549;
    teproc_.qur = teproc_.uar * (teproc_.twr - teproc_.tcr) * (1. - 
	    tesub8_(&c__10, time) * .35);
/* Computing 4th power */
    d__1 = teproc_.ftm[7] / (float)3528.73, d__1 *= d__1;
    uas = ((float)1. - (float)1. / (d__1 * d__1 + (float)1.)) * (float)
	    .404655;
    teproc_.qus = uas * (teproc_.tws - teproc_.tst[7]) * (1. - tesub8_(
	    &c__11, time) * .25);
    teproc_.quc = 0.;
    if (teproc_.tcc < (float)100.) {
	teproc_.quc = uac * ((float)100. - teproc_.tcc);
    }
    pv_.xmeas[0] = teproc_.ftm[2] * (float).359 / (float)35.3145;
    pv_.xmeas[1] = teproc_.ftm[0] * teproc_.xmws[0] * (float).454;
    pv_.xmeas[2] = teproc_.ftm[1] * teproc_.xmws[1] * (float).454;
    pv_.xmeas[3] = teproc_.ftm[3] * (float).359 / (float)35.3145;
    pv_.xmeas[4] = teproc_.ftm[8] * (float).359 / (float)35.3145;
    pv_.xmeas[5] = teproc_.ftm[5] * (float).359 / (float)35.3145;
    pv_.xmeas[6] = (teproc_.ptr - (float)760.) / (float)760. * (float)
	    101.325;
    pv_.xmeas[7] = (teproc_.vlr - (float)84.6) / (float)666.7 * (float)100.;
    pv_.xmeas[8] = teproc_.tcr;
    pv_.xmeas[9] = teproc_.ftm[9] * (float).359 / (float)35.3145;
    pv_.xmeas[10] = teproc_.tcs;
    pv_.xmeas[11] = (teproc_.vls - (float)27.5) / (float)290. * (float)100.;
    pv_.xmeas[12] = (teproc_.pts - (float)760.) / (float)760. * (float)
	    101.325;
    pv_.xmeas[13] = teproc_.ftm[10] / teproc_.dls / (float)35.3145;
    pv_.xmeas[14] = (teproc_.vlc - (float)78.25) / teproc_.vtc * (float)
	    100.;
    pv_.xmeas[15] = (teproc_.ptv - (float)760.) / (float)760. * (float)
	    101.325;
    pv_.xmeas[16] = teproc_.ftm[12] / teproc_.dlc / (float)35.3145;
    pv_.xmeas[17] = teproc_.tcc;
    pv_.xmeas[18] = teproc_.quc * 1040. * (float).454;
    pv_.xmeas[19] = teproc_.cpdh * 392.7;
    pv_.xmeas[19] = teproc_.cpdh * 293.07;
    pv_.xmeas[20] = teproc_.twr;
    pv_.xmeas[21] = teproc_.tws;
    *isd = 0;
    if (pv_.xmeas[6] > (float)3e3) {
	*isd = 1;
	sprintf(msg,"High Reactor Pressure!!  Shutting down.");
    }
    if (teproc_.vlr / (float)35.3145 > (float)24.) {
	*isd = 2;
	sprintf(msg,"High Reactor Liquid Level!!  Shutting down.");
    }
    if (teproc_.vlr / (float)35.3145 < (float)2.) {
	*isd = 3;
	sprintf(msg,"Low Reactor Liquid Level!!  Shutting down.");
    }
    if (pv_.xmeas[8] > (float)175.) {
	sprintf(msg,"High Reactor Temperature!!  Shutting down.");
	*isd = 4;
    }
    if (teproc_.vls / (float)35.3145 > (float)12.) {
	*isd = 5;
	sprintf(msg,"High Separator Liquid Level!!  Shutting down.");
    }
    if (teproc_.vls / (float)35.3145 < (float)1.) {
	*isd = 6;
	sprintf(msg,"Low Separator Liquid Level!!  Shutting down.");
    }
    if (teproc_.vlc / (float)35.3145 > (float)8.) {
	sprintf(msg,"High Stripper Liquid Level!!  Shutting down.");
	*isd = 7;
    }
    if (teproc_.vlc / (float)35.3145 < (float)1.) {
	*isd = 8;
	sprintf(msg,"Low Stripper Liquid Level!!  Shutting down.");
    }
    if (*time > (float)0. && *isd == 0) {
	for (i__ = 1; i__ <= 22; ++i__) {
	    tesub6_(&teproc_.xns[i__ - 1], &xmns);
	    pv_.xmeas[i__ - 1] += xmns;
/* L6500: */
	}
    }
    xcmp[22] = teproc_.xst[48] * (float)100.;
    xcmp[23] = teproc_.xst[49] * (float)100.;
    xcmp[24] = teproc_.xst[50] * (float)100.;
    xcmp[25] = teproc_.xst[51] * (float)100.;
    xcmp[26] = teproc_.xst[52] * (float)100.;
    xcmp[27] = teproc_.xst[53] * (float)100.;
    xcmp[28] = teproc_.xst[72] * (float)100.;
    xcmp[29] = teproc_.xst[73] * (float)100.;
    xcmp[30] = teproc_.xst[74] * (float)100.;
    xcmp[31] = teproc_.xst[75] * (float)100.;
    xcmp[32] = teproc_.xst[76] * (float)100.;
    xcmp[33] = teproc_.xst[77] * (float)100.;
    xcmp[34] = teproc_.xst[78] * (float)100.;
    xcmp[35] = teproc_.xst[79] * (float)100.;
    xcmp[36] = teproc_.xst[99] * (float)100.;
    xcmp[37] = teproc_.xst[100] * (float)100.;
    xcmp[38] = teproc_.xst[101] * (float)100.;
    xcmp[39] = teproc_.xst[102] * (float)100.;
    xcmp[40] = teproc_.xst[103] * (float)100.;
    if (*time == 0.) {
	for (i__ = 23; i__ <= 41; ++i__) {
	    teproc_.xdel[i__ - 1] = xcmp[i__ - 1];
	    pv_.xmeas[i__ - 1] = xcmp[i__ - 1];
/* L7010: */
	}
	teproc_.tgas = (float).1;
	teproc_.tprod = (float).25;
    }
    if (*time >= teproc_.tgas) {
	for (i__ = 23; i__ <= 36; ++i__) {
	    pv_.xmeas[i__ - 1] = teproc_.xdel[i__ - 1];
	    tesub6_(&teproc_.xns[i__ - 1], &xmns);
	    pv_.xmeas[i__ - 1] += xmns;
	    teproc_.xdel[i__ - 1] = xcmp[i__ - 1];
/* L7020: */
	}
	teproc_.tgas += (float).1;
    }
    if (*time >= teproc_.tprod) {
	for (i__ = 37; i__ <= 41; ++i__) {
	    pv_.xmeas[i__ - 1] = teproc_.xdel[i__ - 1];
	    tesub6_(&teproc_.xns[i__ - 1], &xmns);
	    pv_.xmeas[i__ - 1] += xmns;
	    teproc_.xdel[i__ - 1] = xcmp[i__ - 1];
/* L7030: */
	}
	teproc_.tprod += (float).25;
    }
    for (i__ = 1; i__ <= 8; ++i__) {
	yp[i__] = teproc_.fcm[i__ + 47] - teproc_.fcm[i__ + 55] + 
		teproc_.crxr[i__ - 1];
	yp[i__ + 9] = teproc_.fcm[i__ + 55] - teproc_.fcm[i__ + 63] - 
		teproc_.fcm[i__ + 71] - teproc_.fcm[i__ + 79];
	yp[i__ + 18] = teproc_.fcm[i__ + 87] - teproc_.fcm[i__ + 95];
	yp[i__ + 27] = teproc_.fcm[i__ - 1] + teproc_.fcm[i__ + 7] + 
		teproc_.fcm[i__ + 15] + teproc_.fcm[i__ + 31] + 
		teproc_.fcm[i__ + 63] - teproc_.fcm[i__ + 39];
/* L9010: */
    }
    yp[9] = teproc_.hst[6] * teproc_.ftm[6] - teproc_.hst[7] * 
	    teproc_.ftm[7] + teproc_.rh + teproc_.qur;
/* 		Here is the "correct" version of the separator energy balance: */
/* 	YP(18)=HST(8)*FTM(8)- */
/*    .(HST(9)*FTM(9)-cpdh)- */
/*    .HST(10)*FTM(10)- */
/*    .HST(11)*FTM(11)+ */
/*    .QUS */
/* 		Here is the original version */
    yp[18] = teproc_.hst[7] * teproc_.ftm[7] - teproc_.hst[8] * 
	    teproc_.ftm[8] - teproc_.hst[9] * teproc_.ftm[9] - 
	    teproc_.hst[10] * teproc_.ftm[10] + teproc_.qus;
    yp[27] = teproc_.hst[3] * teproc_.ftm[3] + teproc_.hst[10] * 
	    teproc_.ftm[10] - teproc_.hst[4] * teproc_.ftm[4] - 
	    teproc_.hst[12] * teproc_.ftm[12] + teproc_.quc;
    yp[36] = teproc_.hst[0] * teproc_.ftm[0] + teproc_.hst[1] * 
	    teproc_.ftm[1] + teproc_.hst[2] * teproc_.ftm[2] + 
	    teproc_.hst[4] * teproc_.ftm[4] + teproc_.hst[8] * 
	    teproc_.ftm[8] - teproc_.hst[5] * teproc_.ftm[5];
    yp[37] = (teproc_.fwr * (float)500.53 * (teproc_.tcwr - teproc_.twr) - 
	    teproc_.qur * 1e6 / (float)1.8) / teproc_.hwr;
    yp[38] = (teproc_.fws * (float)500.53 * (teproc_.tcws - teproc_.tws) - 
	    teproc_.qus * 1e6 / (float)1.8) / teproc_.hws;
    teproc_.ivst[9] = dvec_.idv[13];
    teproc_.ivst[10] = dvec_.idv[14];
    teproc_.ivst[4] = dvec_.idv[18];
    teproc_.ivst[6] = dvec_.idv[18];
    teproc_.ivst[7] = dvec_.idv[18];
    teproc_.ivst[8] = dvec_.idv[18];
    for (i__ = 1; i__ <= 12; ++i__) {
	if (*time == 0. || (d__1 = teproc_.vcv[i__ - 1] - pv_.xmv[i__ - 1], 
		abs(d__1)) > teproc_.vst[i__ - 1] * teproc_.ivst[i__ - 1]) {
	    teproc_.vcv[i__ - 1] = pv_.xmv[i__ - 1];
	}
	if (teproc_.vcv[i__ - 1] < (float)0.) {
	    teproc_.vcv[i__ - 1] = (float)0.;
	}
	if (teproc_.vcv[i__ - 1] > (float)100.) {
	    teproc_.vcv[i__ - 1] = (float)100.;
	}
	yp[i__ + 38] = (teproc_.vcv[i__ - 1] - vpos[i__ - 1]) / 
		teproc_.vtau[i__ - 1];
/* L9020: */
    }
    if (*time > (float)0. && *isd != 0) {
	i__1 = *nn;
	for (i__ = 1; i__ <= i__1; ++i__) {
	    yp[i__] = (float)0.;
/* L9030: */
	}
    }
    return 0;
} /* tefunc_ */

#undef isd



/* ============================================================================= */

/* SUBROUTINE TEINIT*/

static int teinit(const integer *nn, doublereal *time, doublereal *yy, doublereal *yp)
{
    /* Local variables */
    integer i__;
#define isd ((integer *)&dvec_ + 20)


/*       Initialization */

/*         Inputs: */

/*           NN   = Number of differential equations */

/*         Outputs: */

/*           Time = Current time(hrs) */
/*           YY   = Current state values */
/*           YP   = Current derivative values */

/*  MEASUREMENT AND VALVE COMMON BLOCK */


/*   DISTURBANCE VECTOR COMMON BLOCK */

/* 	NOTE: I have included isd in the /IDV/ common.  This is set */
/* 		non-zero when the process is shutting down. */
/* 		Output XMEAS(42) is for cost [cents/kmol product]. */
/* 		Output XMEAS(43) is production rate of G [kmol G generated/h] */
/* 		Output XMEAS(44) is production rate of H [kmol H generated/h] */
/* 		Output XMEAS(45) is production rate of F [kmol F generated/h] */
/* 		Output XMEAS(46) is partial pressure of A in reactor [kPa] */
/* 		Output XMEAS(47) is partial pressure of C in reactor [kPa] */
/* 		Output XMEAS(48) is partial pressure of D in reactor [kPa] */
/* 		Output XMEAS(49) is partial pressure of E in reactor [kPa] */
/* 		Output XMEAS(50) is true (delay free) mole % G in product */
/* 		Output XMEAS(51) is true (delay free) mole % H in product */
    /* Parameter adjustments */
    --yp;
    --yy;

    /* Function Body */
    const_.xmw[0] = (float)2.;
    const_.xmw[1] = (float)25.4;
    const_.xmw[2] = (float)28.;
    const_.xmw[3] = (float)32.;
    const_.xmw[4] = (float)46.;
    const_.xmw[5] = (float)48.;
    const_.xmw[6] = (float)62.;
    const_.xmw[7] = (float)76.;
    const_.avp[0] = (float)0.;
    const_.avp[1] = (float)0.;
    const_.avp[2] = (float)0.;
    const_.avp[3] = (float)15.92;
    const_.avp[4] = (float)16.35;
    const_.avp[5] = (float)16.35;
    const_.avp[6] = (float)16.43;
    const_.avp[7] = (float)17.21;
    const_.bvp[0] = (float)0.;
    const_.bvp[1] = (float)0.;
    const_.bvp[2] = (float)0.;
    const_.bvp[3] = (float)-1444.;
    const_.bvp[4] = (float)-2114.;
    const_.bvp[5] = (float)-2114.;
    const_.bvp[6] = (float)-2748.;
    const_.bvp[7] = (float)-3318.;
    const_.cvp[0] = (float)0.;
    const_.cvp[1] = (float)0.;
    const_.cvp[2] = (float)0.;
    const_.cvp[3] = (float)259.;
    const_.cvp[4] = (float)265.5;
    const_.cvp[5] = (float)265.5;
    const_.cvp[6] = (float)232.9;
    const_.cvp[7] = (float)249.6;
    const_.ad[0] = (float)1.;
    const_.ad[1] = (float)1.;
    const_.ad[2] = (float)1.;
    const_.ad[3] = (float)23.3;
    const_.ad[4] = (float)33.9;
    const_.ad[5] = (float)32.8;
    const_.ad[6] = (float)49.9;
    const_.ad[7] = (float)50.5;
    const_.bd[0] = (float)0.;
    const_.bd[1] = (float)0.;
    const_.bd[2] = (float)0.;
    const_.bd[3] = (float)-.07;
    const_.bd[4] = (float)-.0957;
    const_.bd[5] = (float)-.0995;
    const_.bd[6] = (float)-.0191;
    const_.bd[7] = (float)-.0541;
    const_.cd[0] = (float)0.;
    const_.cd[1] = (float)0.;
    const_.cd[2] = (float)0.;
    const_.cd[3] = (float)-2e-4;
    const_.cd[4] = (float)-1.52e-4;
    const_.cd[5] = (float)-2.33e-4;
    const_.cd[6] = (float)-4.25e-4;
    const_.cd[7] = (float)-1.5e-4;
    const_.ah[0] = 1e-6;
    const_.ah[1] = 1e-6;
    const_.ah[2] = 1e-6;
    const_.ah[3] = 9.6e-7;
    const_.ah[4] = 5.73e-7;
    const_.ah[5] = 6.52e-7;
    const_.ah[6] = 5.15e-7;
    const_.ah[7] = 4.71e-7;
    const_.bh[0] = (float)0.;
    const_.bh[1] = (float)0.;
    const_.bh[2] = (float)0.;
    const_.bh[3] = 8.7e-9;
    const_.bh[4] = 2.41e-9;
    const_.bh[5] = 2.18e-9;
    const_.bh[6] = 5.65e-10;
    const_.bh[7] = 8.7e-10;
    const_.ch[0] = (float)0.;
    const_.ch[1] = (float)0.;
    const_.ch[2] = (float)0.;
    const_.ch[3] = 4.81e-11;
    const_.ch[4] = 1.82e-11;
    const_.ch[5] = 1.94e-11;
    const_.ch[6] = 3.82e-12;
    const_.ch[7] = 2.62e-12;
    const_.av[0] = 1e-6;
    const_.av[1] = 1e-6;
    const_.av[2] = 1e-6;
    const_.av[3] = 8.67e-5;
    const_.av[4] = 1.6e-4;
    const_.av[5] = 1.6e-4;
    const_.av[6] = 2.25e-4;
    const_.av[7] = 2.09e-4;
    const_.ag[0] = 3.411e-6;
    const_.ag[1] = 3.799e-7;
    const_.ag[2] = 2.491e-7;
    const_.ag[3] = 3.567e-7;
    const_.ag[4] = 3.463e-7;
    const_.ag[5] = 3.93e-7;
    const_.ag[6] = 1.7e-7;
    const_.ag[7] = 1.5e-7;
    const_.bg[0] = 7.18e-10;
    const_.bg[1] = 1.08e-9;
    const_.bg[2] = 1.36e-11;
    const_.bg[3] = 8.51e-10;
    const_.bg[4] = 8.96e-10;
    const_.bg[5] = 1.02e-9;
    const_.bg[6] = 0.;
    const_.bg[7] = 0.;
    const_.cg[0] = 6e-13;
    const_.cg[1] = -3.98e-13;
    const_.cg[2] = -3.93e-14;
    const_.cg[3] = -3.12e-13;
    const_.cg[4] = -3.27e-13;
    const_.cg[5] = -3.12e-13;
    const_.cg[6] = 0.;
    const_.cg[7] = 0.;
    yy[1] = (float)10.40491389;
    yy[2] = (float)4.363996017;
    yy[3] = (float)7.570059737;
    yy[4] = (float).4230042431;
    yy[5] = (float)24.15513437;
    yy[6] = (float)2.942597645;
    yy[7] = (float)154.3770655;
    yy[8] = (float)159.186596;
    yy[9] = (float)2.808522723;
    yy[10] = (float)63.75581199;
    yy[11] = (float)26.74026066;
    yy[12] = (float)46.38532432;
    yy[13] = (float).2464521543;
    yy[14] = (float)15.20484404;
    yy[15] = (float)1.852266172;
    yy[16] = (float)52.44639459;
    yy[17] = (float)41.20394008;
    yy[18] = (float).569931776;
    yy[19] = (float).4306056376;
    yy[20] = .0079906200783;
    yy[21] = (float).9056036089;
    yy[22] = .016054258216;
    yy[23] = (float).7509759687;
    yy[24] = .088582855955;
    yy[25] = (float)48.27726193;
    yy[26] = (float)39.38459028;
    yy[27] = (float).3755297257;
    yy[28] = (float)107.7562698;
    yy[29] = (float)29.77250546;
    yy[30] = (float)88.32481135;
    yy[31] = (float)23.03929507;
    yy[32] = (float)62.85848794;
    yy[33] = (float)5.546318688;
    yy[34] = (float)11.92244772;
    yy[35] = (float)5.555448243;
    yy[36] = (float).9218489762;
    yy[37] = (float)94.59927549;
    yy[38] = (float)77.29698353;
    yy[39] = (float)63.05263039;
    yy[40] = (float)53.97970677;
    yy[41] = (float)24.64355755;
    yy[42] = (float)61.30192144;
    yy[43] = (float)22.21;
    yy[44] = (float)40.06374673;
    yy[45] = (float)38.1003437;
    yy[46] = (float)46.53415582;
    yy[47] = (float)47.44573456;
    yy[48] = (float)41.10581288;
    yy[49] = (float)18.11349055;
    yy[50] = (float)50.;
    for (i__ = 1; i__ <= 12; ++i__) {
	pv_.xmv[i__ - 1] = yy[i__ + 38];
	teproc_.vcv[i__ - 1] = pv_.xmv[i__ - 1];
	teproc_.vst[i__ - 1] = 2.;
	teproc_.ivst[i__ - 1] = 0;
/* L200: */
    }
    teproc_.vrng[0] = (float)400.;
    teproc_.vrng[1] = (float)400.;
    teproc_.vrng[2] = (float)100.;
    teproc_.vrng[3] = (float)1500.;
    teproc_.vrng[6] = (float)1500.;
    teproc_.vrng[7] = (float)1e3;
    teproc_.vrng[8] = (float).03;
    teproc_.vrng[9] = (float)1e3;
    teproc_.vrng[10] = (float)1200.;
    teproc_.vtr = (float)1300.;
    teproc_.vts = (float)3500.;
    teproc_.vtc = (float)156.5;
    teproc_.vtv = (float)5e3;
    teproc_.htr[0] = .06899381054;
    teproc_.htr[1] = .05;
    teproc_.hwr = (float)7060.;
    teproc_.hws = (float)11138.;
    teproc_.sfr[0] = (float).995;
    teproc_.sfr[1] = (float).991;
    teproc_.sfr[2] = (float).99;
    teproc_.sfr[3] = (float).916;
    teproc_.sfr[4] = (float).936;
    teproc_.sfr[5] = (float).938;
    teproc_.sfr[6] = .058;
    teproc_.sfr[7] = .0301;
    teproc_.xst[0] = (float)0.;
    teproc_.xst[1] = (float)1e-4;
    teproc_.xst[2] = (float)0.;
    teproc_.xst[3] = (float).9999;
    teproc_.xst[4] = (float)0.;
    teproc_.xst[5] = (float)0.;
    teproc_.xst[6] = (float)0.;
    teproc_.xst[7] = (float)0.;
    teproc_.tst[0] = (float)45.;
    teproc_.xst[8] = (float)0.;
    teproc_.xst[9] = (float)0.;
    teproc_.xst[10] = (float)0.;
    teproc_.xst[11] = (float)0.;
    teproc_.xst[12] = (float).9999;
    teproc_.xst[13] = (float)1e-4;
    teproc_.xst[14] = (float)0.;
    teproc_.xst[15] = (float)0.;
    teproc_.tst[1] = (float)45.;
    teproc_.xst[16] = (float).9999;
    teproc_.xst[17] = (float)1e-4;
    teproc_.xst[18] = (float)0.;
    teproc_.xst[19] = (float)0.;
    teproc_.xst[20] = (float)0.;
    teproc_.xst[21] = (float)0.;
    teproc_.xst[22] = (float)0.;
    teproc_.xst[23] = (float)0.;
    teproc_.tst[2] = (float)45.;
    teproc_.xst[24] = (float).485;
    teproc_.xst[25] = (float).005;
    teproc_.xst[26] = (float).51;
    teproc_.xst[27] = (float)0.;
    teproc_.xst[28] = (float)0.;
    teproc_.xst[29] = (float)0.;
    teproc_.xst[30] = (float)0.;
    teproc_.xst[31] = (float)0.;
    teproc_.tst[3] = (float)45.;
    teproc_.cpflmx = (float)280275.;
    teproc_.cpprmx = (float)1.3;
    teproc_.vtau[0] = (float)8.;
    teproc_.vtau[1] = (float)8.;
    teproc_.vtau[2] = (float)6.;
    teproc_.vtau[3] = (float)9.;
    teproc_.vtau[4] = (float)7.;
    teproc_.vtau[5] = (float)5.;
    teproc_.vtau[6] = (float)5.;
    teproc_.vtau[7] = (float)5.;
    teproc_.vtau[8] = (float)120.;
    teproc_.vtau[9] = (float)5.;
    teproc_.vtau[10] = (float)5.;
    teproc_.vtau[11] = (float)5.;
    for (i__ = 1; i__ <= 12; ++i__) {
	teproc_.vtau[i__ - 1] /= (float)3600.;
/* L300: */
    }
    randsd_.g = 1431655765.;
    teproc_.xns[0] = .0012;
    teproc_.xns[1] = 18.;
    teproc_.xns[2] = 22.;
    teproc_.xns[3] = .05;
    teproc_.xns[4] = .2;
    teproc_.xns[5] = .21;
    teproc_.xns[6] = .3;
    teproc_.xns[7] = .5;
    teproc_.xns[8] = .01;
    teproc_.xns[9] = .0017;
    teproc_.xns[10] = .01;
    teproc_.xns[11] = 1.;
    teproc_.xns[12] = .3;
    teproc_.xns[13] = .125;
    teproc_.xns[14] = 1.;
    teproc_.xns[15] = .3;
    teproc_.xns[16] = .115;
    teproc_.xns[17] = .01;
    teproc_.xns[18] = 1.15;
    teproc_.xns[19] = .2;
    teproc_.xns[20] = .01;
    teproc_.xns[21] = .01;
    teproc_.xns[22] = .25;
    teproc_.xns[23] = .1;
    teproc_.xns[24] = .25;
    teproc_.xns[25] = .1;
    teproc_.xns[26] = .25;
    teproc_.xns[27] = .025;
    teproc_.xns[28] = .25;
    teproc_.xns[29] = .1;
    teproc_.xns[30] = .25;
    teproc_.xns[31] = .1;
    teproc_.xns[32] = .25;
    teproc_.xns[33] = .025;
    teproc_.xns[34] = .05;
    teproc_.xns[35] = .05;
    teproc_.xns[36] = .01;
    teproc_.xns[37] = .01;
    teproc_.xns[38] = .01;
    teproc_.xns[39] = .5;
    teproc_.xns[40] = .5;
    for (i__ = 1; i__ <= 20; ++i__) {
	dvec_.idv[i__ - 1] = 0;
/* L500: */
    }
    wlk_.hspan[0] = .2;
    wlk_.hzero[0] = .5;
    wlk_.sspan[0] = .03;
    wlk_.szero[0] = .485;
    wlk_.spspan[0] = 0.;
    wlk_.hspan[1] = .7;
    wlk_.hzero[1] = 1.;
    wlk_.sspan[1] = .003;
    wlk_.szero[1] = .005;
    wlk_.spspan[1] = 0.;
    wlk_.hspan[2] = .25;
    wlk_.hzero[2] = .5;
    wlk_.sspan[2] = 10.;
    wlk_.szero[2] = 45.;
    wlk_.spspan[2] = 0.;
    wlk_.hspan[3] = .7;
    wlk_.hzero[3] = 1.;
    wlk_.sspan[3] = 10.;
    wlk_.szero[3] = 45.;
    wlk_.spspan[3] = 0.;
    wlk_.hspan[4] = .15;
    wlk_.hzero[4] = .25;
    wlk_.sspan[4] = 10.;
    wlk_.szero[4] = 35.;
    wlk_.spspan[4] = 0.;
    wlk_.hspan[5] = .15;
    wlk_.hzero[5] = .25;
    wlk_.sspan[5] = 10.;
    wlk_.szero[5] = 40.;
    wlk_.spspan[5] = 0.;
    wlk_.hspan[6] = 1.;
    wlk_.hzero[6] = 2.;
    wlk_.sspan[6] = .25;
    wlk_.szero[6] = 1.;
    wlk_.spspan[6] = 0.;
    wlk_.hspan[7] = 1.;
    wlk_.hzero[7] = 2.;
    wlk_.sspan[7] = .25;
    wlk_.szero[7] = 1.;
    wlk_.spspan[7] = 0.;
    wlk_.hspan[8] = .4;
    wlk_.hzero[8] = .5;
    wlk_.sspan[8] = .25;
    wlk_.szero[8] = 0.;
    wlk_.spspan[8] = 0.;
    wlk_.hspan[9] = 1.5;
    wlk_.hzero[9] = 2.;
    wlk_.sspan[9] = 0.;
    wlk_.szero[9] = 0.;
    wlk_.spspan[9] = 0.;
    wlk_.hspan[10] = 2.;
    wlk_.hzero[10] = 3.;
    wlk_.sspan[10] = 0.;
    wlk_.szero[10] = 0.;
    wlk_.spspan[10] = 0.;
    wlk_.hspan[11] = 1.5;
    wlk_.hzero[11] = 2.;
    wlk_.sspan[11] = 0.;
    wlk_.szero[11] = 0.;
    wlk_.spspan[11] = 0.;
    for (i__ = 1; i__ <= 12; ++i__) {
	wlk_.tlast[i__ - 1] = 0.;
	wlk_.tnext[i__ - 1] = .1;
	wlk_.adist[i__ - 1] = wlk_.szero[i__ - 1];
	wlk_.bdist[i__ - 1] = 0.;
	wlk_.cdist[i__ - 1] = 0.;
	wlk_.ddist[i__ - 1] = 0.;
/* L550: */
    }
    *time = (float)0.;
    tefunc(nn, time, &yy[1], &yp[1]);
    return 0;
} /* teinit */

#undef isd


/* ============================================================================= */

/* Subroutine */static int tesub1_(doublereal *z__, doublereal *t, 
		doublereal *h__, const integer *ity)
{
    /* System generated locals */
    doublereal d__1;

    /* Local variables */
    integer i__;
    doublereal r__, hi;

    /* Parameter adjustments */
    --z__;

    /* Function Body */
    if (*ity == 0) {
	*h__ = 0.;
	for (i__ = 1; i__ <= 8; ++i__) {
/* Computing 2nd power */
	    d__1 = *t;
	    hi = *t * (const_.ah[i__ - 1] + const_.bh[i__ - 1] * *t / 2. + 
		    const_.ch[i__ - 1] * (d__1 * d__1) / 3.);
	    hi *= 1.8;
	    *h__ += z__[i__] * const_.xmw[i__ - 1] * hi;
/* L100: */
	}
    } else {
	*h__ = 0.;
	for (i__ = 1; i__ <= 8; ++i__) {
/* Computing 2nd power */
	    d__1 = *t;
	    hi = *t * (const_.ag[i__ - 1] + const_.bg[i__ - 1] * *t / 2. + 
		    const_.cg[i__ - 1] * (d__1 * d__1) / 3.);
	    hi *= 1.8;
	    hi += const_.av[i__ - 1];
	    *h__ += z__[i__] * const_.xmw[i__ - 1] * hi;
/* L200: */
	}
    }
    if (*ity == 2) {
	r__ = 3.57696e-6;
	*h__ -= r__ * (*t + (float)273.15);
    }
    return 0;
} /* tesub1_ */

/* Subroutine */static int tesub2_(doublereal *z__, doublereal *t, doublereal *h__, 
           const integer *ity)
{
    integer j;
    doublereal htest;
    doublereal dh;
    doublereal dt, err, tin;

    /* Parameter adjustments */
    --z__;

    /* Function Body */
    tin = *t;
    for (j = 1; j <= 100; ++j) {
	tesub1_(&z__[1], t, &htest, ity);
	err = htest - *h__;
	tesub3_(&z__[1], t, &dh, ity);
	dt = -err / dh;
	*t += dt;
/* L250: */
	if (abs(dt) < 1e-12) {
	    goto L300;
	}
    }
    *t = tin;
L300:
    return 0;
} /* tesub2_ */

/* Subroutine */static int tesub3_(doublereal *z__, doublereal *t, doublereal *dh, 
		   const integer *ity)
{
    /* System generated locals */
    doublereal d__1;

    /* Local variables */
    integer i__;
    doublereal r__, dhi;

    /* Parameter adjustments */
    --z__;

    /* Function Body */
    if (*ity == 0) {
	*dh = 0.;
	for (i__ = 1; i__ <= 8; ++i__) {
/* Computing 2nd power */
	    d__1 = *t;
	    dhi = const_.ah[i__ - 1] + const_.bh[i__ - 1] * *t + const_.ch[
		    i__ - 1] * (d__1 * d__1);
	    dhi *= 1.8;
	    *dh += z__[i__] * const_.xmw[i__ - 1] * dhi;
/* L100: */
	}
    } else {
	*dh = 0.;
	for (i__ = 1; i__ <= 8; ++i__) {
/* Computing 2nd power */
	    d__1 = *t;
	    dhi = const_.ag[i__ - 1] + const_.bg[i__ - 1] * *t + const_.cg[
		    i__ - 1] * (d__1 * d__1);
	    dhi *= 1.8;
	    *dh += z__[i__] * const_.xmw[i__ - 1] * dhi;
/* L200: */
	}
    }
    if (*ity == 2) {
	r__ = 3.57696e-6;
	*dh -= r__;
    }
    return 0;
} /* tesub3_ */

/* Subroutine */static int tesub4_(doublereal *x, doublereal *t, doublereal *r__)
{
    integer i__;
    doublereal v;

    /* Parameter adjustments */
    --x;

    /* Function Body */
    v = (float)0.;
    for (i__ = 1; i__ <= 8; ++i__) {
	v += x[i__] * const_.xmw[i__ - 1] / (const_.ad[i__ - 1] + (
		const_.bd[i__ - 1] + const_.cd[i__ - 1] * *t) * *t);
/* L10: */
    }
    *r__ = (float)1. / v;
    return 0;
} /* tesub4_ */

static int tesub5_(doublereal *s, doublereal *sp, doublereal *adist, doublereal *bdist, 
			doublereal *cdist, doublereal *ddist, doublereal *tlast, 
			doublereal *tnext, doublereal *hspan, doublereal *hzero, 
			doublereal *sspan, doublereal *szero, doublereal *spspan, 
			integer *idvflag)
{
    /* System generated locals */
    doublereal d__1;

    /* Local variables */
    doublereal h__;
    integer i__;
    doublereal s1;
    doublereal s1p;

    i__ = -1;
    h__ = *hspan * tesub7_(&i__) + *hzero;
    s1 = *sspan * tesub7_(&i__) * *idvflag + *szero;
    s1p = *spspan * tesub7_(&i__) * *idvflag;
    *adist = *s;
    *bdist = *sp;
/* Computing 2nd power */
    d__1 = h__;
    *cdist = ((s1 - *s) * 3. - h__ * (s1p + *sp * 2.)) / (d__1 * d__1);
/* Computing 3rd power */
    d__1 = h__;
    *ddist = ((*s - s1) * 2. + h__ * (s1p + *sp)) / (d__1 * (d__1 * d__1));
    *tnext = *tlast + h__;
    return 0;
} /* tesub5_ */

/* Subroutine */static int tesub6_(doublereal *std, doublereal *x)
{
    integer i__;

    *x = 0.;
    for (i__ = 1; i__ <= 12; ++i__) {
	*x += tesub7_(&i__);
    }
    *x = (*x - 6.) * *std;
    return 0;
} /* tesub6_ */

static doublereal tesub7_(integer *i__)
{
    /* System generated locals */
    doublereal ret_val, d__1, c_b78;

    d__1 = randsd_.g * 9228907.;
	c_b78 = 4294967296.;
    randsd_.g = d_mod(&d__1, &c_b78);
    if (*i__ >= 0) {
	ret_val = randsd_.g / 4294967296.;
    }
    if (*i__ < 0) {
	ret_val = randsd_.g * 2. / 4294967296. - 1.;
    }
    return ret_val;
} /* tesub7_ */

static doublereal tesub8_(const integer *i__, doublereal *t)
{
    /* System generated locals */
    doublereal ret_val;

    /* Local variables */
    doublereal h__;

    h__ = *t - wlk_.tlast[*i__ - 1];
    ret_val = wlk_.adist[*i__ - 1] + h__ * (wlk_.bdist[*i__ - 1] + h__ * (
	    wlk_.cdist[*i__ - 1] + h__ * wlk_.ddist[*i__ - 1]));
    return ret_val;
} /* tesub8_ */

#ifdef KR_headers
#ifdef IEEE_drem
double drem();
#else
double floor();
#endif
double d_mod(x,y) doublereal *x, *y;
#else
#ifdef IEEE_drem
double drem(double, double);
#else
#undef abs
#endif
double d_mod(doublereal *x, doublereal *y)
#endif
{
#ifdef IEEE_drem
	double xa, ya, z;
	if ((ya = *y) < 0.)
		ya = -ya;
	z = drem(xa = *x, ya);
	if (xa > 0) {
		if (z < 0)
			z += ya;
		}
	else if (z > 0)
		z -= ya;
	return z;
#else
	double quotient;
	if( (quotient = *x / *y) >= 0)
		quotient = floor(quotient);
	else
		quotient = -floor(-quotient);
	return(*x - (*y) * quotient );
#endif
}

#ifdef KR_headers
double pow();
double pow_dd(ap, bp) doublereal *ap, *bp;
#else
#undef abs
double pow_dd(doublereal *ap, const doublereal *bp)
#endif
{
return(pow(*ap, *bp) );
}



/*=============================*
 * Required S-function trailer *
 *=============================*/

#ifdef  MATLAB_MEX_FILE    /* Is this file being compiled as a MEX-file? */
#include "simulink.c"      /* MEX-file interface mechanism */
#else
#include "cg_sfun.h"       /* Code generation registration function */
#endif

