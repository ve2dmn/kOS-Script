Switch to 0.
CopyPath( "LaunchWParameters.ks", "1:/LaunchWParameters.ks").
CopyPath( "OrbitWParameters.ks", "1:/OrbitWParameters.ks").
CopyPath( "Burn_Function.ks", "1:/Burn_Function.ks").
Switch to 1.
WAIT 3.
SET Destination_Altitude to 350000.
RUN LaunchWParameters(Destination_Altitude).
RUN OrbitWParameters(Destination_Altitude).

Shutdown.
