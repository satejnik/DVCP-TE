*** NOTE:  See updates at end of file ***

Contents of this Zip archive:

temex.c         C source code for compiling TEMEX mex file.
teprob.h        C header file needed when compiling.
temex.dll       Mex file ready for use on a Windows machine.  It was compiled
                and built using MS Visual C++ and tested in MATLAB release 11.
temex.mex       Mex file ready for use on a PowerMac.  It was built using
                the MPW MrC compiler and tested in MATLAB 5.2.1.
te_test.mdl	    Simulink model illustrating use of the TE challenge process
                simulation.
teplot.m        Script that plots the results at the end of a simulation.

System Requirements:

Matlab Version 5.2 or higher, with Simulink version 2 or higher.

Installation:

1) Unzip the archive into a new directory.  If you are on a Windows computer, you may
delete temex.mex.  If you are on a PowerMac you may delete temex.dll.  Otherwise
you may delete both the .mex and .dll files.

2) Start MATLAB and make the new directory the default.

3) If you are using a system other than Windows or PowerMac, you must now compile
and build the code.  You will need a C compiler (probably already installed if 
you're using a Unix machine).  If you have one, type the following
in the MATLAB command window:

mex temex.c

If all goes well, after a short delay the compiled-and-built mex file will be
in the default directory (verify this). You may see a couple of warning messages 
during the compile step, but you can ignore them (unless they are errors 
rather than warnings).

If you have trouble with the compile & build, make sure you have a C compiler approved 
for use with MATLAB c-mex files, and that it is set up properly.  See MATLAB's 
"Application Program Interface Guide" (available on-line in PDF format) for more details.

Testing the code:

4) In the MATLAB command window type "te_test" to bring up a Simulink window 
containing the example.  (This assumes that the directory created in step 1 is 
still the MATLAB default).

5) Start the simulation.  The initial condition is the base case defined in
the Downs and Vogel paper. Since the TE challenge process is open-loop unstable,
however, and the steady state is inexact (due to model complexity) the plant will 
eventually exhibit a transient.  After approximately 2 hours (simulated time) the
reactor pressure will exceed the upper bound of 3000 kPa and the plant will shut
down.  You should see a message to that effect in the MATLAB command window.  The
variables will be plotted (the format of this depends on whether or not you
have the MPC Tools).

Using the code:

The code is a standard Simulink s-function.  It's easiest to run as a block in 
a graphical diagram -- as in the example.  You can also run it from the MATLAB
command line, however.  See the Simulink documentation for general information
on s-functions and their use.

The block requires the following input data:

A) Parameters
-------------------------------------------------------------------------------------

The s-function requires two parameters (double-click on the example temex block to
see how these were defined):

1)  Initial states of the TE process.  Must be a vector, length 50.  If empty
(as in the example), the Downs and Vogel base case values are used.

2)  Disturbance codes.  Must be a vector, length 20.  These are the 
20 disturbances IDV(1) ... IDV(20) defined by Downs and Vogel.  If a 
disturbance code is zero, that disturbance is turned off.  Otherwise it is on.
(All were off in the example).  You may change these during a simulation if
you wish.  Either pause the simulation and change them manually or set up a
MATLAB script to do so at pre-defined times.

B) Input signals.
-------------------------------------------------------------------------------------

These are the 12 manipulated variables (MVs) defined by Downs 
and Vogel.  The example has the base-case values in a vector.  It adds another
vector which is defined as zero but could be used to introduce a step in one
or more MVs.

C) Output Signals
-------------------------------------------------------------------------------------

The block outputs are the 41 measured variables defined by Downs and Vogel.  Note
that the first 22 are measured continuously, and the rest are sampled composition
analyses from chromatographs.  The latter will exhibit discrete steps as
a new sample becomes available (at intervals of 0.1 or 0.25 hours, depending
on the signal).

-------------------------------------------------------------------------------------

In the example the outputs are being logged to the MATLAB workspace so they can
be plotted when the simulation ends (on a 266 Mh Pentium-II the 2-hour simulation 
requires about 6 seconds of computing time).  In general you could feed back some
or all of the measurements to MV adjustments.  A number of control strategies
have been proposed in the literature.

If you have difficulty with the installation or the mex code doesn't seem to 
give correct answers, please send a note to N L Ricker with full details:

ricker@u.washington.edu

=====================================================================================
=====================================================================================

Update 25 February 2002:

Changes to the following files:

temex.c         C source code for compiling TEMEX mex file.  This is now
                compatible with MATLAB 6.5 (Release 13).  The main change is
                that the input is defined as including a direct feedthrough
                to the output.  This eliminates segmentation errors that
                occurred when using the original.

temex.dll       Mex file ready for use on a Windows machine.  It is compatible
                with MATLAB 6.5 (Release 13).

temex.c.v5      Original version of temex.c (works with earlier Matlab releases)

temex.dll.v5    Original version of temex.dll (works with earlier MATLAB releases).


=====================================================================================

Update 2 December 2002:

Added files:

temexd.c        As for temex.c, but disturbances are input variables rather than
                parameters.  See "MultiLoop_mode1.mdl" for an example use.
                
temexd.dll      Mex file version of temexd.c for use on a Windows machine.  It is
                compatible with MATLAB 6.5 (Release 13).
                
MultiLoop_mode1.mdl     
				Simulink model of the control strategy described in

                "Decentralized control of the Tennessee Eastman Challenge
                Process", N. L. Ricker, J. Proc. Cont., Vol. 6, No. 4, 
                pp. 205-221, 1996. 
				
				It is set up to initialize and run with
                constant setpoints at the "Mode 1" operating condition.
				NOTE: override loops are not included.  
                
                The .mdl file calls two custom scripts (lines 34 and 35):
                
                    PreLoadFcn        "Mode_1_Init"
                    StopFcn           "TEplot"

                These initialize the simulation variables and plot the results
                at the end of the run.  See the files "Mode_1_Init.m" and
                "TEplot.m" for more details.
                               
MultiLoop_Skoge_mode1.mdl
				Similar to above, but uses the control strategy 
                described in 
				
				"Self-Optimizing control of a large-scale plant:
                the Tennessee Eastman process" Larsson, T., et al., Ind. Eng.
                Chem. Res., Vol. 40, pp. 4889-4901, 2001.
                
                It automatically runs "Skoge_Mode1_Init.m" and "TEplot.m".

Mode_1_Init.m   Script file executed automatically at beginning of 
                "MultiLoop_mode1.mdl".  See above discussion.
                
Skoge_Mode1_Init.m      As above, but for "MultiLoop_Skoge_mode1.mdl".

Mode1xInitial.mat       Contains initial conditions for "MultiLoop_model.mdl".
                It is loaded by the script file "Mode_1_Init.m", which is 
                executed automatically when the model is opened.
                
Mode1SkogeInit.mat      As above, but for "MultiLoop_Skoge_mode1.mdl".

TElib.mdl       A Simulink library containing two controller blocks.  These are
                used in the two "MultiLoop" simulations.
                
Remarks:

1.  The simulation uses a fixed step size ODE integration algorithm.  I have 
    found that variable step size methods work poorly in this application.
    
2.  If you get a "file not found" or "variable undefined" error from MATLAB, 
    make sure the initialization scripts described above are on the MATLAB
    path.  The simplest approach is to put all of the above files in a 
    single directory, and make it the MATLAB default directory.


=====================================================================================

Update 29 September 2003:

Added files:

R12_ExampleScript.m  Shows how to run simulations from the command line.

R12_tesys.mdl        Simulink model of the original TE plant.  This version
                     is saved in MATLAB Release 12 (Simulink 4.1)
                     format.  See also tesys.mdl, saved in Release 13 (Simulink 5.0)
                     format.  You will need one of these when running R12_ExampleScript.m.
                     If you wish to use the older version, rename it to tesys.mdl before
                     running the script.


=====================================================================================

Update 24 February 2005:

Added files:

MultiLoop_mode3.mdl  Similar to MultiLoop_mode1.mdl, but designed to run at
                     Mode 3 conditions.  Includes an additional override
					that reduces the recycle valve % open when the 
                     separator coolant valve goes above 90%.  If this
                     is not included, the coolant valve saturates and
                     the system loses control of reactor level.

Mode_3_Init.m        Initial model states needed for the above.

Mode3xInitial.mat    Contains initial conditions for "MultiLoop_mode3.mdl".
                     It is loaded by the script file "Mode_3_Init.m", which is 
                     executed automatically when the model is opened.


=====================================================================================
Modi

Mode 	G/H mass ratio 		Producti rate (stream 11)
1 		50/50 				7038 kg h-1G and 7038 kg h-‘H (base case)
2 		10/90 				1408 kg h-r G and 12,669 kg h-’ H
3 		90/10 				lO,OOOkgh-‘G and 1111 kgh-‘H
4 		50/50 				maximum production rate
5 		10/90 				maximum production rate
6 		90/10 				maximum production rate

=====================================================================================
Process maniuulated variables (XMV)
Variable name							Variable number		Base case value (%)		Low limit		High Limit
D feed flow @tram 2) 					XMV (1)				63,053					0				5811
E feed flow (stream 3) 					XMV (2)				53,980					0				8354
A feed flow (stream 1) 					XMV (3)				24,644					0				1,017
A and C feed flow (stream 4) 			XMV (4)				61,302					0				15,25
Compressor recycle valve 				XMV (5)				22,210					0				100
Purge valve (stream 9) 					XMV (6)
Separator pot liquid flow (stream 10)	XMV (7)
Stripper liquid product flow (stream 11)XMV (8)
Stripper steam valve 					XMV (9)
Reactor cooling water flow 				XMV (10)
Condenser cooling water flow 			XMV (11)
Agitator sueed 							XMV (12)

=====================================================================================
Continuous process mcasurcrnents

Variable name							Variable number			Base case value			Units		Low Limit	High Limit
A feed (stream 1) 						XMEAS (1)				0.25052
D feed (stream 2) 						XMEAS (2)				3664.0
E feexl (strcam 3) 						XMEAS (3)				4509.3
A and C feed (stream 4) 				XMEAS (4)				9.3477
Recycle flow (stream 8) 				XMEAS (5)				26.902
Reactor feed rate (stream 6) 			XMEAS (6)				42.339
Reactor pressure 						XMEAS (7)				2705.0					kPa gauge				3000 kPa
Reactor level 							XMEAS (8)
Reactor anperature 						XMBAS (9)
Purge rate (stream 9) 					XMEAS (IO)
Product separator temperature 			XMEAS (11)
Product separator level 				XMEAS (12)
Product separator pressure 				XMEAS (13)
Product separator underflow (stream 10) XMBAS (14)
stripper level XMEAS (15)
stripper pressure XMEAS (16)
Stripper underflow (stream 11) XMEAS (17)
stripper temperature XMBAS (18)
strippx steam dew XMEAS (19)
Compressor work XMEAS (20)
Reactor coolinn water outlet ten-merature XMEAS (21)
separator cooling water outlet te~peratnre XMEAS i22j 77.297

75.000
120.40
0.33712
80.109
50.000
2633.7
25.160
50.000
3102.2
22.949
65.731
230.31
341.43
94.599
Table 5. Sanmkd ur-8 tneasurernents
k- &aus=
%
“C
kscmb
‘C
%
k- &au=
In’ h-1
%
kPa gauge
m3lI-’
“C
kg h-’
kW
“C