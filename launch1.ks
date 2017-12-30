/hellolaunch
    PRINT "Staging".
    STAGE.
    PRESERVE.
}.

SET MYSTEER TO HEADING(90,90).
    //For the initial ascent, we want our steering to be straight
    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 400 AND SHIP:VELOCITY:SURFACE:MAG < 500 {
    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 500 AND SHIP:VELOCITY:SURFACE:MAG < 600 {
    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 600 AND SHIP:VELOCITY:SURFACE:MAG < 700 {
    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 1000 AND SHIP:VELOCITY:SURFACE:MAG < 1200 {
    //Beyond 800m/s, we can keep facing towards 10 degrees above the horizon and wait

PRINT "100km apoapsis reached, cutting throttle".
//At this point, our apoapsis is above 100km and our main loop has ended. Next

WAIT UNTIL SHIP:ALTITUDE >70000.
CLEARSCREEN.

PRINT "Space reached Setting Pitch".
SET MYSTEER TO HEADING(90,0).

WAIT UNTIL SHIP:ALTITUDE >100000.
//Next, we'll lock our throttle to 100%.
LOCK THROTTLE TO 1.0.   // 1.0 is the max, 0.0 is idle.

UNTIL SHIP:PERIAPSIS > 99500 { //Remember, all altitudes will be in meters, not kilometers
}.

//This sets the user's throttle setting to zero to prevent the throttle
