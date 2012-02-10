//
//  JBFlapGestureRecognizer.h
//  KinectWings
//
//  Created by John Boiles on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JB3DGestureRecognizer.h"

@class JBFlapGestureRecognizer;

@protocol JBFlapGestureRecognizerDelegate <NSObject>
// TODO(johnb): Combine these into a single vector
// TODO(johnb): Don't register flap gestures if arms aren't extended outward
// TODO(johnb): Time out flap gestures after a moment of no flapping
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

@end
