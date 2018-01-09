//Match Orbit and Rendez-vous Script

RUN ONCE Orbit_Functions.ks.
RUN ONCE Burn_Function.ks.

//Debug Output
SET anArrow TO VECDRAWARGS(
      SHIP:BODY:POSITION,  
       V(0,0,0),
      MAGENTA,
      "Vector_to_AN",
      1.0,
      FALSE,
      0.2
    ).
SET dnArrow TO VECDRAWARGS(
      SHIP:BODY:POSITION,  
       V(0,0,0),
      CYAN,
      "Vector_to_DN",
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


//Get Vector to Acending/Descending node
LOCAL Vector_to_AN TO Find_Acending_Vector(TARGET):NORMALIZED.
LOCAL Vector_to_DN TO Find_Acending_Vector(TARGET,SHIP,TRUE):NORMALIZED.
LOCAL SHIP_SOI_POSITION IS SHIP:POSITION - SHIP:BODY:POSITION.
SET SHIP_SOI_POSITION TO SHIP_SOI_POSITION:NORMALIZED.
LOCAL Ship_normal IS VECTORCROSSPRODUCT(SHIP_SOI_POSITION, SHIP:VELOCITY:ORBIT):NORMALIZED.
LOCAL Check_if_AN IS VECTORDOTPRODUCT(SHIP:BODY:UP:UPVECTOR,VECTORCROSSPRODUCT(SHIP_SOI_POSITION, Vector_to_AN)).
LOCAL Angle_to_AN TO VECTORANGLE( SHIP_SOI_POSITION, Vector_to_AN).
LOCAL Angle_to_DN TO VECTORANGLE( SHIP_SOI_POSITION, Vector_to_DN).


//Debug Output
SET anArrow:Start TO  SHIP:BODY:POSITION.
SET anArrow:VEC TO Vector_to_AN*1000000.
SET anArrow:SHOW TO TRUE.

SET dnArrow:Start TO  SHIP:BODY:POSITION.
SET dnArrow:VEC TO Vector_to_DN*1000000.
SET dnArrow:SHOW TO TRUE.



PRINT "Vector_to_AN:"+ Vector_to_AN AT(0,3).
PRINT "Vector_to_DN:" +Vector_to_DN AT(0,4).
PRINT "Ship_normal:"+ Ship_normal AT(0,5).
PRINT "Check_if_AN:" + Check_if_AN AT(0,6).

PRINT "Angle_to_AN:"+ Angle_to_AN AT(0,8).
PRINT "Angle_to_DN:"+ Angle_to_DN AT(0,9).


IF(Check_if_AN <0){
	SET Angle_to_AN TO  360 -Angle_to_AN.
} ELSE {
	SET Angle_to_DN TO  360-Angle_to_DN.
}


//Get Time to Acending/Descending node
LOCAL TIME_to_nodeAN IS Seconds_To_MAnomaly(Angle_to_AN + Mean_Anormality_at_t()).
LOCAL TIME_to_nodeDN IS Seconds_To_MAnomaly(Angle_to_DN + Mean_Anormality_at_t()).
LOCAL TIME_to_nodeAN2 IS Seconds_To_TAnomaly(Angle_to_AN + SHIP:ORBIT:TRUEANOMALY).
LOCAL TIME_to_nodeDN2 IS Seconds_To_TAnomaly(Angle_to_DN + SHIP:ORBIT:TRUEANOMALY).



//Debug Output
PRINT "Angle_to_AN:"+ Angle_to_AN AT(0,10).
PRINT "Angle_to_DN:"+ Angle_to_DN AT(0,11).
PRINT "SHIP:ORBIT:TRUEANOMALY:" + SHIP:ORBIT:TRUEANOMALY AT(0,12)..
PRINT "TIME_to_node1:"+ TIME_to_nodeAN AT(0,13).
PRINT "TIME_to_node2:"+ TIME_to_nodeDN AT(0,14).
PRINT "TIME_to_node1TA:"+ TIME_to_nodeAN2 AT(0,15).
PRINT "TIME_to_node2TA:"+ TIME_to_nodeDN2 AT(0,16).



IF (TIME_to_nodeAN < TIME_to_nodeDN){
	SET Burn TO NODE(TIME:SECONDS+TIME_to_nodeAN, 0, 0, 1).
	ADD Burn.
	SET Burn:NORMAL to  - 2*VELOCITYAT(SHIP,TIME:SECONDS+TIME_to_nodeAN):ORBIT:MAG  * SIN(Find_degree_Orbits(Target) * 0.5).
} ELSE {
	SET Burn TO NODE(TIME:SECONDS+TIME_to_nodeDN, 0, 0, 1).
	ADD Burn.
	SET Burn:NORMAL to  2*VELOCITYAT(SHIP,TIME:SECONDS+TIME_to_nodeDN):ORBIT:MAG  * SIN(Find_degree_Orbits(Target) * 0.5).
}



//Wait for node.
//SET BurnTime to MANEUVER_TIME(Burn:DELTAV).
//PRINT "Time for burn: " + BurnTime.
//PRINT "HALF burn: " + (BurnTime/2).


//Execute node.
//Execute_Node().

/////////////////////////

