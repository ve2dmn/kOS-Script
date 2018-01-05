//Match Orbit and Rendez-vous Script

RUN ONCE Orbit_Function.ks.

CLEARSCREEN.
PRINT "Trying to Match orbit of target".
SET Waittime to TIME:SECONDS + 20.
WHILE (not HASTARGET ){
	PRINT "WAITING FOR TARGET " AT(0,2).
	IF(TIME:SECONDS > Waittime){
		PRINT "NO TARGET. SHUTDOWN "(0,2).
		SHUTDOWN.
	}

}

PRINT "TARGET ACQUIRED". AT(0,2).

//Get Time to Acending/Descending node



//Put New Maneouver Node at Acending/Decending node.

//Wait for node.

//Execute node.

/////////////////////////

