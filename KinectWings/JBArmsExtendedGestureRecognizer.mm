//
//  JBArmsExtendedGestureRecognizer.mm
//  KinectWings
//
//  Created by John Boiles on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "JBArmsExtendedGestureRecognizer.h"
#include <XnCppWrapper.h>
#import "XnVector3DUtils.h"
#import "Skeleton.h"

@implementation JBArmsExtendedGestureRecognizer

@synthesize delegate=_delegate;

- (id)init {
  self = [super init];
  if (self) {
    _timeout = 1.5; // Default timeout
    _state = JBArmsExtendedGestureRecognizerStatePossible;
  }
  return self;
}

- (void)_gestureTimeout {
  _state = JBArmsExtendedGestureRecognizerStatePossible;
  _timeoutTimer = nil;
  [_delegate armsExtendedGestureRecognizerDidFinishExtendingArms:self];
}

- (void)skeletalTrackingBegan {
  
}

- (void)skeletalTrackingDidContinueWithSkeleton:(Skeleton *)skeleton {
  switch (_state) {
    case JBArmsExtendedGestureRecognizerStatePossible:
      // TODO: Require particularly straight arms to get this started
      if ([skeleton armsAreStraightOutToTheSide]) {
        // We look to have arms extended, set the timeout timestamp
        _timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:_timeout target:self selector:@selector(_gestureTimeout) userInfo:nil repeats:NO];
        _state = JBArmsExtendedGestureRecognizerStateExtended;
        [_delegate armsExtendedGestureRecognizerDidExtendArms:self];
      }
      break;
    case JBArmsExtendedGestureRecognizerStateExtended:
      if ([skeleton armsAreStraightOutToTheSide]) {
        // If arms are still extended, push the timeout timer back
        [_timeoutTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:_timeout]];
      } else {
        _state = JBArmsExtendedGestureRecognizerStateNotExtended;
      }
      break;
    case JBArmsExtendedGestureRecognizerStateNotExtended:
      if ([skeleton armsAreStraightOutToTheSide]) {
        // If arms are extended, push the timeout timer back
        [_timeoutTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:_timeout]];
        _state = JBArmsExtendedGestureRecognizerStateExtended;
      }
    default:
      break;
  }
}

- (void)skeletalTrackingDidEnd {
  
}

@end
