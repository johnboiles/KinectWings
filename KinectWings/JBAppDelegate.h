//
//  JBAppDelegate.h
//  KinectWings
//
//  Created by John Boiles on 1/13/12.
//  Copyright (c) 2012 John Boiles. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CocoaOpenNI.h"
#import "JBFlapGestureRecognizer.h"
#import "JBTiltGestureRecognizer.h"
#import "ARDrone.h"
#import "ControlData.h"
#import "JBWindow.h"

@class DepthView;
@class VerticalGuageView;

@interface JBAppDelegate : NSObject <NSApplicationDelegate, JBFlapGestureRecognizerDelegate, JBTiltGestureRecognizerDelegate, JBWindowDelegate> {
  JBWindow *_window;

  IBOutlet DepthView *_openGLView;
  IBOutlet GLViewController *_droneVideoView;
  IBOutlet VerticalGuageView *_leftVerticalGuageView;
  IBOutlet VerticalGuageView *_rightVerticalGuageView;
  IBOutlet NSTextField *_angleTextField;
  IBOutlet NSTextField *_thrustTextField;

  JBFlapGestureRecognizer *_flapGestureRecognizer;
  JBTiltGestureRecognizer *_tiltGestureRecognizer;

  ARDrone *_drone;
  ControlData *_controlData;
}

@property (assign) IBOutlet JBWindow *window;

@end
