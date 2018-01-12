FUNCTION removeAllNodes
{
  UNTIL NOT HASNODE { REMOVE NEXTNODE. WAIT 0. }
}

///////////////////////
//Based on code avaialable here:
//https://www.reddit.com/r/Kos/comments/3ftcwk/compute_burn_time_with_calculus/

// Calculate the burn time to complete a burn of a fixed Δv

// Base formulas:
// Δv = ∫ F / (m0 - consumptionRate * t) dt
// consumptionRate = F / (Isp * g)
// ∴ Δv = ∫ F / (m0 - (F * t / g * Isp)) dt

// Integrate:
// ∫ F / (m0 - (F * t / g * Isp)) dt = -g * Isp * log(g * m0 * Isp - F * t)
// F(t) - F(0) = known Δv
// Expand, simplify, and solve for t

FUNCTION MANEUVER_TIME {
  PARAMETER dV.

  LIST ENGINES IN engs.

  LOCAL f IS SHIP:MAXTHRUST * 1000.  // Engine Thrust (kg * m/s²)
  LOCAL m IS SHIP:MASS * 1000.        // Starting mass (kg)
  LOCAL e IS CONSTANT():E.            // Base of natural log
  LOCAL g IS KERBIN:MU / KERBIN:RADIUS^2.    // Gravitational acceleration constant (9.80665m/s²)

  LOCAL TotalFuelFlow IS 0.
	FOR eng IN engs {
		if(eng:IGNITION and eng:AVAILABLETHRUST >0.1){
			SET TotalFuelFlow to TotalFuelFlow + (eng:ISP / MAX(eng:AVAILABLETHRUST, 1)).
		}
	}.
  LOCAL p IS SHIP:MAXTHRUST/MAX(0.0000001,TotalFuelFlow).  // Engine ISP(s)

  RETURN g * m * p * (1 - e^(-dV/ MAX(0.0000001,(g*p)))) / f.
}.

//PRINT "Time for a 100m/s burn: " + MANEUVER_TIME(100).
//PRINT "Time for a 200m/s burn: " + MANEUVER_TIME(200).
//PRINT "Time for a 300m/s burn: " + MANEUVER_TIME(300).
//PRINT "Time for a 400m/s burn: " + MANEUVER_TIME(400).
//PRINT "Time for a 500m/s burn: " + MANEUVER_TIME(500).
//PRINT "Time for a 1000m/s burn: " + MANEUVER_TIME(1000).

////////////////
//Taken from
//https://ksp-kos.github.io/KOS/tutorials/exenode.html

FUNCTION Execute_Node {

PARAMETER nd IS nextnode.

//print out node's basic parameters - ETA and deltaV
print "Node in: " + round(nd:eta) + ", DeltaV: " + round(nd:deltav:mag).

//calculate ship's max acceleration
set max_acc to ship:maxthrust/ship:mass.


// get the estimated time of the burn.
//
set burn_duration to MANEUVER_TIME(nd:deltav:mag).

set np to nd:deltav. //points to node, don't care about the roll direction.
lock steering to np.


wait until nd:eta <= (burn_duration/2 + 60).


//now we need to wait until the burn vector and ship's facing are aligned
//wait until abs(np:pitch - facing:pitch) < 0.15 and abs(np:yaw - facing:yaw) < 0.15.

//the ship is facing the right direction, let's wait for our burn time
wait until nd:eta <= (burn_duration/2).

//we only need to lock throttle once to a certain variable in the beginning of the loop, and adjust only the variable itself inside it
set tset to 0.
lock throttle to tset.

set done to False.
//initial deltav
set dv0 to nd:deltav.
until done
{
    //recalculate current max_acceleration, as it changes while we burn through fuel
    set max_acc to ship:maxthrust/ship:mass.

    //throttle is 100% until there is less than 1 second of time left to burn
    //when there is less than 1 second - decrease the throttle linearly
    set tset to min(nd:deltav:mag/max_acc, 1).

    //here's the tricky part, we need to cut the throttle as soon as our nd:deltav and initial deltav start facing opposite directions
    //this check is done via checking the dot product of those 2 vectors
    if vdot(dv0, nd:deltav) < 0
    {
        print "End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
        lock throttle to 0.
        break.
    }

    //we have very little left to burn, less then 0.1m/s
    if nd:deltav:mag < 0.1
    {
        print "Finalizing burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
        //we burn slowly until our node vector starts to drift significantly from initial vector
        //this usually means we are on point
        wait until vdot(dv0, nd:deltav) < 0.5.

        lock throttle to 0.
        print "End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
        set done to True.
    }
}
unlock steering.
unlock throttle.
wait 1.

//we no longer need the maneuver node
remove nd.

//set throttle to 0 just in case.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

}.