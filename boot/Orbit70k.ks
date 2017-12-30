Switch to 0.
CopyPath( "LaunchEquator.ks", "1:/LaunchEquator.ks").
CopyPath( "Orbit1.ks", "1:/Orbit1.ks").
CopyPath( "Burn_Function.ks", "1:/Burn_Function.ks").
Switch to 1.
WAIT 3.
RUN LaunchEquator.ks.
RUN Orbit1.ks.

Shutdown.
