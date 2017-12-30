//Based on hellolaunch
//First, we'll clear the terminal screen to make it look nice
CLEARSCREEN.

//set default value to 0 in case the script crashs
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
//Next, we'll lock our throttle to 100%.
LOCK THROTTLE TO 1.0.   // 1.0 is the max, 0.0 is idle.

SET TargetAltitude TO body:atm:height + 10000.
SET HorizontalAltitude TO body:atm:height - 20000.
SET GravCst TO KERBIN:MU / KERBIN:RADIUS^2.
SET TargetOrbitalSpeed TO 600000 * SQRT(GravCst/(600000+TargetAltitude)).
Set PitchingSteer to 90.
SET AdjustedThrottle TO 1.
SET SpeedPitch TO 90.
SET AltitudePitch TO 90.
SET FlamoutTrigger TO FALSE.

PRINT "TargetAltitude:" + TargetAltitude .
PRINT "TargetOrbitalSpeed:" + TargetOrbitalSpeed.


//This is a trigger that constantly checks to see if our thrust is zero.
WHEN MAXTHRUST = 0 THEN {

	PRINT "Staging due to No Thrust".
	STAGE.
	IF(AVAILABLETHRUST <= 0)
		RETURN FALSE.
	RETURN TRUE.
}.

//This is a Manual trigger that stages only if the flameout is not the last engine
WHEN FlamoutTrigger THEN {

	IF(MAXTHRUST = 0) //The other trigger will stage
		RETURN TRUE.
	SET FlamoutTrigger to FALSE.
	PRINT "Staging due to Flameout".
	STAGE.
	IF(AVAILABLETHRUST <= 0)
		RETURN FALSE.
	RETURN TRUE.
}


//This will be our main control loop for the ascent. It will
//cycle through continuously until our apoapsis is greater
//than TargetAltitude. 

LOCK SpeedPitch TO (100-(GROUNDSPEED/12)).
LOCK AltitudePitch TO (90 - ((SHIP:Altitude /HorizontalAltitude )*90)).

SET MYSTEER TO HEADING(90,90).
LOCK THROTTLE TO  AdjustedThrottle.
LOCK STEERING TO MYSTEER. // from now on we'll be able to change steering by just assigning a new value to MYSTEER
UNTIL SHIP:APOAPSIS > TargetAltitude { //Remember, all altitudes will be in meters, not kilometers
    //For the initial ascent, we want our steering to be straight
    //up and rolled due east

	IF  SHIP:ALTITUDE < 500 {
		SET PitchingSteer to AltitudePitch. //Below 500, be conservative
	}ELSE {
		SET PitchingSteer TO MIN(AltitudePitch,SpeedPitch).
		}


	IF PitchingSteer >90 SET PitchingSteer to 90.
	IF PitchingSteer <0 SET PitchingSteer to 0.

	set i TO 14.
	PRINT "Pitching to " + PitchingSteer + " degrees" AT(0,8).
	PRINT "APOAPSIS: " + ROUND(SHIP:APOAPSIS,0) AT (0,9).
	PRINT "Velocities " AT(0,10).
	PRINT "Ship Air Velocity:" + SHIP:AIRSPEED AT(0,11).
	PRINT "Ship Q     :" + SHIP:Q AT(0,12).
	PRINT "List of Engines" AT(0,13).
	set EngineFlameout TO false.
	list engines in engs.
	FOR eng IN engs {
		print " Activated: " +eng:IGNITION + " Flameout:" + eng:FLAMEOUT +" Engine ISP:" + eng:ISP AT(0,i).
		if(eng:FLAMEOUT){
		SET EngineFlameout to true.
		}
		SET i TO i+1.
	}.
	SET FlamoutTrigger TO EngineFlameout.
	PRINT "--------------------------------------------------------------------------------" AT(0,i).


	
    IF SHIP:VELOCITY:SURFACE:MAG < 100 {
	//This sets our steering 90 degrees up and yawed to the compass
		//heading of 90 degrees (east)
        SET MYSTEER TO HEADING(90,90).

    //Once we pass 100m/s, we want to pitch down
    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 100 {
        SET MYSTEER TO HEADING(90,PitchingSteer).
    } 


}.
CLEARSCREEN.
PRINT  TargetAltitude + "m apoapsis reached, cutting throttle".
