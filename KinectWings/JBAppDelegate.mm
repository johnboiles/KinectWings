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
#import "ControlData.h"
#import "JBWindow.h"

extern navdata_unpacked_t ctr;

@implementation JBAppDelegate

@synthesize window=_window;

- (void)dealloc {
  [super dealloc];
}

- (void)display {
  //[_openGLView setNeedsDisplay:YES];
  // Read next available data
  // If we skip this, the view will appear paused
  if ([CocoaOpenNI sharedOpenNI].started) {
    [[CocoaOpenNI sharedOpenNI] context].WaitAndUpdateAll();
    xn::UserGenerator userGenerator = [[CocoaOpenNI sharedOpenNI] userGenerator];
    XnUserID user = [[CocoaOpenNI sharedOpenNI] firstTrackingUser];
    if (user) {
      Skeleton *skeleton = [Skeleton skeletonFromUserGenerator:userGenerator user:user];
      [_flapGestureRecognizer skeletalTrackingDidContinueWithSkeleton:skeleton];
      [_tiltGestureRecognizer skeletalTrackingDidContinueWithSkeleton:skeleton];
      [_drone performSelectorOnMainThread:@selector(sendControls) withObject:nil waitUntilDone:NO];
    }
  }
  [_droneVideoView setNeedsDisplay:YES];
}

- (IBAction)takeOff:(id)sender {
  [_drone takeOff];
}

- (IBAction)setSomeConfigs:(id)sender {
  [_drone setSomeControls];
}

#pragma mark - NSApplicationDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  [_window setAspectRatio:NSMakeSize(640, 480)];
  [_window setWindowDelegate:self];
  [[CocoaOpenNI sharedOpenNI] startWithConfigPath:[[NSBundle mainBundle] pathForResource:@"KinectConfig" ofType:@"xml"]];
  //[_openGLView setup];
  if ([CocoaOpenNI sharedOpenNI].started) {
    _flapGestureRecognizer = [[JBFlapGestureRecognizer alloc] init];
    _flapGestureRecognizer.delegate = self;
    _tiltGestureRecognizer = [[JBTiltGestureRecognizer alloc] init];
    _tiltGestureRecognizer.delegate = self;
  }
  // XXX(johnb): I think I'm supposed to do this with CADisplayLink or something like that. This seems ghetto
  _drone = [[ARDrone alloc] initWithFrame:CGRectZero withState:YES];
  [NSThread detachNewThreadSelector:@selector(timerThread) toTarget:_drone withObject:nil];
  //[NSTimer scheduledTimerWithTimeInterval:0.03 target:self selector:@selector(display) userInfo:nil repeats:YES];
  //[NSThread detachNewThreadSelector:@selector(refreshThread) toTarget:self withObject:nil];
  [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(display) userInfo:nil repeats:YES];
  [_drone setSomeControls];
}

#pragma mark - JBFlapGestureRecognizerDelegate

- (void)flapGestureRecognizer:(JBFlapGestureRecognizer *)flapGestureRecognizer didGetThrustVector:(XnVector3D)thrustVector {
  _leftVerticalGuageView.value = -thrustVector.Y / 100.0;
  [_leftVerticalGuageView setNeedsDisplay:YES];
  [_rightVerticalGuageView setNeedsDisplay:YES];
  float thrust = thrustVector.Z / 100;
  _rightVerticalGuageView.value = 0.5 + thrust / 2;
  [_thrustTextField setStringValue:[NSString stringWithFormat:@"%0.2f", thrust]];
  [_drone setPitch:thrust * 0.8];
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

#pragma mark - JBWindowDelegate

- (BOOL)handleKeyDownEvent:(NSEvent *)event {
  if ([event modifierFlags] & NSNumericPadKeyMask) {
    NSString *arrow = [event charactersIgnoringModifiers];
    unichar keyChar = [arrow characterAtIndex:0];
    if (keyChar == NSRightArrowFunctionKey) {
      NSLog(@"Right Arrow");
      [_drone setYaw:0.7];
      [_drone sendControls];
    } else if (keyChar == NSLeftArrowFunctionKey) {
      NSLog(@"Left Arrow");
      [_drone setYaw:-0.7];
      [_drone sendControls];
    } else if (keyChar == NSUpArrowFunctionKey) {
      NSLog(@"Up Arrow");
      [_drone setPitch:0.7];
      [_drone sendControls];
    } else if (keyChar == NSDownArrowFunctionKey) {
      NSLog(@"Down Arrow");
      [_drone setPitch:-0.7];
      [_drone sendControls];
    }
    return YES;
  } else {
    return NO;
  }
}

- (BOOL)handleKeyUpEvent:(NSEvent *)event {
  if ([event modifierFlags] & NSNumericPadKeyMask) {
    NSString *arrow = [event charactersIgnoringModifiers];
    unichar keyChar = [arrow characterAtIndex:0];
    if (keyChar == NSRightArrowFunctionKey || keyChar == NSLeftArrowFunctionKey) {
      NSLog(@"Right or Left Arrow Up");
      [_drone setYaw:0.0];
      [_drone sendControls];
    } else if (keyChar == NSUpArrowFunctionKey || keyChar == NSDownArrowFunctionKey) {
      NSLog(@"Up or Down Arrow Up");
      [_drone setPitch:0.0];
      [_drone sendControls];
    }
    return YES;
  } else {
    return NO;
  }
}

@end

