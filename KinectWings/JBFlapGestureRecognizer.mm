//
//  JBFlapGestureRecognizer.m
//  KinectWings
//
//  Created by John Boiles on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JBFlapGestureRecognizer.h"
#include <XnCppWrapper.h>
#import "Skeleton.h"
#import "XnVector3DUtils.h"

@implementation JBFlapGestureRecognizer

@synthesize delegate=_delegate;

// Figure out the velocity vector for an arm since the last sample
//- (XnVector3D)vectorFor...

- (void)skeletalTrackingBegan {
  // Startup
}

- (void)skeletalTrackingDidContinueWithSkeleton:(Skeleton *)skeleton {
  _index++;
  if (_index >= (kNumberOfSamples)) _index = 0;

  _leftHandPositions[_index] = skeleton.leftHand;
  _rightHandPositions[_index] = skeleton.rightHand;

  // Calculate left hand vector
  // TODO: Not handling initialization
  NSUInteger previousIndex = (_index + kNumberOfSamples - 1) % kNumberOfSamples;
  NSUInteger previousPreviousIndex = (_index + kNumberOfSamples - 2) % kNumberOfSamples;
  // Get the moving average (v2 - v1) * 0.7 + (v1 - v0) * 0.3
  XnVector3D leftHandVector = XnVector3DSum(2, XnVector3DMultiply(XnVector3DDifference(_leftHandPositions[_index].position, _leftHandPositions[previousIndex].position), 0.7), XnVector3DMultiply(XnVector3DDifference(_leftHandPositions[previousIndex].position, _leftHandPositions[previousPreviousIndex].position), 0.3));
  XnVector3D rightHandVector = XnVector3DSum(2, XnVector3DMultiply(XnVector3DDifference(_rightHandPositions[_index].position, _rightHandPositions[previousIndex].position), 0.7), XnVector3DMultiply(XnVector3DDifference(_rightHandPositions[previousIndex].position, _rightHandPositions[previousPreviousIndex].position), 0.3));

  // Get the mean vector of flap thrust
  XnVector3D thrustVector = XnVector3DAverage(2, leftHandVector, rightHandVector);

  // Don't consider it a flap gesture unless it has at least some downward thrust
  if (thrustVector.Y >= 0) {
    XnVector3D XnVector3DZero;
    XnVector3DZero.X = 0;
    XnVector3DZero.Y = 0;
    XnVector3DZero.Z = 0;
    [_delegate flapGestureRecognizer:self didGetThrustVector:XnVector3DZero];
    return;
  }

  [_delegate flapGestureRecognizer:self didGetThrustVector:thrustVector];
  /*
  switch (_state) {
    case JB3DGestureRecognizerStatePossible:
      // If both arms are above shoulders, and don't have upward velocity, move to state Began
      break;
    case JB3DGestureRecognizerStateBegan:
      // If arms have downward velocity, move to JB3DGestureRecognizerStateChanged
      break;
    case JB3DGestureRecognizerStateChanged:
      // As long as both arms maintain downward velocity, stay in this state
      // If arms haven't gone downward in the last 0.5 seconds, move to JB3DGestureRecognizerStatePossible
      // If arms do not maintain downward velocity, move to JB3DGestureRecognizerStateEnded
      break;
    case JB3DGestureRecognizerStateEnded:
      // Log that the gesture ended.
      // Move to JB3DGestureRecognizerStatePossible
    default:
      break;
  }
   */
}

- (void)skeletalTrackingDidEnd {
  // Cleanup
}

@end
