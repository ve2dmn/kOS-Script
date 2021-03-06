//Based on hellolaunch
//First, we'll clear the terminal screen to make it look nice
CLEARSCREEN.
//Next, we'll lock our throttle to 100%.
LOCK THROTTLE TO 1.0.   // 1.0 is the max, 0.0 is idle.
//This is a trigger that constantly checks to see if our thrust is zero.
//If it is, it will attempt to stage and then return to where the script
//left off. The PRESERVE keyword keeps the trigger active even after it
//has been triggered.

//SET myPart TO SHIP:PARTSDUBBED("FuelA")[0].

SET Logging TO FALSE.

SET TargetAltitude TO 80000.
SET GravCst TO 9.82. 
SET TargetOrbitalSpeed TO 600000 * SQRT(GravCst/(600000+TargetAltitude)).
SET Staggincount TO 3.
Set PitchingSteer to 90.
SET AirResistPitch TO 90.
SET AdjustedThrottle TO 1.
SET SpeedPitch TO 90.
SET AltitudePitch TO 90.
SET GravityLoss TO 1.
SET DragCoef TO 1.
SET CrossSection TO 1.25.
SET Area TO constant:pi * (CrossSection/2)*(CrossSection/2).
SET DragCST TO DragCoef * Area.
SET RemainingSecs TO 400.
SET oneSecondsLater to TIME:SECONDS + 1.


PRINT "TargetAltitude:" + TargetAltitude .
PRINT "TargetOrbitalSpeed" + TargetOrbitalSpeed.

//For Apergus Stagging
//WHEN myPart:RESOURCES[0]:amount = 0 THEN {
//	PRINT "Part Staging".
//	STAGE.
//	}


WHEN MAXTHRUST = 0 THEN {

	PRINT "Staging".
	STAGE.
	IF(AVAILABLETHRUST <= 0)
		RETURN FALSE.
	RETURN TRUE.

}.

if(Logging) {
LOG "TIME" + "," +
 "SHIP:ALTITUDE" + "," +
 "TargetAltitude" + "," +
 "AltitudePitch" + "," +
 "GROUNDSPEED" + "," +
 "VERTICALSPEED" + "," +
 "AIRSPEED" + "," +
 "SpeedPitch" + "," +
 "SHIP:Q" + "," +
 "SHIP:SENSORS:PRES" + "," +
 "AirResistPitch" + "," +
 "SHIP:APOAPSIS" + "," +
 "AVAILABLETHRUST" + "," +
 "SHIP:MASS" + "," +
 "SHIP:WETMASS" + "," +
 "SHIP:DRYMASS" + "," +
 "PitchingSteer"
  to "0:/Launch.csv". 

  }.
//Loggin loop
WHEN TIME:SECONDS > oneSecondsLater THEN {
if(Logging) {
SET oneSecondsLater to TIME:SECONDS + 1.
LOG TIME:SECONDS + "," +
 SHIP:ALTITUDE + "," +
 TargetAltitude + "," +
 AltitudePitch + "," +
 GROUNDSPEED + "," +
 VERTICALSPEED + "," +
 AIRSPEED + "," +
 SpeedPitch + "," +
 SHIP:Q + "," +
 SHIP:SENSORS:PRES + "," +
 AirResistPitch + "," +
 SHIP:APOAPSIS + "," +
 AVAILABLETHRUST + "," +
 SHIP:MASS + "," +
 SHIP:WETMASS + "," +
 SHIP:DRYMASS + "," +
 PitchingSteer
  to "0:/Launch.csv". 
  }.
RETURN TRUE.
}


//This will be our main control loop for the ascent. It will
//cycle through continuously until our apoapsis is greater
//than 100km. Each cycle, it will check each of the IF
//statements inside and perform them if their conditions
//are met.
LOCK RemainingSecs TO ((70000-SHIP:ALTITUDE)/MAX(0.0000001,SIN(PitchingSteer)))  /  MAX(0.0000001,SHIP:AIRSPEED).
LOCK AirEstimatedLoss TO (SHIP:Q * DragCST)/2 * RemainingSecs.
LOCK AirResistPitch TO MIN((AirEstimatedLoss*10),90).
LOCK SpeedPitch TO (100-(GROUNDSPEED/12)).
LOCK AltitudePitch TO (90 - ((SHIP:Altitude /60000 )*90)).
LOCK GravityLoss TO SIN(PitchingSteer)*AVAILABLETHRUST - SHIP:MASS * GravCst.
LOCK GravityEstimatedLoss TO GravityLoss*SHIP:MASS*(TargetOrbitalSpeed-GROUNDSPEED)/(AVAILABLETHRUST*MAX(0.0001,COS(PitchingSteer))).
LOCK LNPitch TO 90 - (90 *  LN(SHIP:ALTITUDE/TargetAltitude +1)).

SET MYSTEER TO HEADING(90,90).
LOCK THROTTLE TO  AdjustedThrottle.
LOCK STEERING TO MYSTEER. // from now on we'll be able to change steering by just assigning a new value to MYSTEER
UNTIL SHIP:APOAPSIS > 80000 { //Remember, all altitudes will be in meters, not kilometers
    //For the initial ascent, we want our steering to be straight
    //up and rolled due east

	IF  SHIP:ALTITUDE < 500 {
		SET PitchingSteer to AltitudePitch. //Below 500, be conservative....
	}ELSE {
		SET PitchingSteer TO MIN(AltitudePitch,SpeedPitch).
		}
		
		//ELSE IF AirEstimatedLoss < GravityEstimatedLoss{
		//	SET PitchingSteer TO PitchingSteer - 0.5.
		//}ELSE IF AirEstimatedLoss > GravityEstimatedLoss{
		//	SET PitchingSteer TO PitchingSteer + 0.5.
	//	}
	//}

//		} ELSE IF AirResistPitch < AltitudePitch {
		//Not being aggressive enough
//		SET PitchingSteer TO AirResistPitch.
//	} ELSE {
//		SET PitchingSteer to AltitudePitch.
//	}

	IF PitchingSteer >90 SET PitchingSteer to 90.
	IF PitchingSteer <0 SET PitchingSteer to 0.



	PRINT "Pitching to " + PitchingSteer + " degrees" AT(0,15).
	PRINT "APOAPSIS: " + ROUND(SHIP:APOAPSIS,0) AT (0,16).
	PRINT "Velocities " AT(0,17).
	PRINT "Ship Air Velocity:" + SHIP:AIRSPEED AT(0,18).
	PRINT "Air Pressure     :" + SHIP:Q AT(0,19).
	PRINT "Estimated AirLoss:" + AirEstimatedLoss AT(0,21).
	PRINT "Gravity Loss     :" + GravityLoss AT(0,22).
	PRINT "Est. Gravity Loss:" + GravityEstimatedLoss  AT(0,23).
	PRINT "Air Resist Pitch :" + AirResistPitch AT(0,24).
	PRINT "Speed Pitch      :" + SpeedPitch AT(0,25).
	PRINT "LN (70000x) Pitch:" + LNPitch  AT(0,26).

	// Logic for Throttle going too fast
//	IF AirEstimatedLoss < 100 {
//		SET AdjustedThrottle TO 1.
//	}ELSE IF AirEstimatedLoss > 19 {
//		SET AdjustedThrottle TO 0.4.
//	}ELSE IF AirEstimatedLoss > 18 {
//		SET AdjustedThrottle TO 0.5.
//	}ELSE IF AirEstimatedLoss > 17 {
//		SET AdjustedThrottle TO 0.7.
//	}ELSE IF AirEstimatedLoss > 16 {
//		SET AdjustedThrottle TO 0.8.
//	} ELSE IF AdjustedThrottle < 1  {
//		SET AdjustedThrottle to (AdjustedThrottle + 0.01).
//	}

	
    IF SHIP:VELOCITY:SURFACE:MAG < 100 {
	//This sets our steering 90 degrees up and yawed to the compass
		//heading of 90 degrees (east)
        SET MYSTEER TO HEADING(90,90).

    //Once we pass 100m/s, we want to pitch down
    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 100 {
        SET MYSTEER TO HEADING(90,PitchingSteer).
    } 


}.
CLEARSCREEN.
PRINT "80km apoapsis reached, cutting throttle".
