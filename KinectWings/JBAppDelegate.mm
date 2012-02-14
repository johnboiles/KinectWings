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

extern navdata_unpacked_t ctrlnavdata;

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

- (IBAction)takeOff:(id)sender {
  [_drone omgflyaway];
}

- (IBAction)left:(id)sender {
  [_drone setYaw:0];
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
  static ARDroneHUDConfiguration hudconfiguration;
  _drone = [[ARDrone alloc] initWithFrame:CGRectZero withState:YES withDelegate:self withHUDConfiguration:&hudconfiguration];
  [NSThread detachNewThreadSelector:@selector(TimerHandler) toTarget:_drone withObject:nil];

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
  [_drone setYaw:angle / 90];
}

#pragma mark - ARDroneDelegate

- (void)executeCommandOut:(ARDRONE_COMMAND_OUT)commandId withParameter:(void *)parameter fromSender:(id)sender {
  NSLog(@"executeCommandOut %d from %@", commandId, sender);
}

@end
