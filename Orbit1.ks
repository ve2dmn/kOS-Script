
//At this point, our apoapsis is above 100km and our main loop has ended. Next
//we'll make sure our throttle is zero and that we're pointed prograde
LOCK THROTTLE TO 0.
WAIT UNTIL SHIP:ALTITUDE >70000.
CLEARSCREEN.
PRINT "Space reached Setting Pitch".
UNTIL SHIP:VERTICALSPEED <150 { 
	SET MYSTEER TO HEADING(90,PitchingSteer).
	PRINT "Vertcal Velocity:" + SHIP:VERTICALSPEED AT(0,18).
	Set PitchingSteer TO -(SHIP:VERTICALSPEED)/10.
}.
//Next, we'll lock our throttle to 100%.
LOCK THROTTLE TO 1.0.   // 1.0 is the max, 0.0 is idle.


UNTIL SHIP:PERIAPSIS > 70000 { //Remember, all altitudes will be in meters, not kilometers
	SET MYSTEER TO HEADING(90,PitchingSteer).
	PRINT "Vertcal Velocity:" + SHIP:VERTICALSPEED AT(0,18).
	Set PitchingSteer TO -(SHIP:VERTICALSPEED)/10.
}.

PRINT "70km periapsis reached, cutting throttle".
LOCK THROTTLE TO 0.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.