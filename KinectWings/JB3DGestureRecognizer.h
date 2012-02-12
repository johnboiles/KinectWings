//
//  JB3DGestureRecognizer.h
//  KinectWings
//
//  Created by John Boiles on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <XnCppWrapper.h>

@class Skeleton;

@protocol JB3DGestureRecognizer <NSObject>
- (void)skeletalTrackingBegan;
- (void)skeletalTrackingDidContinueWithSkeleton:(Skeleton *)skeleton;
- (void)skeletalTrackingDidEnd;
@end

// States have been modeled after UIGestureRecognizer in an attempt to keep implementation familiar.
typedef enum {
  // The gesture recognizer has not yet recognized its gesture, but may be evaluating events. This is the default state.
  JB3DGestureRecognizerStatePossible,
  // The gesture recognizer has received tracking info recognized as a continuous gesture.
  // It sends its action message (or messages) at the next cycle of the run loop.
  JB3DGestureRecognizerStateBegan,
  // The gesture recognizer has received tracking info recognized as a change to a continuous gesture.
  // It sends its action message (or messages) at the next cycle of the run loop.
  JB3DGestureRecognizerStateChanged,
  // The gesture recognizer has received tracking info recognized as the end of a continuous gesture.
  // It sends its action message (or messages) at the next cycle of the run loop and resets its state to UIGestureRecognizerStatePossible.
  JB3DGestureRecognizerStateEnded,
  // The gesture recognizer has received tracking info resulting in the cancellation of a continuous gesture.
  // It sends its action message (or messages) at the next cycle of the run loop and resets its state to UIGestureRecognizerStatePossible.
  JB3DGestureRecognizerStateCancelled,

  // The gesture recognizer has received a tracking sequence that it cannot recognize as its gesture.
  // No action message is sent and the gesture recognizer is reset to UIGestureRecognizerStatePossible.
  JB3DGestureRecognizerStateFailed,
  // The gesture recognizer has received a tracking sequence that it recognizes as its gesture.
  // It sends its action message (or messages) at the next cycle of the run loop and resets its state to UIGestureRecognizerStatePossible.
  JB3DGestureRecognizerRecognized,
} JB3DGestureRecognizerState;

@interface JB3DGestureRecognizer : NSObject <JB3DGestureRecognizer> {
  JB3DGestureRecognizerState _state;
  XnUserID _user;
}

@end
