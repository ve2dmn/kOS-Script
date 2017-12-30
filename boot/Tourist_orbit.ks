Switch to 0.
CopyPath( "Launch4.ks", "1:/Launch4.ks").
CopyPath( "Orbit1.ks", "1:/Orbit1.ks").
CopyPath( "Land1.ks", "1:/Land1.ks").
CopyPath( "Burn_Function.ks", "1:/Burn_Function.ks").
Switch to 1.
WAIT 3.
RUN Launch4.ks.
RUN Orbit1.ks.
set kuniverse:timewarp:warp to 4.
kuniverse:timewarp:warpto(time:seconds + 3600).
WAIT 3.
RUN Land1.ks.
