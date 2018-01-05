//List Of Orbit-related Function

//Find Acending / Descending Node

//Take a make the 'normal' vector of the 2 orbits and do the cross product.
// The result is a vector that is the true anomaly of both orbits.
FUNCTION Find_Acending_Vector{
	PARAMETER Orbitable_1.
	PARAMETER Orbitable_0 IS SHIP.
	
	//Normal for first object.
	
	LOCAL Normal_Vector_1 IS VECTORCROSSPRODUCT(Orbitable_1:POSITION - Orbitable_1:BODY:POSITION, Orbitable_1:VELOCITY:ORBIT).
	LOCAL Normal_Vector_0 IS VECTORCROSSPRODUCT(Orbitable_0:POSITION - Orbitable_0:BODY:POSITION, Orbitable_0:VELOCITY:ORBIT).
	
	RETURN VECTORCROSSPRODUCT(Normal_Vector_1, Normal_Vector_0).
}
//to get the True Anomaly out of the return vector, just calculate the angle between the ship position and this vector
//ex: TA = VECTORANGLE(SHIP:POSITION - SHIP:BODY:POSITION, Find_Acending_Vector(TheOtherOrbitable)).

//Find Degrees between 2 orbits.

FUNCTION Find_diff_Orbits{
	PARAMETER Orbitable_1.
	PARAMETER Orbitable_0 IS SHIP.
	PAREMETER time_t IS TIME.
	
	//Normal for first object.
	
	LOCAL Normal_Vector_1 IS VECTORCROSSPRODUCT(POSITIONAT(Orbitable_1, time_t) - POSITIONAT(Orbitable_1:BODY,time_t), VELOCITYAT(Orbitable_1,time_t):ORBIT).
	LOCAL Normal_Vector_0 IS VECTORCROSSPRODUCT(POSITIONAT(Orbitable_0, time_t) - POSITIONAT(Orbitable_0:BODY,time_t), VELOCITYAT(Orbitable_0,time_t):ORBIT).
	
	RETURN VECTORANGLE(Normal_Vector_1, Normal_Vector_0).
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
FUNCTION Seconds_To_Anomaly {
	PARAMETER TA.
	PARAMETER MA //TODO: IS MA From TA.
	PARAMETER TIME_0 IS TIME.
	PARAMETER Orbit_1 IS SHIP:ORBIT.

	
	IF (Orbit_1:ECCENTRICITY >= 1)
		RETURN -1.
	
	LOCAL a IS Orbit_1:SEMIMAJORAXIS.
	LOCAL MA1 IS Mean_Anormality_at_t(Orbit_1,TIME_0).
	LOCAL MA2 IS MA.

	
	LOCAL delta_Sec IS SQRT(ABS(a^3) / Orbit_1:BODY:MU) * (MA2 - MA1)*(2*CONSTANT:Pi /360).
	IF (secs < 0)
		RETURN delta_Sec + Orbit_0:PERIOD.
	RETURN delta_Sec.
}


//Mean Anormality at time T
//kOS uses Degrees by default.
FUNCTION Mean_Anormality_at_t {
	PARAMETER Orbit_0.
	PARAMETER Time_t IS TIME.
	
	LOCAL n is 360/ Orbit_0:PERIOD.
	
	return Orbit_0:MEANANOMALYATEPOCH + n (Time_t - Orbit_0:EPOCH).
}



