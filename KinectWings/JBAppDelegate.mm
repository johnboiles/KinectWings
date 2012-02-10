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

- (void)initOpenGL {
  glDisable(GL_DEPTH_TEST);
  glEnable(GL_TEXTURE_2D);
  glEnableClientState(GL_VERTEX_ARRAY);
  glDisableClientState(GL_COLOR_ARRAY);

  _openGLView.started = YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  [[CocoaOpenNI sharedOpenNI] start];
  [self initOpenGL];
  _flapGestureRecognizer = [[JBFlapGestureRecognizer alloc] init];
  _flapGestureRecognizer.delegate = self;
  _tiltGestureRecognizer = [[JBTiltGestureRecognizer alloc] init];
  _tiltGestureRecognizer.delegate = self;

  // XXX(johnb): I think I'm supposed to do this with CADisplayLink or something like that. This seems ghetto
  [NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(display) userInfo:nil repeats:YES];
}

- (void)flapGestureRecognizer:(JBFlapGestureRecognizer *)flapGestureRecognizer didGetLeftWingVector:(XnVector3D)leftWingVector rightWingVector:(XnVector3D)rightWingVector {
  //NSLog(@"Vector %f, %f, %f", leftWingVector.X, leftWingVector.Y, leftWingVector.Z);
  //double magnitude = XnVector3DMagnitude(leftWingVector);
  //NSLog(@"Magnitude %f", magnitude);
  NSLog(@"%0.3f %0.3f", leftWingVector.Y, rightWingVector.Y);

  if (leftWingVector.Y < 0) {
    _leftVerticalGuageView.value = -leftWingVector.Y / 100.0;
  } else {
    _leftVerticalGuageView.value = 0;
  }
  [_leftVerticalGuageView setNeedsDisplay:YES];

  if (rightWingVector.Y < 0) {
    _rightVerticalGuageView.value = -rightWingVector.Y / 100.0;
  } else {
    _rightVerticalGuageView.value = 0;
  }
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
