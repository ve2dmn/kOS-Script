
//At this point, our apoapsis is above 80km and our main loop has ended. Next
//we'll make sure our throttle is zero and that we're pointed prograde
RUN ONCE Burn_Function.ks.

LOCK THROTTLE TO 0.
WAIT UNTIL SHIP:ALTITUDE >70000.
CLEARSCREEN.
PRINT "Space reached".

SET Burn TO NODE(TIME:SECONDS+ETA:APOAPSIS, 0, 0, 100).
ADD Burn.
UNTIL Burn:ORBIT:PERIAPSIS > 70000 {
	SET Burn:PROGRADE to Burn:PROGRADE+10.
//	PRINT "Burning dv:" +Burn:PROGRADE AT(0,16).
//	PRINT "Time for burn: " + MANEUVER_TIME(Burn:PROGRADE) AT(0,15).
}.

PRINT "Burning dv:" +Burn:PROGRADE AT(0,19).
SET BurnTime to MANEUVER_TIME(Burn:PROGRADE).
PRINT "Time for burn: " + BurnTime AT(0,20).
PRINT "HALF burn: " + (BurnTime/2) AT(0,21).

WAIT 1.

UNTIL ETA:APOAPSIS < (BurnTime/2){ 
	SET MYSTEER TO HEADING(90,0).
	PRINT "Vertcal Velocity:" + SHIP:VERTICALSPEED AT(0,18).
	PRINT "Time to Apoapsis:" + ETA:APOAPSIS AT(0,17).

}.
//Next, we'll lock our throttle to 100%.
LOCK THROTTLE TO 1.0.   // 1.0 is the max, 0.0 is idle.


UNTIL SHIP:PERIAPSIS > 70000 { //Remember, all altitudes will be in meters, not kilometers

	IF ETA:APOAPSIS < (BurnTime/2){
		 LOCK THROTTLE TO 1.0. 
	}
	ELSE {LOCK THROTTLE TO 0.}
	SET MYSTEER TO HEADING(90,0).
	SET BurnTime to MANEUVER_TIME(Burn:PROGRADE).
	PRINT "Time to Apoapsis:" + ETA:APOAPSIS AT(0,17).
	PRINT "Vertcal Velocity:" + SHIP:VERTICALSPEED AT(0,18).
	PRINT "Time for burn: " + BurnTime AT(0,20).
	PRINT "HALF burn: " + (BurnTime/2) AT(0,21).
}.

PRINT "70km periapsis reached, cutting throttle".
LOCK THROTTLE TO 0.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.