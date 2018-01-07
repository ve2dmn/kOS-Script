

//Remember, all altitudes will be in meters, not kilometers
DECLARE PARAMETER TargetAltitude IS body:atm:height + 10000. 
DECLARE PARAMETER Orientation IS 90.

RUN ONCE Burn_Function.ks.

LOCK THROTTLE TO 0.

PRINT "Time for a 100m/s burn: " + MANEUVER_TIME(100).
PRINT "Time for a 200m/s burn: " + MANEUVER_TIME(200).
PRINT "Time for a 300m/s burn: " + MANEUVER_TIME(300).
PRINT "Time for a 400m/s burn: " + MANEUVER_TIME(400).
PRINT "Time for a 500m/s burn: " + MANEUVER_TIME(500).
PRINT "Time for a 1000m/s burn: " + MANEUVER_TIME(1000).

SET FlamoutTrigger TO FALSE.







WAIT UNTIL SHIP:ALTITUDE > body:atm:height.
CLEARSCREEN.
PRINT "Space reached".

SET Burn TO NODE(TIME:SECONDS+ETA:APOAPSIS, 0, 0, 100).
ADD Burn.
UNTIL Burn:ORBIT:PERIAPSIS > TargetAltitude {
	SET Burn:PROGRADE to Burn:PROGRADE+10.
	IF Burn:ORBIT:APOAPSIS > (SHIP:APOAPSIS + 5000) { Break.}
}.
SET MYSTEER TO Burn:BURNVECTOR.
LOCK STEERING TO MYSTEER.
PRINT "SHIP:MAXTHRUST : " + SHIP:MAXTHRUST AT(0,2).
PRINT "Burning dv:" +Burn:PROGRADE AT(0,3).
WAIT 3.
SET BurnTime to MANEUVER_TIME(Burn:PROGRADE).
PRINT "Time for burn: " + BurnTime AT(0,4).
PRINT "HALF burn: " + (BurnTime/2) AT(0,5).

PANELS ON.
RADIATORS ON.

UNTIL Burn:ETA < (BurnTime/2){ 
	SET MYSTEER TO Burn:BURNVECTOR.
	PRINT "Vertcal Velocity:" + SHIP:VERTICALSPEED AT(0,6).
	PRINT "Time to Apoapsis:" + ETA:APOAPSIS AT(0,7).

}.
//Next, we'll lock our throttle to 100%.
LOCK THROTTLE TO 1.0.   // 1.0 is the max, 0.0 is idle.

UNTIL SHIP:PERIAPSIS > TargetAltitude * 0.95 { 

	IF Burn:ETA < (BurnTime/2){
		 LOCK THROTTLE TO 1.0.
		set EngineFlameout TO false.
		list engines in engs.
		FOR eng IN engs {
			if(eng:FLAMEOUT){
				SET EngineFlameout to true.
			}
		}.
		SET FlamoutTrigger TO EngineFlameout.
	}
	ELSE {LOCK THROTTLE TO 0.}

	IF BurnTime < 5 {
		UNLOCK STEERING.
		SAS ON.
		}
	ELSE {
		SET MYSTEER TO Burn:BURNVECTOR.
		}
	
	SET BurnTime to MANEUVER_TIME(Burn:PROGRADE).
	PRINT "Time to Apoapsis:" + ETA:APOAPSIS AT(0,9).
	PRINT "Vertcal Velocity:" + SHIP:VERTICALSPEED AT(0,10).
	PRINT "Time for burn: " + BurnTime AT(0,11).
	PRINT "HALF burn: " + (BurnTime/2) AT(0,12).
}.

PRINT "70km periapsis reached, cutting throttle".
LOCK THROTTLE TO 0.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
removeAllNodes().