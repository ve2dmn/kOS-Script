//List Of Orbit-related Function

//Find Acending / Descending Node

//Take a make the 'normal' vector of the 2 orbits and do the cross product.
// The result is a vector that is the true anomaly of both orbits.
FUNCTION Find_Acending_Vector{
	PARAMETER Orbitable_1.
	PARAMETER Orbitable_0 IS SHIP.
	PARAMETER Descending IS FALSE.
	
	LOCAL POSITION_0 IS Orbitable_0:POSITION - Orbitable_0:BODY:POSITION.
	LOCAL POSITION_1 IS Orbitable_1:POSITION - Orbitable_1:BODY:POSITION.
	LOCAL Normal_Vector_1 IS VECTORCROSSPRODUCT(POSITION_1, Orbitable_1:VELOCITY:ORBIT):NORMALIZED.
	LOCAL Normal_Vector_0 IS VECTORCROSSPRODUCT(POSITION_0, Orbitable_0:VELOCITY:ORBIT):NORMALIZED.
	
	LOCAL Vector_to_Node IS VECTORCROSSPRODUCT(Normal_Vector_0, Normal_Vector_1).
	
	LOCAL Check_if_AN IS VECTORDOTPRODUCT(SHIP:BODY:UP:UPVECTOR,VECTORCROSSPRODUCT(Normal_Vector_0-Normal_Vector_1, Vector_to_Node)).
	LOCAL Vector_to_AN Is Vector_to_Node:NORMALIZED.
	LOCAL Vector_to_DN Is -Vector_to_Node:NORMALIZED.
	
	//Vector_to_AN is really Vector_to_DN. Reverse both.
	if(Check_if_AN > 0 ) {
		SET Vector_to_AN  TO Vector_to_DN.
		SET Vector_to_DN  TO Vector_to_Node:NORMALIZED.
		}

	IF(Descending) {
			RETURN Vector_to_DN.
		}
	
	RETURN Vector_to_AN.

}
//to get the True Anomaly out of the return vector, just calculate the angle between the ship position and this vector
//ex: TA = VECTORANGLE(SHIP:POSITION - SHIP:BODY:POSITION, Find_Acending_Vector(TheOtherOrbitable)).



//Find Degrees between 2 orbits.
FUNCTION Find_degree_Orbits{
	PARAMETER Orbitable_1.
	PARAMETER Orbitable_0 IS SHIP.
	PARAMETER time_t IS TIME.
	
	
	LOCAL POSITION_0 IS POSITIONAT(Orbitable_0, time_t) - POSITIONAT(Orbitable_0:BODY,time_t).
	LOCAL POSITION_1 IS POSITIONAT(Orbitable_1, time_t) - POSITIONAT(Orbitable_1:BODY,time_t).
	//Normal for first object.
	
	LOCAL Normal_Vector_1 IS VECTORCROSSPRODUCT(POSITION_1, VELOCITYAT(Orbitable_1,time_t):ORBIT).
	LOCAL Normal_Vector_0 IS VECTORCROSSPRODUCT(POSITION_0, VELOCITYAT(Orbitable_0,time_t):ORBIT).
	
	RETURN VECTORANGLE(Normal_Vector_1, Normal_Vector_0).
	
	//This function also works to find the inclination between the 2 planes:
	//RETURN ARCCOS( VECTORDOTPRODUCT(Normal_Vector_0,Normal_Vector_1)/sqrt(Normal_Vector_0:SQRMAGNITUDE * Normal_Vector_1:SQRMAGNITUDE)).
}


//Get Mean Anomaly From True Anomaly
FUNCTION GetMaFromTA {
	PARAMETER TA.
	PARAMETER eccent.
	
	//First Get Eccentric anomaly from TA:
	//COS E = (e+COS(TA)) /  (1+eCOS(TA)
	
	LOCAL Eccen_Anomaly IS ARCCOS((eccent+COS(TA)) /  (1+eccent * COS(TA) )).
	
	//Then Get Mean Anomaly From Eccentric Anomaly:
	//M = E- esinE
	RETURN Eccen_Anomaly - (eccent * SIN(Eccen_Anomaly)).

}




//Time to True Anomaly and /or Mean Anomaly

//Formula is based on Kepler 3rd law:
//P^2= 4*Pi*a^3 / G(M1+M2)
//If M1 >>>> M2, then we can approximate:
//P^2 = 4*Pi*a^3 / G*M
//P is the time it takes for a revolution,
// So if we want a fraction of this time, we can write
//P(s) = X * SRQT(4*Pi*a^3 / G*M ) = 2*Pi*X * SRQT(a^3 / G*M )
//Put the ratio X in the difference in Mean Anomaly (in radian) and you get
//P(s) = dMA * SRQT(a^3 / Body:mu)


//This function assumes T0 is now.
//Return garbage in paraboles and Hyperboles
FUNCTION Seconds_To_TAnomaly {
	PARAMETER TA.
	PARAMETER TIME_0 IS TIME.
	PARAMETER Orbit_1 IS SHIP:ORBIT.
	PARAMETER MA IS GetMaFromTA(TA,Orbit_1:ECCENTRICITY).
	
	IF (Orbit_1:ECCENTRICITY >= 1)
		RETURN -1.
	
	LOCAL a IS Orbit_1:SEMIMAJORAXIS.
	LOCAL MA1 IS Mean_Anormality_at_t(Orbit_1,TIME_0).
	LOCAL MA2 IS MA.
	
	LOCAL Diff IS MA2 -MA1.
	If (Diff < 0)
		SET Diff TO Diff+360.

	LOCAL delta_Sec IS SQRT(ABS(a^3) / Orbit_1:BODY:MU) * (Diff)* Constant:DegToRad.

	RETURN delta_Sec.
}

//Time to Mean Anomaly based on Orbit:PERIOD
//Return garbage in paraboles and Hyperboles
FUNCTION Seconds_To_MAnomaly {
	PARAMETER MA2.
	PARAMETER TIME_0 IS TIME.
	PARAMETER Orbit_1 IS SHIP:ORBIT.
	PARAMETER MA1 IS Mean_Anormality_at_t(Orbit_1,TIME_0).

	IF (Orbit_1:ECCENTRICITY >= 1)
		RETURN -1.
	
	
	LOCAL Diff IS MA2 -MA1.
	If (Diff < 0)
		SET Diff TO Diff+360.

	LOCAL delta_Sec IS Orbit:PERIOD * (Diff/360).

	RETURN delta_Sec.
}




//Mean Anormality at time T
//kOS uses Degrees by default.
FUNCTION Mean_Anormality_at_t {
	PARAMETER Orbit_0 IS SHIP:ORBIT.
	PARAMETER Time_t IS TIME.
	
	
	LOCAL n is 360/ Orbit_0:PERIOD.
	
	LOCAL Anomaly IS Orbit_0:MEANANOMALYATEPOCH + n*(Time_t:seconds - Orbit_0:EPOCH).
	
	UNTIL (Anomaly <360)
		SET Anomaly TO Anomaly - 360.
	
	Return Anomaly.
}



