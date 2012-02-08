//
//  JBFlapGestureRecognizer.h
//  KinectWings
//
//  Created by John Boiles on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JB3DGestureRecognizer.h"

@class JBFlapGestureRecognizer;

@protocol JBFlapGestureRecognizerDelegate
- (void)flapGestureRecognizer:(JBFlapGestureRecognizer *)flapGestureRecognizer didGetLeftWingVector:(XnVector3D)leftWingVector rightWingVector:(XnVector3D)rightWingVector;
@end

#define kNumberOfSamples 3

@interface JBFlapGestureRecognizer : JB3DGestureRecognizer {
  id<JBFlapGestureRecognizerDelegate> _delegate;

  NSUInteger _index;
  XnSkeletonJointPosition _leftHandPositions[kNumberOfSamples];
  XnSkeletonJointPosition _rightHandPositions[kNumberOfSamples];
}
@property (weak, nonatomic) id<JBFlapGestureRecognizerDelegate> delegate;

- (void)skeletalTrackingDidContinueWithUserGenerator:(xn::UserGenerator)userGenerator user:(XnUserID)user;

@end

XnVector3D XnVector3DSum(NSUInteger count, ...);

XnVector3D XnVector3DAverage(NSUInteger count, ...);

double XnVector3DMagnitude(XnVector3D vector);

XnVector3D XnVector3DDifference(XnVector3D v1, XnVector3D v2);