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
  // Read next available data
  // If we skip this, the view will appear paused
  if ([CocoaOpenNI sharedOpenNI].started) {
    // Sometimes we get a crash in here
    [[CocoaOpenNI sharedOpenNI] context].WaitAndUpdateAll();
    xn::UserGenerator userGenerator = [[CocoaOpenNI sharedOpenNI] userGenerator];
    XnUserID user = [[CocoaOpenNI sharedOpenNI] firstTrackingUser];
    // TODO: Need to keep some state to track when the user tracking began
    if (user) {
      Skeleton *skeleton = [Skeleton skeletonFromUserGenerator:userGenerator user:user];
      [_flyingController skeletalTrackingDidContinueWithSkeleton:skeleton];
    } else {
      [_flyingController skeletalTrackingDidEnd];
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
    _flyingController = [[JBFlyingController alloc] init];
    _flyingController.delegate = self;
  }

  _drone = [[ARDrone alloc] initWithFrame:CGRectZero withState:YES];
  _drone.delegate = self;
  // TODO: Wait are we using this one or the one that the drone owns?
  [_droneVideoView setWantsLayer:YES];
  // XXX(johnb): I think I'm supposed to do this with CADisplayLink or something like that. This seems ghetto
  // TODO: Move this inside of ARDrone
  [NSThread detachNewThreadSelector:@selector(timerThread) toTarget:_drone withObject:nil];
  [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 target:self selector:@selector(display) userInfo:nil repeats:YES];

  _indicatorImage.image = [NSImage imageNamed:@"indicator_red.png"];
}

#pragma mark - ARDroneDelegate

- (void)drone:(ARDrone *)drone didEmergencyWithMessage:(NSString *)message {
  NSLog(@"Emergency! %@", message);
  [_emergencyStatusField setStringValue:message];
  [_emergencyStatusField setNeedsDisplay];
}

- (void)droneDidEndEmergency:(ARDrone *)drone {
  NSLog(@"Phew, emergency is over!");
  [_emergencyStatusField setStringValue:@""];
  [_emergencyStatusField setNeedsDisplay];
}

#pragma mark - JBWindowDelegate

- (BOOL)handleKeyDownEvent:(NSEvent *)event {
  BOOL keyPressed = NO;
  NSCharacterSet *characters = [NSCharacterSet characterSetWithCharactersInString:[event characters]];

  if ([characters characterIsMember:NSRightArrowFunctionKey]) {
    [_drone setYaw:0.7];
    keyPressed = YES;    
  }
  if ([characters characterIsMember:NSLeftArrowFunctionKey]) {
    [_drone setYaw:-0.7];
    keyPressed = YES;    
  }
  if ([characters characterIsMember:NSUpArrowFunctionKey]) {
    [_drone setVertical:1.0];
    keyPressed = YES;    
  }
  if ([characters characterIsMember:NSDownArrowFunctionKey]) {
    [_drone setVertical:-1.0];
    keyPressed = YES;    
  }
  if ([characters characterIsMember:[@" " characterAtIndex:0]]) {
    [_drone takeOff];
    keyPressed = YES;    
  }
  if ([characters characterIsMember:[@"w" characterAtIndex:0]]) {
    [_drone setPitch:0.7];
    keyPressed = YES;
  }
  if ([characters characterIsMember:[@"a" characterAtIndex:0]]) {
    [_drone setRoll:-0.7];
    keyPressed = YES;
  }
  if ([characters characterIsMember:[@"s" characterAtIndex:0]]) {
    [_drone setPitch:-0.7];
    keyPressed = YES;
  }
  if ([characters characterIsMember:[@"d" characterAtIndex:0]]) {
    [_drone setRoll:0.7];
    keyPressed = YES;
  }

  if (keyPressed) {
    [_drone sendControls];
    return YES;
  }
  return NO;
}

- (BOOL)handleKeyUpEvent:(NSEvent *)event {
  BOOL keyPressed = NO;
  NSCharacterSet *characters = [NSCharacterSet characterSetWithCharactersInString:[event characters]];
  
  if ([characters characterIsMember:NSRightArrowFunctionKey]) {
    [_drone setYaw:0.0];
    keyPressed = YES;    
  }
  if ([characters characterIsMember:NSLeftArrowFunctionKey]) {
    [_drone setYaw:0.0];
    keyPressed = YES;    
  }
  if ([characters characterIsMember:NSUpArrowFunctionKey]) {
    [_drone setVertical:0.0];
    keyPressed = YES;    
  }
  if ([characters characterIsMember:NSDownArrowFunctionKey]) {
    [_drone setVertical:0.0];
    keyPressed = YES;    
  }
  if ([characters characterIsMember:[@"w" characterAtIndex:0]]) {
    [_drone setPitch:0.0];
    keyPressed = YES;
  }
  if ([characters characterIsMember:[@"a" characterAtIndex:0]]) {
    [_drone setRoll:0.0];
    keyPressed = YES;
  }
  if ([characters characterIsMember:[@"s" characterAtIndex:0]]) {
    [_drone setPitch:0.0];
    keyPressed = YES;
  }
  if ([characters characterIsMember:[@"d" characterAtIndex:0]]) {
    [_drone setRoll:0.0];
    keyPressed = YES;
  }

  if (keyPressed) {
    [_drone sendControls];
    return YES;
  }
  return NO;
}

#pragma mark - JBFlyingControllerDelegate

- (void)flyingController:(JBFlyingController *)flyingController didGetForward:(double)forward vertical:(double)vertical sidestep:(double)sidestep turn:(double)turn {
    
  _leftVerticalGuageView.value = vertical;
  [_leftVerticalGuageView setNeedsDisplay:YES];

  _rightVerticalGuageView.value = 0.5 + forward / 2;
  [_rightVerticalGuageView setNeedsDisplay:YES];  
  [_thrustTextField setStringValue:[NSString stringWithFormat:@"%0.2f", forward]];

  // Let's build a proper rotation indicator sometime
  [_angleTextField setStringValue:[NSString stringWithFormat:@"%0.2f", turn]];
  //[_leftVerticalGuageView setBoundsRotation:angle];
  //[_leftVerticalGuageView setNeedsDisplay:YES];
  //[_rightVerticalGuageView setBoundsRotation:angle];
  //[_rightVerticalGuageView setNeedsDisplay:YES];

  [_drone setPitch:forward];
  [_drone setYaw:turn];
  // Always be drifting down
  [_drone setVertical:vertical - 0.07];
  [_drone sendControls];
}

- (void)flyingControllerShouldLand:(JBFlyingController *)flyingController {
  //[_drone land];
}

- (void)flyingControllerShouldTakeOff:(JBFlyingController *)flyingController {
  //[_drone takeOff];  
} 

- (void)flyingControllerDidRecognizeFlyer:(JBFlyingController *)flyingController {
  _indicatorImage.image = [NSImage imageNamed:@"indicator_green.png"];
  _drone.controlData->accelero_flag |= (1 << ARDRONE_PROGRESSIVE_CMD_ENABLE);
}

- (void)flyingControllerStopRecognizingFlyer:(JBFlyingController *)flyingController {
  _indicatorImage.image = [NSImage imageNamed:@"indicator_red.png"];
  _drone.controlData->accelero_flag &= ~(1 << ARDRONE_PROGRESSIVE_CMD_ENABLE);

}


@end

