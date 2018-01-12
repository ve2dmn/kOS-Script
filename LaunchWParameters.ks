
//Based on hellolaunch
//First, we'll clear the terminal screen to make it look nice
DECLARE PARAMETER TargetAltitude IS body:atm:height + 10000.
DECLARE PARAMETER Orientation IS 90.
CLEARSCREEN.

//set default value to 0 in case the script crashs
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
//Next, we'll lock our throttle to 100%.
LOCK THROTTLE TO 1.0.   // 1.0 is the max, 0.0 is idle.


SET HorizontalAltitude TO MAX(TargetAltitude - 25000,10000). // 50k on Kerbin or 7k on airless worlds
SET GravCst TO KERBIN:MU / KERBIN:RADIUS^2.
SET TargetOrbitalSpeed TO 600000 * SQRT(GravCst/(600000+TargetAltitude)).
Set PitchingSteer to 90.
SET AdjustedThrottle TO 1.
SET SpeedPitch TO 90.
SET AltitudePitch TO 90.
SET FlamoutTrigger TO FALSE.

PRINT "TargetAltitude:" + TargetAltitude + " Inclination:" + Orientation.
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

	set i TO 8.
	PRINT "Pitching to " + PitchingSteer + " degrees" AT(0,i).
	PRINT "APOAPSIS: " + ROUND(SHIP:APOAPSIS,0) AT (0,i+1).
	PRINT "Velocities " AT(0,i+2).
	PRINT "Ship Air Velocity:" + SHIP:AIRSPEED AT(0,i+3).
	PRINT "Ship Q     :" + SHIP:Q AT(0,i+4).
	set EngineFlameout TO false.
	list engines in engs.
	FOR eng IN engs {
		if(eng:FLAMEOUT){
		SET EngineFlameout to true.
		}
	}.
	SET FlamoutTrigger TO EngineFlameout.
	PRINT "--------------------------" AT(0,i+6).


	
    IF SHIP:VELOCITY:SURFACE:MAG < 100 {
	//This sets our steering 90 degrees up and yawed to the compass
		//heading of 90 degrees (east), by default.
        SET MYSTEER TO HEADING(Orientation,90).

    //Once we pass 100m/s, we want to pitch down
    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 100 {
        SET MYSTEER TO HEADING(Orientation,PitchingSteer).
    } 


}.
CLEARSCREEN.
PRINT  TargetAltitude + "m apoapsis reached, cutting throttle".
