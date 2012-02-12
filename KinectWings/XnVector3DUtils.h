//
//  XnVector3DUtils.h
//  KinectWings
//
//  Created by John Boiles on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#include <XnTypes.h>

XnVector3D XnVector3DSum(NSUInteger count, ...);

XnVector3D XnVector3DAverage(NSUInteger count, ...);

double XnVector3DMagnitude(XnVector3D vector);

XnVector3D XnVector3DDifference(XnVector3D v1, XnVector3D v2);

XnVector3D XnVector3DMultiply(XnVector3D vector, double multiplier);

double XnVector3DDotProduct(XnVector3D v1, XnVector3D v2);

// In degrees
double AngleBetweenXnVector3D(XnVector3D v1, XnVector3D v2);

// Angle away from ground (XZ plane)
double AngleAboveHorizon(XnVector3D vector);

double AngleFromYZPlane(XnVector3D vector);

double AngleFromZAxisOnXZPlane(XnVector3D vector);