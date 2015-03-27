/*	Copyright © 2015 Alexander Isakov. Contact: <alexander.isakov@tuhh.de>
 *	Copyright © 2015 Marina Krotofil. Contact: <marina.krotofil@tuhh.de>
 *	Copyright © 2015 TUHH-SVA Security in Distributed Applications.
 * 	All rights reserved.
 *	License: http://opensource.org/licenses/BSD-3-Clause
 *	---------------------------------------------------------------------
 */	

/* Prototypes*/
#ifndef __PROTOTYPES_H__
#define __PROTOTYPES_H__

void report(const char* function, SimStruct *S);


#if defined(__SIMSTRUC_TYPES_H__) && !defined(__SS_SimStatus_Strings__)
#define __SS_SimStatus_Strings__

SS_SimStatus ssGetSimState(SimStruct *S);

#define GetSimState(S) ssGetSimState(S)

time_T ssGetTime(SimStruct *S);

#define GetTime(S) ssGetTime(S)

static const char *SS_SimStatus_Strings[] = {
	"SIMSTATUS_STOPPED",
    "SIMSTATUS_UPDATING",
    "SIMSTATUS_INITIALIZING",
    "SIMSTATUS_RUNNING",
    "SIMSTATUS_PAUSED_IN_DEBUGGER",
    "SIMSTATUS_PAUSED",
    "SIMSTATUS_TERMINATING",
    "SIMSTATUS_EXTERNAL"};

#define SimState(S) SS_SimStatus_Strings[GetSimState(S)]

#endif

#endif /* __PROTOTYPES_H__ */