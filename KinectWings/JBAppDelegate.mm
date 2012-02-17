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
#import "ARDrone.h"
#include "ControlData.h"

extern navdata_unpacked_t ctr;
extern ControlData ctrldata;

@implementation JBAppDelegate

@synthesize window=_window;

- (void)dealloc {
  [super dealloc];
}

- (void)display {
  //[_openGLView setNeedsDisplay:YES];
  // Read next available data
  // If we skip this, the view will appear paused
  [[CocoaOpenNI sharedOpenNI] context].WaitNoneUpdateAll();
  [_droneVideoView setNeedsDisplay:YES];
  xn::UserGenerator userGenerator = [[CocoaOpenNI sharedOpenNI] userGenerator];
  XnUserID user = [[CocoaOpenNI sharedOpenNI] firstTrackingUser];
  Skeleton *skeleton = [Skeleton skeletonFromUserGenerator:userGenerator user:user];
  [_flapGestureRecognizer skeletalTrackingDidContinueWithSkeleton:skeleton];
  [_tiltGestureRecognizer skeletalTrackingDidContinueWithSkeleton:skeleton];
}

- (IBAction)takeOff:(id)sender {
  [_drone takeOff];
}

- (IBAction)left:(id)sender {
  [_drone setYaw:0];
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  [_window setAspectRatio:NSMakeSize(640, 480)];
  [[CocoaOpenNI sharedOpenNI] startWithConfigPath:[[NSBundle mainBundle] pathForResource:@"KinectConfig" ofType:@"xml"]];
  //[_openGLView setup];
  _flapGestureRecognizer = [[JBFlapGestureRecognizer alloc] init];
  _flapGestureRecognizer.delegate = self;
  _tiltGestureRecognizer = [[JBTiltGestureRecognizer alloc] init];
  _tiltGestureRecognizer.delegate = self;
  // XXX(johnb): I think I'm supposed to do this with CADisplayLink or something like that. This seems ghetto
  _drone = [[ARDrone alloc] initWithFrame:CGRectZero withState:YES withDelegate:self];
  [NSThread detachNewThreadSelector:@selector(timerThread) toTarget:_drone withObject:nil];
  //[NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(display) userInfo:nil repeats:YES];
  [NSThread detachNewThreadSelector:@selector(refreshThread) toTarget:self withObject:nil];
  //[NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(display) userInfo:nil repeats:YES];
}

- (void)refreshThread {
  while (YES) {
    [self display];
    sleep(1.0 / 30.0);
  }
}

#pragma mark - JBFlapGestureRecognizerDelegate

- (void)flapGestureRecognizer:(JBFlapGestureRecognizer *)flapGestureRecognizer didGetThrustVector:(XnVector3D)thrustVector {
  _leftVerticalGuageView.value = -thrustVector.Y / 100.0;
  [_leftVerticalGuageView setNeedsDisplay:YES];
  [_rightVerticalGuageView setNeedsDisplay:YES];
  float thrust = thrustVector.Z / 100;
  _rightVerticalGuageView.value = 0.5 + thrust / 2;
  [_thrustTextField setStringValue:[NSString stringWithFormat:@"%0.2f", thrust]];
  ctrldata.accelero_flag = ARDRONE_PROGRESSIVE_CMD_COMBINED_YAW_ACTIVE;
  [_drone setPitch:thrust * .8];
  [_drone setVertical:- thrustVector.Y / 80 - 0.05];
}

#pragma mark - JBTiltGestureRecognizerDelegate

- (void)tiltGestureRecognizer:(JBTiltGestureRecognizer *)tiltGestureRecognizer didGetTiltAngle:(double)angle {
  [_angleTextField setStringValue:[NSString stringWithFormat:@"%0.2f", angle]];
  [_leftVerticalGuageView setBoundsRotation:angle];
  [_leftVerticalGuageView setNeedsDisplay:YES];
  [_rightVerticalGuageView setBoundsRotation:angle];
  [_rightVerticalGuageView setNeedsDisplay:YES];
  float yaw = -angle / 45;
  [_drone setYaw:yaw];
}

#pragma mark - ARDroneDelegate

- (void)executeCommandOut:(ARDRONE_COMMAND_OUT)commandId withParameter:(void *)parameter fromSender:(id)sender {
  NSLog(@"executeCommandOut %d from %@", commandId, sender);
}

@end
