//Match Orbit and Rendez-vous Script

RUN ONCE Orbit_Functions.ks.
RUN ONCE Burn_Function.ks.

//@@@TODO: IF relative inclination > 0.5 , run Match inclination script.


//Debug Output
SET PEArrow TO VECDRAWARGS(
      SHIP:BODY:POSITION,  
       V(0,0,0),
      MAGENTA,
      "Vector to PE",
      1.0,
      FALSE,
      0.2
    ).
SET APArrow TO VECDRAWARGS(
      SHIP:BODY:POSITION,  
       V(0,0,0),
      CYAN,
      "Vector to AP",
      1.0,
      FALSE,
      0.2
    ).

CLEARSCREEN.
PRINT "Trying to Match orbit of target".
SET Waittime to TIME:SECONDS + 20.
UNTIL (HASTARGET ){
	PRINT "WAITING FOR TARGET " AT(0,2).
	IF(TIME:SECONDS > Waittime){
		PRINT "NO TARGET. SHUTDOWN " AT (0,2).
		SHUTDOWN.
	}

}

PRINT "TARGET ACQUIRED" AT(0,2).

//Find PE of Target.
LOCAL TIME_at_PE IS (360 -TARGET:ORBIT:MEANANOMALYATEPOCH)/360 *(TARGET:ORBIT:PERIOD) + TARGET:ORBIT:EPOCH.
LOCAL Vector_to_PE IS POSITIONAT(TARGET,TIME_at_PE) - TARGET:BODY:POSITION.
LOCAL Vector_to_AP IS -Vector_to_PE.

LOCAL SHIP_SOI_POSITION IS SHIP:POSITION - SHIP:BODY:POSITION.

LOCAL Angle_to_AP TO VECTORANGLE( SHIP_SOI_POSITION, Vector_to_AP).
LOCAL Check_if_AP IS VECTORDOTPRODUCT(SHIP:BODY:UP:UPVECTOR,VECTORCROSSPRODUCT(SHIP_SOI_POSITION, Vector_to_AP)).
IF(Check_if_AP > 0) {set Angle_to_AP to 360 - Angle_to_AP. }


LOCAL TIME_to_nodeAP IS Seconds_To_MAnomaly(Angle_to_AP + Mean_Anormality_at_t()).

LOCAL SHIP_PE_Vector IS POSITIONAT(SHIP,TIME:SECONDS+TIME_to_nodeAP) -  SHIP:BODY:POSITION.
LOCAL SHIP_AP_Vector IS Vector_to_PE.



//Characteristics of the new orbit
LOCAL SMA IS (SHIP_PE_Vector:MAG + SHIP_AP_Vector:MAG)/2.
LOCAL FUTUR_SPEED_AT_PE IS SQRT( SHIP:BODY:MU *  (2/ SHIP_PE_Vector:MAG  - 1/ SMA)).
LOCAL CUR_SPEED_AT_PE IS VELOCITYAT(SHIP,TIME:SECONDS+TIME_to_nodeAP):ORBIT:MAG.

SET Burn TO NODE(TIME:SECONDS+TIME_to_nodeAP, 0, 0,FUTUR_SPEED_AT_PE - CUR_SPEED_AT_PE ).
ADD Burn.

//WARP TO nODE

//Execute Node
Execute_Node().
/////////////////////////

