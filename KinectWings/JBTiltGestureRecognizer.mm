//
//  JBTiltGestureRecognizer.m
//  KinectWings
//
//  Created by John Boiles on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JBTiltGestureRecognizer.h"
#import "Skeleton.h"
#include <XnCppWrapper.h>
#import "XnVector3DUtils.h"

@implementation JBTiltGestureRecognizer

@synthesize delegate=_delegate;

- (void)skeletalTrackingBegan {
  
}

// If arms are extended
//   - Both arms are no more than 20 degrees from the angle projected from the shoulders)
// Calculate the average of the angle of the arms
- (void)skeletalTrackingDidContinueWithSkeleton:(Skeleton *)skeleton {

  // Check if arm is straight-ish. Will be 0 if the arm is perfectly straight
  double straightRightArmAngle = AngleBetweenXnVector3D(XnVector3DDifference(skeleton.rightElbow.position, skeleton.rightShoulder.position), XnVector3DDifference(skeleton.rightHand.position, skeleton.rightElbow.position));

  double straightLeftArmAngle = AngleBetweenXnVector3D(XnVector3DDifference(skeleton.leftElbow.position, skeleton.leftShoulder.position), XnVector3DDifference(skeleton.leftHand.position, skeleton.leftElbow.position));

  XnVector3D rightShoulderToHand = XnVector3DDifference(skeleton.rightHand.position, skeleton.rightShoulder.position);  
  double rightHandAngleAboveHorizon = AngleAboveHorizon(rightShoulderToHand);

  XnVector3D leftShoulderToHand = XnVector3DDifference(skeleton.leftHand.position, skeleton.leftShoulder.position);
  double leftHandAngleAboveHorizon = AngleAboveHorizon(leftShoulderToHand);

  // IDEA: What if instead of cutting to zero for these factors I instead had the angle diminish
  // For example, if you brought your arms closer to your body you would still be able to turn, just not as quickly.
  // Similarly for flapping, if you flap without fully extended arms you don't get as much power.

  // Stop recognizing gesture if arms aren't straight or angles are too extreme or arm angles are too different
  if (straightRightArmAngle > 40 || straightLeftArmAngle > 40 || abs(rightHandAngleAboveHorizon) > 60 || abs(leftHandAngleAboveHorizon) > 60 || (rightHandAngleAboveHorizon + leftHandAngleAboveHorizon) > 30) {
    [_delegate tiltGestureRecognizer:self didGetTiltAngle:0];
    return;
  }

  double angle = (rightHandAngleAboveHorizon - leftHandAngleAboveHorizon) / 2;
  [_delegate tiltGestureRecognizer:self didGetTiltAngle:angle];
}

- (void)skeletalTrackingDidEnd {
  
}

@end
