//
//  JBFlapGestureRecognizer.m
//  KinectWings
//
//  Created by John Boiles on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JBFlapGestureRecognizer.h"
#include <XnCppWrapper.h>

XnVector3D XnVector3DSum(NSUInteger count, ...) {
  va_list arguments;
  va_start(arguments, count);
  XnVector3D sumVector;
  sumVector.X = 0;
  sumVector.Y = 0;
  sumVector.Z = 0;
  for (NSUInteger i = 0; i < count; i++) {
    XnVector3D vector = va_arg(arguments, XnVector3D);
    sumVector.X += vector.X;
    sumVector.Y += vector.Y;
    sumVector.Z += vector.Z;
  }
  va_end(arguments);
  return sumVector;
}

XnVector3D XnVector3DAverage(NSUInteger count, ...) {
  va_list arguments;
  va_start(arguments, count);
  XnVector3D sumVector;
  sumVector.X = 0;
  sumVector.Y = 0;
  sumVector.Z = 0;
  for (NSUInteger i = 0; i < count; i++) {
    XnVector3D vector = va_arg(arguments, XnVector3D);
    sumVector.X += vector.X;
    sumVector.Y += vector.Y;
    sumVector.Z += vector.Z;
  }
  va_end(arguments);
  sumVector.X = sumVector.X / count;
  sumVector.Y = sumVector.Y / count;
  sumVector.Z = sumVector.Z / count;
  return sumVector;
}

XnVector3D XnVector3DDifference(XnVector3D v1, XnVector3D v2) {
  XnVector3D difference;
  difference.X = v1.X - v2.X;
  difference.Y = v1.Y - v2.Y;
  difference.Z = v1.Z - v2.Z;
  return difference;
}

XnVector3D XnVector3DMultiply(XnVector3D vector, double multiplier) {
  XnVector3D difference;
  difference.X = vector.X * multiplier;
  difference.Y = vector.Y * multiplier;
  difference.Z = vector.Z * multiplier;
  return difference;
}

double XnVector3DMagnitude(XnVector3D vector) {
  return sqrt(pow(vector.X, 2) + pow(vector.Y, 2) + pow(vector.Z, 2));
}

XnSkeletonJointPosition GetJointPosition(xn::UserGenerator userGenerator, XnUserID user, XnSkeletonJoint joint) {
  XnSkeletonJointPosition jointPosition;
  xnGetSkeletonJointPosition(userGenerator.GetHandle(), user, joint, &jointPosition);
  return jointPosition;
}

@implementation JBFlapGestureRecognizer

@synthesize delegate=_delegate;

// Figure out the velocity vector for an arm since the last sample
//- (XnVector3D)vectorFor...

- (void)skeletalTrackingBeganWithUserGenerator:(xn::UserGenerator)userGenerator user:(XnUserID)user {
  // Startup
}

- (void)skeletalTrackingDidContinueWithUserGenerator:(xn::UserGenerator)userGenerator user:(XnUserID)user {
  // Maybe we should store all this in a skeleton object for easy comprehension
  XnSkeletonJointPosition leftHandPosition = GetJointPosition(userGenerator, user, XN_SKEL_LEFT_HAND);
  //XnSkeletonJointPosition leftElbowJoint = [self getJointPositionForJoint:XN_SKEL_LEFT_ELBOW];
  //XnSkeletonJointPosition leftShoulderJoint = [self getJointPositionForJoint:XN_SKEL_LEFT_SHOULDER];
  XnSkeletonJointPosition rightHandPosition = GetJointPosition(userGenerator, user, XN_SKEL_RIGHT_HAND);
  //XnSkeletonJointPosition rightElbowJoint = [self getJointPositionForJoint:XN_SKEL_RIGHT_ELBOW];
  //XnSkeletonJointPosition rightShoulderJoint = [self getJointPositionForJoint:XN_SKEL_RIGHT_SHOULDER];

  _index++;
  if (_index >= (kNumberOfSamples)) _index = 0;
  _leftHandPositions[_index] = leftHandPosition;
  _rightHandPositions[_index] = rightHandPosition;

  // Calculate left hand vector
  // TODO: Not handling initialization
  NSUInteger previousIndex = (_index + kNumberOfSamples - 1) % kNumberOfSamples;
  NSUInteger previousPreviousIndex = (_index + kNumberOfSamples - 2) % kNumberOfSamples;
  // Get the moving average (v2 - v1) * 0.7 + (v1 - v0) * 0.3
  XnVector3D leftHandVector = XnVector3DSum(2, XnVector3DMultiply(XnVector3DDifference(_leftHandPositions[_index].position, _leftHandPositions[previousIndex].position), 0.7), XnVector3DMultiply(XnVector3DDifference(_leftHandPositions[previousIndex].position, _leftHandPositions[previousPreviousIndex].position), 0.3));
  XnVector3D rightHandVector = XnVector3DSum(2, XnVector3DMultiply(XnVector3DDifference(_rightHandPositions[_index].position, _rightHandPositions[previousIndex].position), 0.7), XnVector3DMultiply(XnVector3DDifference(_rightHandPositions[previousIndex].position, _rightHandPositions[previousPreviousIndex].position), 0.3));

  [_delegate flapGestureRecognizer:self didGetLeftWingVector:leftHandVector rightWingVector:rightHandVector];
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
