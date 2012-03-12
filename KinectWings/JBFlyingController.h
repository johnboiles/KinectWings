//
//  JBFlyingController.h
//  KinectWings
//
//  Created by John Boiles on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JBFlapGestureRecognizer.h"
#import "JBTiltGestureRecognizer.h"
#import "JBArmsExtendedGestureRecognizer.h"

@class JBFlyingController;

@protocol JBFlyingControllerDelegate <NSObject>
- (void)flyingController:(JBFlyingController *)flyingController didGetForward:(double)forward vertical:(double)vertical sidestep:(double)sidestep turn:(double)turn;
- (void)flyingControllerShouldLand:(JBFlyingController *)flyingController;
- (void)flyingControllerShouldTakeOff:(JBFlyingController *)flyingController;
- (void)flyingControllerDidRecognizeFlyer:(JBFlyingController *)flyingController;
- (void)flyingControllerStopRecognizingFlyer:(JBFlyingController *)flyingController;

@end

/*!
 This controller is responsible for interpreting a skeleton into a desired forward velocity, sidestep velocity,
 and turn (yaw). It also handles take off and landing gestures.
 */
@interface JBFlyingController : NSObject <JBFlapGestureRecognizerDelegate, JBTiltGestureRecognizerDelegate, JBArmsExtendedGestureRecognizerDelegate> {
  id<JBFlyingControllerDelegate> _delegate;

  JBFlapGestureRecognizer *_flapGestureRecognizer;
  JBTiltGestureRecognizer *_tiltGestureRecognizer;
  JBArmsExtendedGestureRecognizer *_armsExtendedGestureRecognizer;
  NSTimer *_takeOffTimer;
  NSTimer *_landTimer;

  double _forwardCumulative;
  double _forward;
  double _verticalCumulative;
  double _vertical;
  double _sidestep;
  double _turn;
}

@property (assign, nonatomic) id<JBFlyingControllerDelegate> delegate;

- (void)skeletalTrackingBegin;

- (void)skeletalTrackingDidContinueWithSkeleton:(Skeleton *)skeleton;

- (void)skeletalTrackingDidEnd;

@end
