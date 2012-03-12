//
//  JBFlyingController.m
//  KinectWings
//
//  Created by John Boiles on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JBFlyingController.h"

#define constrain(value, min, max) (value) < (min) ? (min) : ((value) > (max) ? (max) : (value))

@implementation JBFlyingController

@synthesize delegate=_delegate;

- (id)init {
  self = [super init];
  if (self) {
    _flapGestureRecognizer = [[JBFlapGestureRecognizer alloc] init];
    _flapGestureRecognizer.delegate = self;
    _tiltGestureRecognizer = [[JBTiltGestureRecognizer alloc] init];
    _tiltGestureRecognizer.delegate = self;
    _armsExtendedGestureRecognizer = [[JBArmsExtendedGestureRecognizer alloc] init];
    _armsExtendedGestureRecognizer.delegate = self;
  }
  return self;
}

- (void)dealloc {
  _flapGestureRecognizer.delegate = nil;
  [_flapGestureRecognizer release];
  _tiltGestureRecognizer.delegate = nil;
  [_tiltGestureRecognizer release];
  _armsExtendedGestureRecognizer.delegate = nil;
  [_armsExtendedGestureRecognizer release];
  [super dealloc];
}

- (void)skeletalTrackingBegin {
  
}

- (void)skeletalTrackingDidContinueWithSkeleton:(Skeleton *)skeleton {
  [_flapGestureRecognizer skeletalTrackingDidContinueWithSkeleton:skeleton];
  [_tiltGestureRecognizer skeletalTrackingDidContinueWithSkeleton:skeleton];
  [_armsExtendedGestureRecognizer skeletalTrackingDidContinueWithSkeleton:skeleton];
  [_delegate flyingController:self didGetForward:_forward vertical:_vertical sidestep:_sidestep turn:_turn];
}

- (void)skeletalTrackingDidEnd {
  
}

#pragma mark - JBFlapGestureRecognizerDelegate

- (void)flapGestureRecognizer:(JBFlapGestureRecognizer *)flapGestureRecognizer didGetThrustVector:(XnVector3D)thrustVector {
  _forward = thrustVector.Z / 100;
  _vertical = -thrustVector.Y / 80 - 0.05;
}

#pragma mark - JBTiltGestureRecognizerDelegate

- (void)tiltGestureRecognizer:(JBTiltGestureRecognizer *)tiltGestureRecognizer didGetTiltAngle:(double)angle {
  _turn = constrain(-angle / 45, -1, 1);
}

#pragma mark - JBArmsExtendedGestureRecognizerDelegate

- (void)armsExtendedGestureRecognizerDidExtendArms:(JBArmsExtendedGestureRecognizer *)armsExtendedGestureRecognizer {
  [_delegate flyingControllerDidRecognizeFlyer:self];
}

- (void)armsExtendedGestureRecognizerDidFinishExtendingArms:(JBArmsExtendedGestureRecognizer *)armsExtendedGestureRecognizer {
  [_delegate flyingControllerStopRecognizingFlyer:self];
}

@end
