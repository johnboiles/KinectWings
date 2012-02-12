//
//  JBAppDelegate.m
//  KinectWings
//
//  Created by John Boiles on 1/13/12.
//  Copyright (c) 2012 John Boiles. All rights reserved.
//

#import "JBAppDelegate.h"
#import <OpenGL/gl.h>
#include <XnCppWrapper.h>
#import <QuartzCore/QuartzCore.h>
#include <GLUT/glut.h>
#import "JBFlapGestureRecognizer.h"
#import "DepthView.h"
#import "VerticalGuageView.h"
#import "math.h"
#import "Skeleton.h"

@implementation JBAppDelegate

@synthesize window=_window;

- (void)dealloc {
  [super dealloc];
}

- (void)display {
  [_openGLView setNeedsDisplay:YES];
  xn::UserGenerator userGenerator = [[CocoaOpenNI sharedOpenNI] userGenerator];
  XnUserID user = [[CocoaOpenNI sharedOpenNI] firstTrackingUser];
  Skeleton *skeleton = [Skeleton skeletonFromUserGenerator:userGenerator user:user];
  [_flapGestureRecognizer skeletalTrackingDidContinueWithSkeleton:skeleton];
  [_tiltGestureRecognizer skeletalTrackingDidContinueWithSkeleton:skeleton];
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  [_window setAspectRatio:NSMakeSize(640, 480)];
  [[CocoaOpenNI sharedOpenNI] startWithConfigPath:[[NSBundle mainBundle] pathForResource:@"KinectConfig" ofType:@"xml"]];
  [_openGLView setup];
  _flapGestureRecognizer = [[JBFlapGestureRecognizer alloc] init];
  _flapGestureRecognizer.delegate = self;
  _tiltGestureRecognizer = [[JBTiltGestureRecognizer alloc] init];
  _tiltGestureRecognizer.delegate = self;
  // XXX(johnb): I think I'm supposed to do this with CADisplayLink or something like that. This seems ghetto
  [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(display) userInfo:nil repeats:YES];
}

#pragma mark - JBFlapGestureRecognizerDelegate

- (void)flapGestureRecognizer:(JBFlapGestureRecognizer *)flapGestureRecognizer didGetThrustVector:(XnVector3D)thrustVector {
  _leftVerticalGuageView.value = -thrustVector.Y / 100.0;
  _rightVerticalGuageView.value = 0.5 + thrustVector.Z / 100.0;
  [_leftVerticalGuageView setNeedsDisplay:YES];
  [_rightVerticalGuageView setNeedsDisplay:YES];
}

#pragma mark - JBTiltGestureRecognizerDelegate

- (void)tiltGestureRecognizer:(JBTiltGestureRecognizer *)tiltGestureRecognizer didGetTiltAngle:(double)angle {
  [_angleTextField setStringValue:[NSString stringWithFormat:@"%f", angle]];
  [_leftVerticalGuageView setBoundsRotation:angle];
  [_leftVerticalGuageView setNeedsDisplay:YES];
  [_rightVerticalGuageView setBoundsRotation:angle];
  [_rightVerticalGuageView setNeedsDisplay:YES];
}

@end
