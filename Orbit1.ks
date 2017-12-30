
//At this point, our apoapsis is above 80km and our main loop has ended. Next
//we'll make sure our throttle is zero and that we're pointed prograde
RUN ONCE Burn_Function.ks.

LOCK THROTTLE TO 0.

PRINT "Time for a 100m/s burn: " + MANEUVER_TIME(100).
PRINT "Time for a 200m/s burn: " + MANEUVER_TIME(200).
PRINT "Time for a 300m/s burn: " + MANEUVER_TIME(300).
PRINT "Time for a 400m/s burn: " + MANEUVER_TIME(400).
PRINT "Time for a 500m/s burn: " + MANEUVER_TIME(500).
PRINT "Time for a 1000m/s burn: " + MANEUVER_TIME(1000).


WAIT UNTIL SHIP:ALTITUDE >70000.
CLEARSCREEN.
PRINT "Space reached".

SET Burn TO NODE(TIME:SECONDS+ETA:APOAPSIS, 0, 0, 100).
ADD Burn.
UNTIL Burn:ORBIT:PERIAPSIS > 80000 {
	SET Burn:PROGRADE to Burn:PROGRADE+10.
	IF Burn:ORBIT:APOAPSIS > (SHIP:APOAPSIS + 5000) { Break.}
//	PRINT "Burning dv:" +Burn:PROGRADE AT(0,16).
//	PRINT "Time for burn: " + MANEUVER_TIME(Burn:PROGRADE) AT(0,15).
}.
SET MYSTEER TO Burn:BURNVECTOR.
LOCK STEERING TO MYSTEER.
PRINT "Burning dv:" +Burn:PROGRADE AT(0,19).
SET BurnTime to MANEUVER_TIME(Burn:PROGRADE).
PRINT "Time for burn: " + BurnTime AT(0,20).
PRINT "HALF burn: " + (BurnTime/2) AT(0,21).

WAIT 5.

UNTIL Burn:ETA < (BurnTime/2){ 
	SET MYSTEER TO Burn:BURNVECTOR.
	PRINT "Vertcal Velocity:" + SHIP:VERTICALSPEED AT(0,18).
	PRINT "Time to Apoapsis:" + ETA:APOAPSIS AT(0,17).

}.
//Next, we'll lock our throttle to 100%.
LOCK THROTTLE TO 1.0.   // 1.0 is the max, 0.0 is idle.


UNTIL SHIP:PERIAPSIS > 75000 { //Remember, all altitudes will be in meters, not kilometers

	IF Burn:ETA < (BurnTime/2){
		 LOCK THROTTLE TO 1.0. 
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
	PRINT "Time to Apoapsis:" + ETA:APOAPSIS AT(0,17).
	PRINT "Vertcal Velocity:" + SHIP:VERTICALSPEED AT(0,18).
	PRINT "Time for burn: " + BurnTime AT(0,20).
	PRINT "HALF burn: " + (BurnTime/2) AT(0,21).
}.

PRINT "70km periapsis reached, cutting throttle".
LOCK THROTTLE TO 0.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.