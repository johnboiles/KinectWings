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
  [_landTimer invalidate];
  _landTimer = nil;
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

- (void)_takeOff {
  _takeOffTimer = nil;
  [_delegate flyingControllerShouldTakeOff:self];
}

- (void)_land {
  _landTimer = nil;
  [_delegate flyingControllerShouldLand:self];
}

#pragma mark - JBFlapGestureRecognizerDelegate

- (void)flapGestureRecognizer:(JBFlapGestureRecognizer *)flapGestureRecognizer didGetThrustVector:(XnVector3D)thrustVector {
  _forwardCumulative += thrustVector.Z / 170;
  _forwardCumulative = constrain(_forwardCumulative, -2.0, 2.0);
  // TODO: do this compensation using a timestamp
  if (_forwardCumulative > 0) {
    _forwardCumulative -= 0.05;
  } else {
    _forwardCumulative += 0.05;
  }
  _forward = _forwardCumulative;

  double verticalThrust = -thrustVector.Y / 250;
  _verticalCumulative += verticalThrust;
  _verticalCumulative = constrain(_verticalCumulative, -2, 2);
  if (_verticalCumulative > 0.00) {
    _verticalCumulative -= 0.06;
  } else {
    _verticalCumulative += 0.06;
  }
  _verticalCumulative -= 0.05;
  _vertical = _verticalCumulative;
}

#pragma mark - JBTiltGestureRecognizerDelegate

- (void)tiltGestureRecognizer:(JBTiltGestureRecognizer *)tiltGestureRecognizer didGetTiltAngle:(double)angle {
  _turn = constrain(-angle / 45, -1, 1);
}

#pragma mark - JBArmsExtendedGestureRecognizerDelegate

- (void)armsExtendedGestureRecognizerDidExtendArms:(JBArmsExtendedGestureRecognizer *)armsExtendedGestureRecognizer {
  [_delegate flyingControllerDidRecognizeFlyer:self];
  [_landTimer invalidate];
  _landTimer = nil;
  [_takeOffTimer invalidate];
  _takeOffTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(_takeOff) userInfo:nil repeats:NO];
}

- (void)armsExtendedGestureRecognizerDidFinishExtendingArms:(JBArmsExtendedGestureRecognizer *)armsExtendedGestureRecognizer {
  [_delegate flyingControllerStopRecognizingFlyer:self];
  [_takeOffTimer invalidate];
  _takeOffTimer = nil;
  [_landTimer invalidate];
  _landTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(_land) userInfo:nil repeats:NO];
}

@end
