WAIT 10.

SET MYSTEER TO HEADING(270,0).
LOCK STEERING TO MYSTEER.
WAIT 5.

LOCK THROTTLE TO 1.0.

UNTIL SHIP:PERIAPSIS < 0 { //Remember, all altitudes will be in meters, not kilometers
SET MYSTEER TO HEADING(270,0).
}.

////////////////////////////////////

UNTIL SHIP:ALTITUDE < 70000 {
SET MYSTEER TO HEADING(270,0).
}.
SET MYSTEER TO HEADING(270,0).
Wait 10.
UNLOCK STEERING.

UNTIL SHIP:ALTITUDE < 2000 { 
	IF SHIP:VELOCITY:SURFACE:MAG < 100 {
	SET BRAKES TO true.
	SET GEAR TO true.
	SET CHUTES TO true.
	} ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 100 AND SHIP:VELOCITY:SURFACE:MAG < 450 {
			SET LIGHTS TO true.
	}
}
UNTIL SHIP:ALTITUDE < 850 { 
	IF SHIP:VELOCITY:SURFACE:MAG >= 200 {
	SET BRAKES TO true.
	SET GEAR TO true.
	SET CHUTES TO true.
	}
}

SET LIGHTS TO true.
SET BRAKES TO true.
SET GEAR TO true.
SET CHUTES TO true.
//This sets the user's throttle setting to zero to prevent the throttle
//from returning to the position it was at before the script was run.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

