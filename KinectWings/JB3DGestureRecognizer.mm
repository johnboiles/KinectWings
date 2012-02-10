//
//  JB3DGestureRecognizer.m
//  KinectWings
//
//  Created by John Boiles on 1/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JB3DGestureRecognizer.h"
#include <XnCppWrapper.h>

@implementation JB3DGestureRecognizer

// Perhaps we have a timer on the main thread that calls events based on the state
// Then also a timer on another thread that's reading skeletal data, processing it, and updating the state
// I wonder if GCD makes sense here

// Or maybe we just do it all in the second timer. There's not a callback every time the skeleton moves
// like there are with touches, so the whole two threaded part might not make sense.

// Must have a seperate instance per user

- (void)skeletalTrackingBeganWithUserGenerator:(xn::UserGenerator)userGenerator user:(XnUserID)user {
  
}

- (void)skeletalTrackingDidContinueWithUserGenerator:(xn::UserGenerator)userGenerator user:(XnUserID)user {
  
}

- (void)skeletalTrackingDidEnd {
  
}

@end
