/*	Copyright © 2015 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
 *	Copyright © 2015 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
 *	Copyright © 2015 TUHH-SVA Security in Distributed Applications.
 * 	All rights reserved.
 *	License: http://opensource.org/licenses/BSD-3-Clause
 *	---------------------------------------------------------------------
 */	

#include <simstruc.h>
#include <simstruc_types.h>
#include "prototypes.h"

#ifdef __PROTOTYPES_H__

void report(const char* message, SimStruct *S)
{
	ssPrintf("%f: %s (%s).\n", ssGetTime(S), message, SimState(S));
}

#ifdef __SS_SimStatus_Strings__

time_T ssGetTime(SimStruct *S)
{
	time_T time = 0.0;
	if(GetSimState(S) == SIMSTATUS_RUNNING)
		time = ssGetT(S);
	return time;
	
	// SIMSTATUS_STOPPED,
    // SIMSTATUS_UPDATING,
    // SIMSTATUS_INITIALIZING,
    // SIMSTATUS_RUNNING,
    // SIMSTATUS_PAUSED_IN_DEBUGGER,
    // SIMSTATUS_PAUSED,
    // SIMSTATUS_TERMINATING,

    // /* Must be last */
    // SIMSTATUS_EXTERNAL
}

int ssGetSimState(SimStruct *S)
{
	SS_SimStatus status;	
	ssGetSimStatus(S, &status);
	return status;
}

#endif /* __SS_SimStatus_Strings__ */

#endif /* __PROTOTYPES_H__ */