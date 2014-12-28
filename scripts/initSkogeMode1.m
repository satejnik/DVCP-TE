% Copyright: N. L. Ricker, 12/98.  ricker@u.washington.edu

%control strategy described in 
%Self-Optimizing control of a large-scale plant:
%the Tennessee Eastman process" Larsson, T., et al., Ind. Eng.
%Chem. Res., Vol. 40, pp. 4889-4901, 2001.

% Skogestad strategy initialization, Mode 1

u0=[62.4160 52.3280 26.4403 59.9328 0 26.7475 36.7264 45.9852 0 35.5439 14.4569 100.0000];
    
for i=1:12;
    iChar=int2str(i);
    eval(['xmv',iChar,'_0=u0(',iChar,');']);
end

Fp_0=100;

r1_0=0.267/Fp_0;
r2_0=3657/Fp_0;
r3_0=4440/Fp_0;
r4_0=9.24/Fp_0;
r5_0=0.211/Fp_0;
r6_0=25.28/Fp_0;
r7_0=22.89/Fp_0;

Eadj_0=0;
SP17_0=91.7;

% Note:  The values of xmv_0 and r_0 specified above get overridden
%        by the initial conditions specified in the xInitial variable,
%        loaded in the following statement.  The above statements are
%        only needed when starting from a new condition where xInitial
%        doesn't apply.

load SkogeMode1xInitial

% TS_base is the integration step size in hours.  The simulink model
% is using a fixed step size (Euler) method.  Variable step-size methods
% don't work very well (high noise level).  TS_base is also the sampling
% period of most discrete PI controllers used in the simulation.
Ts_base=0.0005;
% TS_save is the sampling period for saving results.  The following
% variables are saved at the end of a run:
% tout    -  the elapsed time (hrs), length N.
% simout  -  the TE plant outputs, N by 41 matrix
% OpCost  -  the instantaneous operating cost, $/hr, length N
% xmv     -  the TE plant manipulated variables, N by 12 matrix
% idv     -  the TE plant disturbances, N by 20 matrix
Ts_save=0.01;
