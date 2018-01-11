If (SHIP:PERIAPSIS > body:atm:height + 10000){
	Print "Already in orbit".
	Shutdown.
	}

Switch to 0.
CopyPath( "LaunchWParameters.ks", "1:/LaunchWParameters.ks").
CopyPath( "OrbitWParameters.ks", "1:/OrbitWParameters.ks").
CopyPath( "Burn_Function.ks", "1:/Burn_Function.ks").
CopyPath( "Orbit_Functions.ks", "1:/Orbit_Functions.ks").
CopyPath( "Match_inclination.ks", "1:/Match_inclination.ks").
Switch to 1.
WAIT 3.
SET Destination_Altitude to 80000.
RUN LaunchWParameters(Destination_Altitude).
RUN OrbitWParameters(Destination_Altitude).
RUN Match_inclination.ks.

Shutdown.