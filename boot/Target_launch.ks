If (SHIP:PERIAPSIS > body:atm:height + 1000){
	Print "Already in orbit".
	Shutdown.
	}
WAIT 3.

	
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

//Find Longitude of target Acending Node
SET Target_lan to TARGET:ORBIT:LAN.
SET Ship_lan to VECTORANGLE( SHIP:ORBIT:POSITION - SHIP:BODY:POSITION, SOLARPRIMEVECTOR ). //Position at KSC should be at 0.
SET sec_until_alignement to (Target_lan -  Ship_lan)/360  * 21600.  //60 seconds per 1 degree
If (sec_until_alignement<0) {set sec_until_alignement to sec_until_alignement + 21600.}

set kuniverse:timewarp:warp to 4.
kuniverse:timewarp:warpto(time:seconds + sec_until_alignement - 100).

WAIT 10.

UNTIL(kuniverse:timewarp:rate <2) {wait 1.}

Switch to 0.
CopyPath( "LaunchWParameters.ks", "1:/LaunchWParameters.ks").
CopyPath( "OrbitWParameters.ks", "1:/OrbitWParameters.ks").
CopyPath( "Burn_Function.ks", "1:/Burn_Function.ks").
CopyPath( "Orbit_Function.ks", "1:/Orbit_Function.ks").
CopyPath( "Match_orbits.ks", "1:/Match_orbits.ks").
Switch to 1.
WAIT 3.
SET Destination_Altitude to 80000.
RUN LaunchWParameters(Destination_Altitude,90 - TARGET:ORBIT:Inclination).
RUN OrbitWParameters(Destination_Altitude,90 - TARGET:ORBIT:Inclination).
RUN Match_orbits.ks.
Shutdown.
